load("//bzl/providers:ocaml.bzl",
     "CompilationModeSettingProvider",
     "OcamlModuleMarker",
     "OcamlNsResolverProvider",
     "OcamlProvider",
     "OcamlSignatureProvider")


# load("//ocaml/_transitions:transitions.bzl",
#      "bootstrap_module_in_transition")

load("//bzl:functions.bzl",
     "capitalize_initial_char",
     "get_fs_prefix",
     "get_module_name",
     # "get_sdkpath",
     "normalize_module_label",
     "rename_srcfile",
     "file_to_lib_name")

load(":options.bzl",
     "get_options",
     "options",
     "options_module")
     # "options_ns_opts")

# load(":impl_module.bzl", "impl_module")

load(":impl_common.bzl",
     "dsorder",
     "opam_lib_prefix",
     "tmpdir"
     )

scope = tmpdir

###############################
def _bootstrap_module(ctx):

    tc = ctx.toolchains["//bzl/toolchain:bootstrap"]

    ##mode = ctx.attr._mode[CompilationModeSettingProvider].value

    mode = "bytecode"

    # if mode == "bytecode":
    tool = tc.ocamlrun
    tool_args = [tc.ocamlc]
    # else:
    #     tool = tc.ocamlrun.opt
    #     tool_args = []

    # return impl_module(ctx, mode, tool, tool_args)

    debug = False
    if ctx.label.name in ["Make_opcodes"]:
        debug = True

    # env = {"PATH": get_sdkpath(ctx)}

    # mode = ctx.attr._mode[CompilationModeSettingProvider].value

    # if ctx.attr._rule.startswith("bootstrap"):
    #     tc = ctx.toolchains["//bzl/toolchain:bootstrap"]
    #     if mode == "native":
    #         exe = tc.ocamlrun
    #     else:
    #         ext = ".cmo"
    # else:
    #     tc = ctx.toolchains["@obazl_rules_ocaml//ocaml:toolchain"]
    #     if mode == "native":
    #         exe = tc.ocamlopt.basename
    #     else:
    #         exe = tc.ocamlc.basename

    ext  = ".cmx" if  mode == "native" else ".cmo"

    ################
    includes   = []
    default_outputs    = [] # just the cmx/cmo files, for efaultInfo
    action_outputs   = [] # .cmx, .cmi, .o
    # direct_linkargs = []
    old_cmi = None

    ## module name is derived from sigfile name, so start with sig
    # if we have an input cmi, we will pass it on as Provider output,
    # but it is not an output of this action- do NOT add incoming cmi
    # to action outputs.

    # WARNING: When both .mli and .ml are inputs, '-o' is unavailable:
    # ocaml will write the output to the directory containing the
    # source files. This will NOT be the directory for output files
    # made with declare_file. There is no way that I know of to tell
    # the compiler to write outputs to some other directory. So if
    # both .mli and .ml are inputs, we need to copy/move/link the
    # output files to the correct (Bazel) output dir. Sadly, the
    # compile action will fail before we can do that, since it's
    # outputs will be in the wrong place.

    in_structfile = None
    module_name = None
    mlifile = None
    cmifile = None
    sig_src = None

    sig_inputs = None
    sig_linkargs = None
    sig_paths = None

    ns = None

    if ctx.attr.sig:
        sig_attr = ctx.attr.sig
        if debug:
            print("SIG attr: %s" % sig_attr)

        if OcamlSignatureProvider in sig_attr:
            if debug:
                print("sig is cmi")
            # sig is ocaml_signature target providing cmi file
            # derive module name from sigfile
            # for submodules, sigfile name will already contain ns prefix

            sigProvider = sig_attr[OcamlSignatureProvider]
            cmifile = sigProvider.cmi
            old_cmi = [cmifile]
            mlifile = sigProvider.mli

            if debug:
                print("cmifile: %s" % cmifile)
                print("mlifile: %s" % mlifile)

            ## we're given a sig cmi, so we're going to derive the module
            ## name from the signame rather than the structfile name.
            ## cmifile has been ppxed and ns-renamed if necessary
            module_name = cmifile.basename[:-4]

            (from_name, ns, module_name) = get_module_name(ctx, ctx.file.struct)
            if debug:
                print("From {src} To: {dst}".format(
                    src = from_name, dst = module_name))

            if from_name == module_name:
                if debug:
                    print("not namespaced") # was not renamed

                if ctx.file.struct.is_source:
                    in_structfile = ctx.actions.declare_file(scope + ctx.file.struct.basename)
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                else:
                    ## generated file already in bazel dir
                    in_structfile = ctx.file.struct

            else:
                if debug:
                    print("mlifile was renamed: %s" % mlifile)
                    print("module_name: %s" % module_name)
                # so we need to rename structfile to match
                # NB: mlifile must be added to provider output
                # if ctx.attr.ppx:
                #     in_structfile = impl_ppx_transform(
                #         ctx.attr._rule, ctx,
                #         ctx.file.struct, module_name + ".ml"
                #     )
                # else:

                if ctx.file.struct.is_source:
                    in_structfile = ctx.actions.declare_file(
                        scope + module_name + ".ml"
                    )
                    ctx.actions.symlink(
                        output = in_structfile,
                        target_file = ctx.file.struct
                    )
                else:
                    ## generated file, already in bazel dir
                    in_structfile = ctx.file.struct
                # print("renamed structfile {src} => {dest}".format(
                #     src = ctx.file.struct.path,
                #     dest = in_structfile
                # ))

            includes.append(mlifile.dirname)

            # sig_inputs = sig_attr[DefaultInfo].files
            sig_inputs = sig_attr[OcamlProvider].inputs
            sig_linkargs = sig_attr[OcamlProvider].linkargs
            sig_paths = sig_attr[OcamlProvider].paths

            ## NB: cmifile and mlifile must be kept together,
            ## so both go into inputs (and provided outputs)
