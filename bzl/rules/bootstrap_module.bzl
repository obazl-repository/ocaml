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

########################################
def handle_cmi_dep(ctx, scope, debug):

    sig_attr = ctx.attr.sig

    if debug:
        print("sig is cmi")
    # sig is ocaml_signature target providing cmi file
    # derive module name from sigfile
    # for submodules, sigfile name will already contain ns prefix

    sigProvider = sig_attr[OcamlSignatureProvider]
    provider_output_cmi = sigProvider.cmi
    provider_output_mli = sigProvider.mli

    if debug:
        print("provider_output_cmi: %s" % provider_output_cmi.path)
        print("provider_output_cmi shortdir: {d}".format(
            d = paths.dirname(provider_output_cmi.short_path)))
        print("provider_output_mli: %s" % provider_output_mli.path)
        print("provider_output_mli shortdir: {d}".format(
            d = paths.dirname(provider_output_mli.short_path)))
    ## provider_output_cmi and provider_output_mli should be in same dir, so
    ## paths.dirname(short_path) should match

    ## derive the module name from the signame rather than the
    ## structfile name. provider_output_cmi has been ppxed and
    ## ns-renamed if necessary
    module_name = provider_output_cmi.basename[:-4]

    (from_name, ns, module_name) = get_module_name(ctx, ctx.file.struct)
    if debug:
        print("From '{src}' To: '{dst}'".format(
            src = from_name, dst = module_name))

    ## used in 2 places below, so do it here:
    mli_dir = paths.dirname(provider_output_mli.short_path)

    if from_name == module_name:
        if debug:
            print("not namespaced") # was not renamed
            print("src longpath: %s" % ctx.file.struct.path)
            print("src shortpath: %s" % ctx.file.struct.short_path)
            print("src shortdirname: {d}".format(
                d =  paths.dirname(ctx.file.struct.short_path)))

        if ctx.file.struct.is_source:
            # structfile in src dir, link to bazel dir containing cmi
            in_structfile = ctx.actions.declare_file(scope + ctx.file.struct.basename)
            ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
            if debug:
                print("symlinking src: {src} -> {dst}".format(
                    src = ctx.file.struct, dst = in_structfile))
        else:
            # structfile is generated, e.g. by ocamllex or a genrule.
            # make sure it's in same dir as mli/cmi
            ## FIXME: other way 'round, put cmi in same dir as struct

            if paths.dirname(ctx.file.struct.short_path) != mli_dir:
                in_structfile = ctx.actions.declare_file(
                    scope + ctx.file.struct.basename)
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

    else:  ## not from_name == module_name
        if debug:
            print("module is namespaced: %s" % module_name)

        ## provider_output_mli name should match renamed structfile

        ## FIXME: use case: configured module binding w/in ns
        ## make sure structfile is renamed to match sigfile

        ## input structfile must be in bzl dir , whether it is src or gen
        # if ctx.file.struct.is_source:
        in_structfile = ctx.actions.declare_file(
            scope + module_name + ".ml"
        )
        ctx.actions.symlink(
            output = in_structfile,
            target_file = ctx.file.struct
        )
        # else:
        #     ## generated file, already in bazel dir
        #     in_structfile = ctx.file.struct

    if debug:
        print("renamed structfile {src} => {dest}".format(
            src = ctx.file.struct.path,
            dest = in_structfile
        ))

    ## now make sure srcs and cmi in same dir. otherwise we're vulnerable to
    ## the "Inconsistent assumptions over interface" error.

    ##  easily done with 'sibling' attr of declare_file. we can only
    ##  link to files within the tree rooted at the target, so we link
    ##  the mli/cmi deps to the dir containing the (possibly renamed)
    ##  struct file.
    structfile_dir = paths.dirname(in_structfile.short_path)
    if debug:
        print("mli owner: %s" % provider_output_mli.owner)
        print("mli dir: %s" % mli_dir)
        print("mli root: %s" % provider_output_mli.root.path)
        print("structfile owner: %s" % in_structfile.owner)
        print("structfile dir: %s" % structfile_dir)
    if structfile_dir != mli_dir:
        # case 1: link mli/cmi to structfile bzl dir
        new_mli = ctx.actions.declare_file(
            provider_output_mli.basename,
            sibling = in_structfile
        )
        ctx.actions.symlink(
            output = new_mli,
            target_file = provider_output_mli
        )
        print("linked {src} => {dst}".format(
              src = provider_output_mli, dst = new_mli))
        provider_output_mli = new_mli

        new_cmi = ctx.actions.declare_file(
            provider_output_cmi.basename,
            sibling  = in_structfile,
        )
        ctx.actions.symlink(
            output = new_cmi,
            target_file = provider_output_cmi
        )
        print("linked {src} => {dst}".format(
              src = provider_output_cmi, dst = new_cmi))
        provider_output_cmi = new_cmi

    ## NB: provider_output_cmi and provider_output_mli must be kept together,
    ## so both go into inputs (and provided outputs)
    # sig_inputs = [provider_output_cmi, provider_output_mli] # , in_structfile]

    return (provider_output_mli, provider_output_cmi, None,
            ns, module_name, in_structfile)

####################
## if we have ctx.attr.sig, we need to add the cmi file to
## compile_action_inputs. if mode is n_*, we also need to add the
## mli file.

