load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "BootInfo", "ModuleInfo",
     "new_deps_aggregator", "OcamlSignatureProvider")

load("//bzl:functions.bzl", "get_module_name")
load("//bzl/rules/common:DEPS.bzl", "aggregate_deps", "merge_depsets")
load("//bzl/rules/common:impl_common.bzl", "dsorder")
load("//bzl/rules/common:options.bzl", "get_options")

#####################
def module_impl(ctx, module_name):

    basename = ctx.label.name
    from_name = basename[:1].capitalize() + basename[1:]

    debug = False
    # if ctx.label.name in ["Stdlib"]:
    #     print("this: %s" % ctx.label) #.package + "/" + ctx.label.name)
    #     print("manifest: %s" % ctx.attr._manifest[BuildSettingInfo].value)
    #     debug = True
        # fail("x")

    # tc = ctx.exec_groups[ctx.attr._stage].toolchains[
    #     "//toolchain/type:{}".format(ctx.attr._stage)
    # ]
    # tc = ctx.toolchains["//toolchain/type:boot"]
    # print("tc target_host: %s" % tc.target_host)

    stage = ctx.attr._stage[BuildSettingInfo].value
    # print("module _stage: %s" % stage)

    workdir = "_{}/".format(stage)

    tc = None
    if stage == "boot":
        tc = ctx.exec_groups["boot"].toolchains[
            "//boot/toolchain/type:boot"]
    elif stage == "baseline":
        tc = ctx.exec_groups["baseline"].toolchains[
            "//boot/toolchain/type:baseline"]
    elif stage == "dev":
        tc = ctx.exec_groups["dev"].toolchains[
            "//boot/toolchain/type:baseline"]
    else:
        print("UNHANDLED STAGE: %s" % stage)
        tc = ctx.exec_groups["boot"].toolchains[
            "//boot/toolchain/type:boot"]

    if tc.target_host in ["vm"]:
        ext = ".cmo"
    else:
        ext = ".cmx"

    ext = ".cmo" # for now

    ################################################################
    ################  OUTPUTS  ################

    pack_ns = False
    if hasattr(ctx.attr, "_pack_ns"):
        if ctx.attr._pack_ns:
            if ctx.attr._pack_ns[BuildSettingInfo].value:
                pack_ns = ctx.attr._pack_ns[BuildSettingInfo].value
                # print("GOT PACK NS: %s" % pack_ns)

    ################
    includes   = []
    # default_outputs    = [] # just the cmx/cmo files, for efaultInfo
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

    mlifile = None
    cmifile = None
    sig_src = None

    ## get_module_name decides if this module is in a namespace
    ## and if so adds ns prefix
    # (from_name, ns, module_name) = get_module_name(ctx, ctx.file.struct)
    # print("module_name: %s" % module_name)
    # print("ns: %s" % ns)

    sig_inputs = []
    if ctx.attr.sig:
        if ctx.file.sig.is_source:
            # need to symlink .mli, to match symlink of .ml
            sig_src = ctx.actions.declare_file(
                workdir + module_name + ".mli"
            )
            sig_inputs.append(sig_src)
            ctx.actions.symlink(output = sig_src,
                                target_file = ctx.file.sig)

            action_output_cmi = ctx.actions.declare_file(workdir + module_name + ".cmi")
            action_outputs.append(action_output_cmi)
            provider_output_cmi = action_output_cmi
            mli_dir = None
        elif OcamlSignatureProvider in ctx.attr.sig:
            sigProvider = ctx.attr.sig[OcamlSignatureProvider]
            provider_output_cmi = sigProvider.cmi
            provider_output_mli = sigProvider.mli
            sig_inputs.append(provider_output_cmi)
            sig_inputs.append(provider_output_mli)
            mli_dir = paths.dirname(provider_output_mli.short_path)
        else:
            fail("ctx.file.sig without OcamlSignatureProvider")

    else: ## no sig, compiler will generate .cmi
        action_output_cmi = ctx.actions.declare_file(workdir + module_name + ".cmi")
        action_outputs.append(action_output_cmi)
        provider_output_cmi = action_output_cmi
        mli_dir = None

    ## struct: put in same dir as mli/cmi, rename if namespaced
    if from_name == module_name:  ## not namespaced
        # if ctx.label.name == "CamlinternalFormatBasics":
            # print("NOT NAMESPACED")
            # print("cmi is_source? %s" % provider_output_cmi.is_source)
        if ctx.file.struct.is_source:
            # structfile in src dir, make sure in same dir as sig
            if ctx.file.sig:
                if ctx.file.sig.is_source:
                    in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                else: # sig file is compiled .cmo
                    in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
            else: # no sig
                in_structfile = ctx.file.struct
        else: # structfile is generated, e.g. by ocamllex or a genrule.
            # make sure it's in same dir as mli/cmi IF we have ctx.file.sig
            if ctx.file.sig:
                if paths.dirname(ctx.file.struct.short_path) != mli_dir:
                    in_structfile = ctx.actions.declare_file(
                        workdir + module_name + ".ml") # ctx.file.struct.basename)
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
        in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
        ctx.actions.symlink(
            output = in_structfile, target_file = ctx.file.struct
        )

    # if ctx.label.name == "CamlinternalFormatBasics":
    #     fail("X")

    out_cm_ = ctx.actions.declare_file(workdir + module_name + ext)
    # sibling = new_cmi) # fname)
    if debug:
        print("OUT_CM_: %s" % out_cm_.path)
    action_outputs.append(out_cm_)
    # direct_linkargs.append(out_cm_)
    # default_outputs.append(out_cm_)

    if not tc.target_host:
        # if not ctx.attr._rule.startswith("bootstrap"):
        out_o = ctx.actions.declare_file(workdir + module_name + ".o",
                                         sibling = out_cm_)
        action_outputs.append(out_o)
        # direct_linkargs.append(out_o)

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    # if ctx.attr._manifest[BuildSettingInfo].value:
    #     manifest = ctx.attr._manifest[BuildSettingInfo].value
    # else:
    manifest = []

    # if ctx.label.name == "Stdlib":
    #     print("Stdlib manifest: %s" % manifest)
        # fail("X")

    if ctx.attr.sig: #FIXME
        if not ctx.file.sig.is_source:
            depsets = aggregate_deps(ctx, ctx.attr.sig, depsets, manifest)
        else:
            depsets.deps.mli.append(ctx.file.sig)

    for dep in ctx.attr.deps:
        depsets = aggregate_deps(ctx, dep, depsets, manifest)
        ## Now what if this module is to be archived, and this dep is
        ## a sibling submodule? If it is a sibling it goes in
        ## archived_cmx, or if it is a cmo we drop it since it will be
        ## archived. If it is not a sibling it goes in cli_link_deps.

    ## The problem is we do not know where whether this module is to
    ## be archived. It is the boot_archive rule that must decide how
    ## to distribute its deps. Which means we have no way of knowing
    ## if this module should go in cli_link_deps.

    ## So we do not include this module in its own BootInfo, only in
    ## DefaultInfo. Clients decide what to do with it. An archive will
    ## put it but not its cli_link_deps on the archive cmd line. An
    ## executable will put it and its cli_link_deps on the cmd line.

    ## An archive must also filter this module's cli_link_deps to
    ## remove sibling submodules that it archives beside this module.

    ## So this module should put the cli_link_deps of all of its deps
    ## into its own BootInfo.cli_link_deps, and leave it to client
    ## archives and execs to sort them out.

    ## And since clients filter cli_link_deps, we can add this module
    ## to its own BootInfo.cli_link_deps.

    ## It would be better to avoid filtering, but that does not seem
    ## possible, since a sibling dependency could be indirect. The
    ## only way to avoid filtering would be to mark sibling deps in
    ## some way.

    ## We could put a transition on the archive rule and have it
    ## record its manifest in the configuration. Then each module
    ## could check the manifest to decide if it is being archived.

    # if ctx.label.name == "Stdlib":
    #     print("depsets: %s" % depsets)
    #     fail("x")

    ## build depsets here, use for OcamlProvider and OutputGroupInfo
    sigs_depset = depset(
        order=dsorder,
        direct = [provider_output_cmi],
        transitive = [merge_depsets(depsets, "sigs")])

    cli_link_deps_depset = depset(
        order = dsorder,
        direct = [out_cm_],
        transitive = [merge_depsets(depsets, "cli_link_deps")]
    )

    afiles_depset  = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "afiles")]
    )

    archived_cmx_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "archived_cmx")]
    )

    paths_depset  = depset(
        order = dsorder,
        direct = [out_cm_.dirname],
        transitive = [merge_depsets(depsets, "paths")]
    )

    ################################################################
    ################
    # indirect_ppx_codep_depsets      = []
    # indirect_ppx_codep_path_depsets = []
    indirect_cc_deps  = {}

    #########################
    args = ctx.actions.args()

    if hasattr(ctx.attr, "_stdlib_resolver"):
        includes.append(ctx.attr._stdlib_resolver[ModuleInfo].sig.dirname)
        if tc.target_host in ["boot", "vm"]:
            # if stage == bootstrap:
            args.add_all(["-use-prims", tc.primitives])
    else:
        args.add("-nopervasives")

    if hasattr(ctx.attr, "_opts"):
        args.add_all(ctx.attr._opts)

    if not ctx.attr.nocopts:
        args.add_all(tc.copts)

    args.add_all(tc.warnings[BuildSettingInfo].value)

    for w in ctx.attr.warnings:
        args.add_all(["-w",
                      w if w.startswith("-")
                      else "-" + w])

    _options = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

    ################ Direct Deps ################

    includes.extend(paths_depset.to_list())

    stdlib_resolver = []
    if hasattr(ctx.attr, "_stdlib_resolver"):
        stdlib_resolver.append(ctx.attr._stdlib_resolver[ModuleInfo].sig)
        stdlib_resolver.append(ctx.attr._stdlib_resolver[ModuleInfo].struct)

    inputs_depset = depset(
        order = dsorder,
        direct = []
        + sig_inputs
        + [in_structfile]
        + depsets.deps.mli
        + stdlib_resolver
        ,
        transitive = []
        + [merge_depsets(depsets, "sigs"),
           merge_depsets(depsets, "cli_link_deps")]
        + [archived_cmx_depset]
        # + ns_deps
        # + bottomup_ns_inputs
    )
    # if ctx.label.name == "Misc":
    #     print("inputs_depset: %s" % inputs_depset)

    if pack_ns:
        args.add("-for-pack", pack_ns)

    if sig_src:
        includes.append(sig_src.dirname)

    args.add_all(includes, before_each="-I", uniquify = True)

    args.add("-c")

    if sig_src:
        args.add(sig_src)
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

    #############################################
    ################  PROVIDERS  ################

    default_depset = depset(
        order = dsorder,
        direct = [out_cm_], ## default_outputs,
        # transitive = [depset(direct=default_outputs)]
        # transitive = bottomup_ns_files + [depset(direct=default_outputs)]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )

    moduleInfo_depset = depset([provider_output_cmi, out_cm_])
    moduleInfo = ModuleInfo(
        sig    = provider_output_cmi,
        struct = out_cm_
    )

    bootProvider = BootInfo(
        sigs     = sigs_depset,
        cli_link_deps = cli_link_deps_depset,
        afiles   = afiles_depset,
        archived_cmx  = archived_cmx_depset,
        paths    = paths_depset,
    )

    providers = [
        defaultInfo,
        bootProvider,
        moduleInfo
    ]

    ################
    outputGroupInfo = OutputGroupInfo(
        cmi        = depset(direct=[provider_output_cmi]),
        module     = moduleInfo_depset
    )
    providers.append(outputGroupInfo)

    return providers