##FIXME: rename src_inputs -> sig_inputs
            src_inputs = [cmifile, mlifile] # , in_structfile]
        else:
            if debug:
                print("sig is source file")
            (from_name, ns, module_name) = get_module_name(ctx, ctx.file.sig)
            # print("module_name: %s" % module_name)
            if from_name == module_name:
                if debug:
                    print("not namespaced")
                    print("struct file: %s" % ctx.file.struct.path)
                in_structfile = ctx.actions.declare_file(scope + ctx.file.struct.basename)
                ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                # print("in_structfile: %s" % in_structfile)
                # print("sig file: %s" % ctx.file.sig.path)
                sig_src = ctx.actions.declare_file(scope + ctx.file.sig.basename)
                ctx.actions.symlink(output=sig_src,
                                    target_file = ctx.file.sig)
                # print("sig_src: %s" % sig_src.path)
                cmi = sig_src.basename[:-4] + ".cmi"
                cmifile = ctx.actions.declare_file(scope + cmi)
                # print("cmi out: %s" % cmifile.path)
                action_outputs.append(cmifile)

                ## NB: cmifile and mlifile must be kept together,
                ## so both go into inputs (and provided outputs)
                src_inputs = [sig_src] # , in_structfile] ## , ctx.file.sig]
            else:
                ## namespaced - symlink to ns-prefixed names
                in_structfile = ctx.actions.declare_file(
                    scope + module_name + ".ml"
                )
                ctx.actions.symlink(
                    output = in_structfile, target_file = ctx.file.struct
                )
                # print("in_structfile: %s" % in_structfile)
                # print("sig file: %s" % ctx.file.sig.path)
                sig_src = ctx.actions.declare_file(
                    scope + module_name + ".mli"
                )
                ctx.actions.symlink(
                    output=sig_src, target_file = ctx.file.sig
                )
                # print("sig_src: %s" % sig_src.path)
                cmi = sig_src.basename[:-4] + ".cmi"
                cmifile = ctx.actions.declare_file(scope + cmi)
                # print("cmi out: %s" % cmifile.path)
                action_outputs.append(cmifile)

                ## NB: cmifile and mlifile must be kept together,
                ## so both go into inputs (and provided outputs)
                src_inputs = [sig_src] #, in_structfile] # , ctx.file.sig]
    else:
        if debug:
            print("No sigfile")
        (from_name, ns, module_name) = get_module_name(ctx, ctx.file.struct)
        # print("module_name: %s" % module_name)
        if from_name == module_name:
            # print("not namespaced")
            # if ctx.attr.ppx:
            #     # print("ppxed")
            #     in_structfile = impl_ppx_transform(
            #         ctx.attr._rule, ctx,
            #         ctx.file.struct, module_name + ".ml"
            #     )
            # else:

            # print("no ppx")
            # in_structfile = ctx.file.struct
            # if debug:
            if ctx.file.struct.is_source:
                print("symlinking src structfile: %s" % ctx.file.struct)
                in_structfile = ctx.actions.declare_file(scope + ctx.file.struct.basename)
                ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
            else:
               in_structfile = ctx.file.struct
 

            cmi = module_name + ".cmi"
            cmifile = ctx.actions.declare_file(scope + cmi)
            # print("cmi out: %s" % cmifile.path)
            action_outputs.append(cmifile)
            src_inputs = [] # in_structfile]
        else:
            # print("namespaced")
            ## renaming input puts it into output dir; not strictly
            # necessary, since w/o an mli file, input can be
            # non-namepaced name and no confusion about cmi file ensues.
            ## but for consistency and clarity, we symlink the input
            ## file to ns-prefixed name in output dir. then we could
            ## omit the -o arg, since compiler writes to its input dir
            ## (which after symlinking is our Bazel output dir).
            # w/o renaming we get stuff like:
            # -c -impl modules/namespaced/green.ml
            #    -o bazel-out/ ... /Color__Green.cmx
            # with renaming:
            # -c -impl bazel-out/darwin-fastbuild/ ... /Color__Green.ml
            #    -o bazel-out/darwin-fastbuild-ST ... /Color__Green.cmx

            # if ctx.attr.ppx:
            #     # print("ppxed")
            #     in_structfile = impl_ppx_transform(
            #         ctx.attr._rule, ctx,
            #         ctx.file.struct, module_name + ".ml"
            #     )
            # else:
            # print("no ppx")
            in_structfile = ctx.actions.declare_file(
                scope + module_name + ".ml"
            )
            ctx.actions.symlink(
                output = in_structfile, target_file = ctx.file.struct
            )

            cmi = module_name + ".cmi"
            cmifile = ctx.actions.declare_file(scope + cmi)
            # print("cmi out: %s" % cmifile.path)
            action_outputs.append(cmifile)
            src_inputs = [] # in_structfile]

    out_cm_ = ctx.actions.declare_file(scope + module_name + ext)
                                       # sibling = new_cmi) # fname)
    # print("OUT_CM_: %s" % out_cm_.path)
    action_outputs.append(out_cm_)
    # direct_linkargs.append(out_cm_)
    default_outputs.append(out_cm_)

    if mode == "native":
        # if not ctx.attr._rule.startswith("bootstrap"):
        out_o = ctx.actions.declare_file(scope + module_name + ".o",
                                         sibling = out_cm_)
        action_outputs.append(out_o)
        # direct_linkargs.append(out_o)

    ################
    # indirect_ppx_codep_depsets      = []
    # indirect_ppx_codep_path_depsets = []
    indirect_cc_deps  = {}

    ns_resolver = False
    ns_resolver_files = []
    if ctx.attr.ns:
        ns_resolver = ctx.attr.ns
        ns_resolver_files = ctx.files.ns

    paths_direct = [out_cm_.dirname] # d.dirname for d in direct_linkargs]
    if ns_resolver:
        paths_direct.extend([f.dirname for f in ns_resolver_files])
    # print("RESOLVER PATHS: %s" % paths_direct)

    #########################
    args = ctx.actions.args()

    args.add_all(tool_args)

    # if ctx.attr._rule.startswith("bootstrap"):
    #         args.add(tc.ocamlc)

    _options = get_options(ctx.attr._rule, ctx)
    # if "-for-pack" in _options:
    #     for_pack = True
    #     _options.remove("-for-pack")
    # else:
    #     for_pack = False

    # if ctx.attr.pack:
    #     args.add("-for-pack", ctx.attr.pack)

    args.add_all(_options)

    ## FIXME: support -bin-annot
    # if "-bin-annot" in _options: ## Issue #17
    #     out_cmt = ctx.actions.declare_file(scope + paths.replace_extension(module_name, ".cmt"))
    #     action_outputs.append(out_cmt)

    ################ Direct Deps ################
    the_deps = []
    the_deps.extend(ctx.attr.deps) # + [ctx.attr._ns_resolver]

    #### INDIRECT DEPS first ####
    # these are "indirect" from the perspective of the consumer
    indirect_inputs_depsets = []
    indirect_linkargs_depsets = []
    indirect_paths_depsets = []

    ccInfo_list = []

    for dep in the_deps:
        if CcInfo in dep:
            # if ctx.label.name == "Main":
            #     dump_CcInfo(ctx, dep)
            ccInfo_list.append(dep[CcInfo])

        ## dep's DefaultInfo.files depend on OcamlProvider.linkargs,
        ## so add the latter before the former

        if OcamlProvider in dep:

            # if ctx.label.name == "Mempool":
            #     print("DEP: %s" % dep[DefaultInfo].files)
            #     for ds in dep[OcamlProvider].linkargs.to_list():
            #         print("DS: %s" % ds)

            indirect_inputs_depsets.append(dep[OcamlProvider].inputs)
            indirect_linkargs_depsets.append(dep[OcamlProvider].linkargs)
            indirect_paths_depsets.append(dep[OcamlProvider].paths)

        indirect_linkargs_depsets.append(dep[DefaultInfo].files)

    ################ Signature Dep ################
    if ctx.attr.sig:
        if sig_inputs:
            indirect_inputs_depsets.append(sig_inputs)
            indirect_linkargs_depsets.append(sig_linkargs)
            indirect_paths_depsets.append(sig_paths)

    paths_depset  = depset(
        order = dsorder,
        direct = paths_direct,
        transitive = indirect_paths_depsets
    )

    args.add_all(paths_depset.to_list(), before_each="-I")
    # args.add("-absname")
    args.add_all(includes, before_each="-I", uniquify = True)

    # if hasattr(ctx.attr._ns_resolver[OcamlNsResolverProvider], "resolver"):
    if ns_resolver:
        args.add("-no-alias-deps")
        args.add("-open", ns)

    # attr '_ns_resolver' a label_flag that resolves to a (fixed)
    # ocaml_ns_resolver target whose params are set by transition fns.
    # by default the 'resolver' field is null.

    # if "-shared" in _options:
    #     args.add("-shared")
    # else:

    ## if we rec'd a .cmi sigfile, we must add its SOURCE file to the dep graph!
    ## otherwise the ocaml compiler will not use the cmx file, it will generate
    ## one from the module source.
    sig_in = [sig_src] if sig_src else []
    mli_out = [mlifile] if mlifile else []
    cmi_out = [cmifile] if cmifile else [] # new_cmi]

    ## runtime deps must be added to the depgraph (so they get built),
    ## but not the command line (they are not build-time deps).

    ns_deps = []
    if ns_resolver:
        if OcamlProvider in ns_resolver:
            # print("LBL: %s" % ctx.label)
            # print("NS RESOLVER: %s" % ns_resolver)
            # print("NS RESOLVER DefaultInfo: %s" % ns_resolver[DefaultInfo])
            # print("NS RESOLVER OcamlProvider: %s" % ns_resolver[OcamlProvider])
            ns_deps = [ns_resolver[OcamlProvider].inputs]

    ## bottomup ns:
    # if hasattr(ctx.attr, "ns"):
    if ctx.attr.ns:
        # print("NS lbl: %s" % ctx.label)
        # print("ns: %s" % ctx.file.ns)
        bottomup_ns_resolver = ctx.attr.ns
        bottomup_ns_files   = [bottomup_ns_resolver[DefaultInfo].files]
        bottomup_ns_inputs  = [bottomup_ns_resolver[OcamlProvider].inputs]
        bottomup_ns_fileset = [bottomup_ns_resolver[OcamlProvider].fileset]
        bottomup_ns_cmi     = [bottomup_ns_resolver[OcamlProvider].cmi]
    else:
        bottomup_ns_resolver = []
        bottomup_ns_files    = []
        bottomup_ns_fileset  = []
        bottomup_ns_inputs   = []
        bottomup_ns_cmi      = []

    # print("bottomup_ns_inputs: %s" % bottomup_ns_inputs)

    if debug:
        print("SRC_INPUTS: %s" % src_inputs)

    inputs_depset = depset(
        order = dsorder,
        direct = src_inputs + [in_structfile] + ns_resolver_files
        + mli_out

        # + [sig_src, in_structfile]
        # + mli_out ##
        # + cmi_out
        # + (old_cmi if old_cmi else [])
        + ctx.files.deps_runtime,
        # + ctx.files.data,

        transitive = indirect_inputs_depsets
        + ns_deps
        + bottomup_ns_inputs
    )
    # if ctx.label.name == "Misc":
    #     print("inputs_depset: %s" % inputs_depset)

    args.add("-c")

    if sig_src:
        args.add("-I", sig_src.dirname)
        # args.add("-intf", sig_src)
        args.add(sig_src)

        # args.add("-impl", structfile)
        args.add(in_structfile) # structfile)
    else:
        args.add("-impl", in_structfile) # structfile)
        args.add("-o", out_cm_)

    # if ctx.attr._rule.startswith("bootstrap"):
    #     toolset = [tc.ocamlrun, tc.ocamlc]
    # else:
    #     toolset = [tc.ocamlopt, tc.ocamlc]

    # if debug:
    #     print("INPUTS: %s" % inputs_depset)

    ################
    ctx.actions.run(
        # env = env,
        executable = tool,
        arguments = [args],
        inputs    = inputs_depset,
        outputs   = action_outputs,
        tools = [tool] + tool_args,
        mnemonic = "CompileBootstrapModule",
        progress_message = "{mode} compiling {rule}: {ws}//{pkg}:{tgt}".format(
            mode = mode,
            rule=ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name,
        )
    )
    ################

    default_depset = depset(
        order = dsorder,
        direct = default_outputs,
        transitive = bottomup_ns_files
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )

    ocamlProvider_files_depset = depset(
        order  = dsorder,
        direct = action_outputs + cmi_out + mli_out,
    )

    # new_inputs_depset = depset(
    #     direct = action_outputs,
    #     transitive = [inputs_depset] ## indirect_inputs_depsets
    # )
    ## same as inputs_depset except structfile omitted
    new_inputs_depset = depset(
        order = dsorder,
        direct = src_inputs + action_outputs + ns_resolver_files
        + ctx.files.deps_runtime,
        transitive = indirect_inputs_depsets
        + ns_deps
        + bottomup_ns_inputs
    )

    # if debug:
    #     print("CLOSURE: %s" % new_inputs_depset)

    linkset    = depset(transitive = indirect_linkargs_depsets)

    fileset_depset = depset(
        direct= action_outputs + cmi_out + mli_out,
        transitive = bottomup_ns_fileset
    )

    ocamlProvider = OcamlProvider(
        # files = ocamlProvider_files_depset,
        cmi      = depset(direct = [cmifile]),
        fileset  = fileset_depset,
        inputs   = new_inputs_depset,
        linkargs = linkset,
        paths    = paths_depset,
    )

    ################################################################
    providers = [
        defaultInfo,
        OcamlModuleMarker(marker="OcamlModule"),
        ocamlProvider,
    ]

    ## FIXME: make this conditional:
    ## if this module is a submodule in a namespace:
    # if ns_resolver:
    #     print("MODULE NS_RESOLVER: %s" % ns_resolver)
    # else:
    #     print("NO MODULE NS_RESOLVER: %s" % ns_resolver)

    if ns_resolver:
        nsResolverProvider = OcamlNsResolverProvider(
            files = ctx.files.ns,
            paths = depset([d.dirname for d in ctx.attr.ns.files.to_list()])
        )
        # print("RESOLVER PROVIDER: %s" % nsResolverProvider)
        providers.append(nsResolverProvider)

    # ## if this is a ppx module, its ppx_codeps (direct or indirect)
    # ## must be passed to any ppx_executable that depends on it.
    # ## FIXME: make this conditional:
    # ## if module has direct or indirect ppx_codeps:
    # ppx_codeps_depset = depset(
    #     order = dsorder,
    #     direct = ppx_codeps_list,
    #     transitive = indirect_ppx_codep_depsets
    # )
    # ppxCodepsProvider = PpxAdjunctsProvider(
    #     ppx_codeps = ppx_codeps_depset,
    #     paths = depset(order = dsorder,
    #                    transitive = indirect_ppx_codep_path_depsets)
    # )
    # providers.append(ppxCodepsProvider)

    ## now merge ccInfo list
    if ccInfo_list:
        ccInfo = cc_common.merge_cc_infos(cc_infos = ccInfo_list)
        providers.append(ccInfo )

    ################
    outputGroupInfo = OutputGroupInfo(
        # cc         = ccInfo.linking_context.linker_inputs.libraries,
        cmi        = depset(
            direct=cmi_out,
            transitive = bottomup_ns_cmi
        ),
        fileset    = fileset_depset,
        linkset    = linkset,
        # ppx_codeps = ppx_codeps_depset,
        # cc = action_inputs_ccdep_filelist,
        closure = new_inputs_depset,
        all = depset(
            order = dsorder,
            transitive=[
                default_depset,
                ocamlProvider_files_depset,
                # ppx_codeps_depset,
                # depset(action_inputs_ccdep_filelist)
            ]
        )
    )
    providers.append(outputGroupInfo)

    return providers

