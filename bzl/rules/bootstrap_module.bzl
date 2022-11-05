load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "OcamlArchiveProvider",
     "OcamlLibraryMarker",
     "OcamlModuleMarker",
     "OcamlNsMarker",
     "OcamlNsResolverProvider",
     "OcamlProvider",
     "OcamlSignatureProvider")


load("//bzl:functions.bzl",
     "capitalize_initial_char",
     # "compile_mode_in_transition",
     # "compile_mode_out_transition",
     # "ocamlc_out_transition",
     "config_tc",
     "get_fs_prefix",
     "get_module_name",
     # "get_sdkpath",
     "normalize_module_label",
     "rename_srcfile",
     "file_to_lib_name")

load(":options.bzl",
     "get_options")
     # "options",
     # "options_module")
     # "options_ns_opts")

# load(":impl_module.bzl", "impl_module")

load(":impl_common.bzl",
     "dsorder",
     "opam_lib_prefix",
     "tmpdir"
     )

# scope = tmpdir

sigdeps_closure = None
sig_linkargs = None
sig_paths = None

in_structfile = None

###############################
def _bootstrap_module(ctx):


    debug = False
    # if ctx.label.name in ["CamlinternalAtomic"]:
    #     debug = True

    # print("ns: '{ns}' for {m}".format(
    #     ns = ctx.attr._pack_ns[BuildSettingInfo].value,
    #     m = ctx.label))

    # (mode,
    # (tc, tool, tool_args, scope, ext) = config_tc(ctx)
    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    if tc.target_host in ["boot", "dev", "vm"]:
        tool = tc.tool_runner
        ext = ".cmo"
    else:
        tool = tc.compiler
        ext = ".cmx"

    pack_ns = False
    if hasattr(ctx.attr, "_pack_ns"):
        if ctx.attr._pack_ns:
            if ctx.attr._pack_ns[BuildSettingInfo].value:
                pack_ns = ctx.attr._pack_ns[BuildSettingInfo].value
                # print("GOT PACK NS: %s" % pack_ns)

    ################
    includes   = []
    default_outputs    = [] # just the cmx/cmo files, for efaultInfo
    action_outputs   = [] # .cmx, .cmi, .o
    # direct_linkargs = []
    # old_cmi = None

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

    # in_structfile = None
    module_name = None
    mlifile = None
    cmifile = None
    sig_src = None

    ## get_module_name decides if this module is in a namespace
    ## and if so adds ns prefix
    (from_name, ns, module_name) = get_module_name(ctx, ctx.file.struct)
    # print("module_name: %s" % module_name)
    # print("ns: %s" % ns)

    sig_inputs = []
    if ctx.attr.sig:
        sigProvider = ctx.attr.sig[OcamlSignatureProvider]
        provider_output_cmi = sigProvider.cmi
        provider_output_mli = sigProvider.mli
        sig_inputs.append(provider_output_cmi)
        sig_inputs.append(provider_output_mli)
        mli_dir = paths.dirname(provider_output_mli.short_path)
    else:
        action_output_cmi = ctx.actions.declare_file(module_name + ".cmi")
        action_outputs.append(action_output_cmi)
        provider_output_cmi = None
        mli_dir = None

    ## struct: put in same dir as mli/cmi, rename if namespaced
    if from_name == module_name:  ## not namespaced
        if ctx.file.struct.is_source:
            # structfile in src dir, link to bazel dir containing cmi
            if ctx.file.sig:
                in_structfile = ctx.actions.declare_file(ctx.file.struct.basename)
                ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
            else:
                in_structfile = ctx.file.struct
        else:
            # structfile is generated, e.g. by ocamllex or a genrule.
            # make sure it's in same dir as mli/cmi IF we have ctx.file.sig
            if ctx.file.sig:
                if paths.dirname(ctx.file.struct.short_path) != mli_dir:
                    in_structfile = ctx.actions.declare_file(
                        ctx.file.struct.basename)
                    ctx.actions.symlink(
                        output = in_structfile,
                        target_file = ctx.file.struct)
                    if debug:
                        print("symlinked {src} => {dst}".format(
                            src = ctx.file.struct, dst = in_structfile))
                else:
                    if debug:
                        print("not symlinking src: {src}".format(
                            src = ctx.file.struct.path))
                    in_structfile = ctx.file.struct
            else:  ## no sig file
                in_structfile = ctx.file.struct
    else:  ## namespaced
        in_structfile = ctx.actions.declare_file(module_name + ".ml")
        ctx.actions.symlink(
            output = in_structfile, target_file = ctx.file.struct
        )

    ## add provided cmi/mli files to action inputs depgraph
    # if provider_output_cmi:
    #     sig_inputs.append(provider_output_cmi)
    # if provider_output_mli:
    #     sig_inputs.append(provider_output_mli)

    out_cm_ = ctx.actions.declare_file(module_name + ext)
    # sibling = new_cmi) # fname)
    if debug:
        print("OUT_CM_: %s" % out_cm_.path)
    action_outputs.append(out_cm_)
    # direct_linkargs.append(out_cm_)
    default_outputs.append(out_cm_)

    if not tc.target_host:
        # if not ctx.attr._rule.startswith("bootstrap"):
        out_o = ctx.actions.declare_file(module_name + ".o",
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
    # print("NS_RESOLVER: %s" % ns_resolver)

    paths_direct = [out_cm_.dirname] # d.dirname for d in direct_linkargs]
    if ns_resolver:
        paths_direct.extend([f.dirname for f in ns_resolver_files])
    # print("RESOLVER PATHS: %s" % paths_direct)

    #########################
    args = ctx.actions.args()

    # print("TC: %s" % tc)

    # if tc.target_host in ["boot", "dev", "vm"]:
    #     args.add(tc.compiler)
    # args.add_all(tool_args)

    args.add_all(tc.copts)

    _options = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

    # primitives = []
    # if hasattr(ctx.attr, "primitives"):
    #     if ctx.attr.primitives:
    #         primitives.append(ctx.file.primitives)
    #         args.add("-use-prims", ctx.file.primitives.path)

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
    indirect_linkargs_files = []
    indirect_paths_depsets = []

    ccInfo_list = []

    archive_manifest_depsets = []

    for dep in the_deps:
        # print("DEP: %s" % dep)
        if OcamlArchiveProvider in dep:
            # print("Found OcamlArchiveProvider in %s" % ctx.label)
            archive_manifest_depsets.append(dep[OcamlArchiveProvider].manifest)

        if CcInfo in dep:
            # if ctx.label.name == "Main":
            #     dump_CcInfo(ctx, dep)
            ccInfo_list.append(dep[CcInfo])

        ## dep's DefaultInfo.files depend on OcamlProvider.linkargs,
        ## so add the latter before the former

        if OcamlProvider in dep:
            # print("DEP OP: %s" % dep[OcamlProvider])

            # if ctx.label.name == "Mempool":
            #     print("DEP: %s" % dep[DefaultInfo].files)
            #     for ds in dep[OcamlProvider].linkargs.to_list():
            #         print("DS: %s" % ds)

            indirect_inputs_depsets.append(dep[OcamlProvider].inputs)
            indirect_linkargs_depsets.append(dep[OcamlProvider].linkargs)
            indirect_paths_depsets.append(dep[OcamlProvider].paths)

        for f in dep[DefaultInfo].files.to_list():
            if f.extension not in ["cmi", "mli"]:
                indirect_linkargs_files.append(f)


    ################ Signature Dep ################
    if ctx.attr.sig:
        if sigdeps_closure:
            indirect_inputs_depsets.append(sigdeps_closure)
            indirect_linkargs_depsets.append(sig_linkargs)
            indirect_paths_depsets.append(sig_paths)

    paths_depset  = depset(
        order = dsorder,
        direct = paths_direct,
        transitive = indirect_paths_depsets
    )

    # args.add_all(paths_depset.to_list(), before_each="-I")
    # args.add("-absname")
    includes.extend(paths_depset.to_list())
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
    # sig_in = [sig_src] if sig_src else []
    # mli_out = [mlifile] if mlifile else []
    # cmi_out = [cmifile] if cmifile else [] # new_cmi]

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

    # if debug:
    #     print("SIG_INPUTS: %s" % sig_inputs)
    #     print("in_structfile %s" % in_structfile)

    inputs_depset = depset(
        order = dsorder,
        direct = sig_inputs
        + [in_structfile] + ns_resolver_files
        # + mli_out
        + (ctx.files.data if ctx.files.data else [])
        # + [sig_src, in_structfile]
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
    if pack_ns:
        args.add("-for-pack", pack_ns)

    if sig_src:
        args.add("-I", sig_src.dirname)
        # args.add("-intf", sig_src)
        args.add(sig_src)

        # args.add("-impl", structfile)
        args.add(in_structfile) # structfile)
    else:
        args.add("-impl", in_structfile) # structfile)
        args.add("-o", out_cm_)

    ################
    ctx.actions.run(
        # env = env,
        executable = tc.compiler[DefaultInfo].files_to_run,
        # executable = tool,
        arguments = [args],
        inputs    = inputs_depset,
        outputs   = action_outputs,
        tools = [tc.compiler[DefaultInfo].files_to_run],
        # tools = [tc.tool_runner, tc.compiler],
        # tools = [tool] + tool_args,
        mnemonic = "CompileBootstrapModule",
        progress_message = "{mode} compiling {rule}: {ws}//{pkg}:{tgt}".format(
            mode = tc.build_host + ">" + tc.target_host,
            rule=ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else "", ## ctx.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name,
        )
    )
    ################

    default_depset = depset(
        order = dsorder,
        direct = default_outputs,
        # transitive = [depset(direct=default_outputs)]
        # transitive = bottomup_ns_files + [depset(direct=default_outputs)]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )

    ocamlProvider_files_depset = depset(
        order  = dsorder,
        direct = action_outputs # + cmi_out + mli_out,
    )

    # closure_depset = depset(
    #     direct = action_outputs,
    #     transitive = [inputs_depset] ## indirect_inputs_depsets
    # )
    ## same as inputs_depset except structfile omitted
    closure_depset = depset(
        order = dsorder,
        direct = sig_inputs + action_outputs + ns_resolver_files
        + ctx.files.deps_runtime,
        transitive = indirect_inputs_depsets
        + ns_deps
        + bottomup_ns_inputs
    )

    # if debug:
    #     print("CLOSURE: %s" % closure_depset)

    linkset    = depset(
        transitive = indirect_linkargs_depsets +
        [depset(direct = indirect_linkargs_files)]
    )

    # if debug:
    #     print("linkset: %s" % linkset)

    fileset_depset = depset(
        # direct= mli_out + cmi_out + action_outputs,
        direct= action_outputs,
        transitive = bottomup_ns_fileset
    )

    archiveManifestDepset = depset(
        transitive = archive_manifest_depsets
    )
    # print("manifest depset for {lbl}: {m}".format(
    #     lbl = ctx.label, m = archiveManifestDepset))

    # print("provider_output_cmi: %s" % provider_output_cmi)
    # print("action_output_cmi: %s" % action_output_cmi)
    # print("bottomup_ns_cmi: %s" % bottomup_ns_cmi)

    cmi_depset = depset(
        direct = sig_inputs,
        # direct = ([provider_output_cmi] if provider_output_cmi else [action_output_cmi]),
        transitive = bottomup_ns_cmi if bottomup_ns_cmi else []
    )

    ocamlProvider = OcamlProvider(
        # files = ocamlProvider_files_depset,
        cmi      = cmi_depset,
        fileset  = fileset_depset,
        inputs   = closure_depset,
        linkargs = linkset,
        paths    = paths_depset,
        archive_manifests = archiveManifestDepset
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
        cmi        = cmi_depset,
        fileset    = fileset_depset,
        linkset    = linkset,
        # ppx_codeps = ppx_codeps_depset,
        # cc = action_inputs_ccdep_filelist,
        closure = closure_depset,
        manifest = archiveManifestDepset,
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
# rule_options = options_module("ocaml")
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

        # _boot       = attr.label(
        #     default = "//bzl/toolchain:boot",
        # ),

        primitives = attr.label(
            allow_single_file = True,
        ),

        # _toolchain = attr.label(
        #     default = "//bzl/toolchain:tc"
        # ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        # ocamlc = attr.label(
        #     # cfg = ocamlc_out_transition,
        #     allow_single_file = True,
        #     default = "//bzl/toolchain:ocamlc"
        # ),

        # _mode       = attr.label(
        #     default = "//bzl/toolchain",
        # ),

        # mode       = attr.string(
        #     doc     = "Overrides global mode build setting.",
        # ),

        ## opts thru _sdkpath pulled from options fn
        opts = attr.string_list(
            doc = "List of OCaml options. Will override configurable default options."
        ),
        debug           = attr.label(default = "//config:debug"),

        ns = attr.label(
            doc = "Bottom-up namespacing",
            allow_single_file = True,
            mandatory = False
        ),

        struct = attr.label(
            doc = "A single module (struct) source file label.",
            mandatory = False, # pack libs may not need a src file
            allow_single_file = True # no constraints on extension
        ),

        _pack_ns = attr.label(
            doc = """Namepace name for use with -for-pack. Set by transition function.
""",
            # default = "//config/pack:ns"
        ),

        sig = attr.label(
            doc = "Single label of a target producing OcamlSignatureProvider (i.e. rule 'ocaml_signature'). Optional.",
            # cfg = compile_mode_out_transition,
            allow_single_file = True, # [".cmi"],
            ## only allow compiled sigs
            providers = [[OcamlSignatureProvider]],
        ),

        ################
        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            # cfg = compile_mode_out_transition,
            providers = [[OcamlArchiveProvider],
                         [OcamlLibraryMarker],
                         [OcamlModuleMarker],
                         [OcamlNsMarker],
                         [OcamlSignatureProvider],
                         [CcInfo]]
            # transition undoes changes that may have been made by ns_lib
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        deps_runtime = attr.label_list(
            doc = "Deps needed at runtime, but not build time. E.g. .cmxs plugins.",
            allow_files = True,
        ),

        data = attr.label_list(
            allow_files = True,
            doc = "Runtime dependencies: list of labels of data files needed by this module at runtime."
        ),
        ################
        cc_deps = attr.label_keyed_string_dict(
            doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
            """,
            # providers = since this is a dictionary depset, no providers
            ## but the keys must have CcInfo providers, check at build time
            # cfg = ocaml_module_cc_deps_out_transition
        ),

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
    # cfg = compile_mode_in_transition,
    provides = [OcamlModuleMarker],
    executable = False,
    fragments = ["platform", "cpp"],
    host_fragments = ["platform",  "cpp"],
    incompatible_use_toolchain_transition = True,
    toolchains = ["//toolchain/type:bootstrap",
                  # "//toolchain/type:profile",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