## we do not need to pass on the depgraph of the cmi target.
def handle_sig(ctx, scope, debug):
    if debug:
        print("handle_sig:")
    if ctx.attr.sig:

        ## cmi file already provided. make sure its in the same dir as
        ## the struct file. rename structfile to match it if needed.
        ## out transitions force the attr to be a list, index by 0:
        if OcamlSignatureProvider in ctx.attr.sig:
            return handle_cmi_dep(ctx, scope, debug)
            # sig_inputs = [cmifile, mlifile]
        else:
            ## bootstrap_signature always uses OcamlSignature
            ## provider, so either ctx.file.sig is a source file or it
            ## was produced by a genrule or some other mechanism.
            if debug:
                fail("ERROR: invalid value for 'sig' attr: %s" % ctx.attr.sig)

    else:
        ## no ctx.attr.sig. rename structfile if in ns, and declare
        ## cmi outfile, which will be added to action outputs
        if debug:
            print("No sigfile")

        (from_name, ns, module_name) = get_module_name(ctx, ctx.file.struct)
        # print("module_name: %s" % module_name)
        if from_name == module_name:
            if debug:
                print("module not in ns - no renaming: %s" % module_name)
            if ctx.file.struct.is_source:
                ## structfile in src tree, symlink it to bazel dir
                in_structfile = ctx.actions.declare_file(
                    scope + ctx.file.struct.basename
                )
                ctx.actions.symlink(
                    output = in_structfile,
                    target_file = ctx.file.struct
                )
                if debug:
                    print("symlinked {src} -> {dst}".format(
                        src = ctx.file.struct, dst = in_structfile))
            else:
                ## structfile was generated, so its already in a bazel dir
                in_structfile = ctx.file.struct
        else:
            if debug:
                print("module in ns - renaming: {src} -> {dst}".format(
                    src = ctx.file.struct, dst = module_name))
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

            in_structfile = ctx.actions.declare_file(
                scope + module_name + ".ml"
            )
            ctx.actions.symlink(
                output = in_structfile, target_file = ctx.file.struct
            )

        cmi = module_name + ".cmi"
        action_output_cmi = ctx.actions.declare_file(scope + cmi)
        # print("cmi out: %s" % cmifile.path)
        # action_outputs.append(cmifile)
        # sig_inputs = [] # in_structfile]

        return None, None, action_output_cmi, ns, module_name, in_structfile

###############################
def _bootstrap_module(ctx):


    debug = False
    # if ctx.label.name in ["CamlinternalAtomic"]:
    #     debug = True

    # print("ns: '{ns}' for {m}".format(
    #     ns = ctx.attr._pack_ns[BuildSettingInfo].value,
    #     m = ctx.label))

    # (mode, tc, tool, tool_args, scope, ext) = config_tc(ctx)
    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    if tc.target_vm:
        ext = ".cmo"
    else:
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

    # ns = None

    stage = ctx.attr._stage[BuildSettingInfo].value
    scope     = "__stage{stage}/".format(stage = stage)

    (provider_output_mli, # None if no sig passed
     ## one of the following two returned:
     provider_output_cmi, # None if no sig passed
     action_output_cmi,   # None if sig passed
     ns,
     module_name,
     in_structfile) = handle_sig(ctx, scope, debug)

    if action_output_cmi:
        action_outputs.append(action_output_cmi)

    ## add provided cmi/mli files to action inputs depgraph
    sig_inputs = []
    if provider_output_cmi:
        sig_inputs.append(provider_output_cmi)
    if provider_output_mli:
        sig_inputs.append(provider_output_mli)

    out_cm_ = ctx.actions.declare_file(scope + module_name + ext)
    # sibling = new_cmi) # fname)
    if debug:
        print("OUT_CM_: %s" % out_cm_.path)
    action_outputs.append(out_cm_)
    # direct_linkargs.append(out_cm_)
    default_outputs.append(out_cm_)

    if not tc.target_vm:
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
    # print("NS_RESOLVER: %s" % ns_resolver)

    paths_direct = [out_cm_.dirname] # d.dirname for d in direct_linkargs]
    if ns_resolver:
        paths_direct.extend([f.dirname for f in ns_resolver_files])
    # print("RESOLVER PATHS: %s" % paths_direct)

    #########################
    args = ctx.actions.args()

    if tc.target_vm:
        args.add(tc.ocamlc)
    # args.add_all(tool_args)

    _options = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

    primitives = []
    if hasattr(ctx.attr, "primitives"):
        if ctx.attr.primitives:
            primitives.append(ctx.file.primitives)
            args.add("-use-prims", ctx.file.primitives.path)

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
        executable = tc.ocamlrun, # tool,
        arguments = [args],
        inputs    = inputs_depset,
        outputs   = action_outputs,
        tools = [tc.ocamlrun, tc.ocamlc],
        # tools = [tool] + tool_args,
        mnemonic = "CompileBootstrapModule",
        progress_message = "{mode} compiling {rule}: {ws}//{pkg}:{tgt}".format(
            mode = "vm" if tc.target_vm else "sys",
            rule=ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name,
        )
    )
    ################

    default_depset = depset(
        order = dsorder,
        # direct = default_outputs,
        transitive = bottomup_ns_files + [depset(direct=default_outputs)]
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

        _toolchain = attr.label(
            default = "//bzl/toolchain:tc"
        ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        ocamlc = attr.label(
            # cfg = ocamlc_out_transition,
            allow_single_file = True,
            default = "//bzl/toolchain:ocamlc"
        ),

        _mode       = attr.label(
            default = "//bzl/toolchain",
        ),

        mode       = attr.string(
            doc     = "Overrides global mode build setting.",
        ),

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
            ## FIXME: how to specify OcamlSignatureProvider OR FileProvider?
            #providers = [[OcamlSignatureProvider]],
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
    toolchains = ["//toolchain/type:bootstrap"],
)