################################
# rule_options = options("ocaml") ## we don't want global config defaults
rule_options = options_module("ocaml")
# FIXME: no need for ppx support here
# rule_options.update(options_ppx)
## FIXME: bootstrap ns are bottomup, no need for this:
# rule_options.update(options_ns_opts("ocaml"))

####################
bootstrap_module = rule(
    implementation = _bootstrap_module,
    doc = """Compiles an OCaml module. Provides: [OcamlModuleMarker](providers_ocaml.md#ocamlmoduleprovider).

**CONFIGURABLE DEFAULTS** for rule `ocaml_module`

In addition to the [OCaml configurable defaults](#configdefs) that apply to all
`ocaml_*` rules, the following apply to this rule:

    """,
    attrs = dict(

        rule_options,

        ## opts thru _sdkpath pulled from options fn
        opts = attr.string_list(
            doc = "List of OCaml options. Will override configurable default options."
        ),
        debug           = attr.label(default = "//config:debug"),

        _verbose = attr.label(default = "//config:verbose"),

        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath") # ppx also uses this
        # ),

        ## FIXME: don't need this for bootstrapping
        # _ns_resolver = attr.label(
        #     doc = "Experimental",
        #     providers = [OcamlNsResolverProvider],
        #     default = "@ocaml//bootstrap/ns:resolver",
        # ),

        # _warnings = attr.label(
        # ),

        _rule = attr.string( default = "bootstrap_module" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # incompatible_use_toolchain_transition = True,
    # exec_groups = {
    #     "compile": exec_group(
    #         exec_compatible_with = [
    #             # "@platforms//os:linux",
    #             "@platforms//os:macos"
    #         ],
    #         toolchains = [
    #             "@obazl_rules_ocaml//ocaml:toolchain",
    #             # "@obazl_rules_ocaml//coq:toolchain_type",
    #         ],
    #     ),
    # },
    # cfg     = bootstrap_module_in_transition,
    provides = [OcamlModuleMarker],
    executable = False,
    toolchains = ["//bzl/toolchain:bootstrap"],
)
