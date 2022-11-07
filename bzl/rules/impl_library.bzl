load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "BootInfo",
     "ModuleInfo",
     "DepsAggregator",
     "new_deps_aggregator",

     "OcamlNsResolverProvider",
     "OcamlLibraryMarker")
     # "OcamlNsMarker")

load(":impl_common.bzl", "dsorder", "module_sep", "resolver_suffix", "tmpdir")

load(":impl_ccdeps.bzl", "dump_CcInfo")

load(":options.bzl", "get_options")

load(":DEPS.bzl",
     "aggregate_deps",
     "merge_depsets",
     "COMPILE", "LINK", "COMPILE_LINK")

## Library targets do not produce anything, they just pass on their deps.

## NS Lib targets also do not directly produce anything, they just
## pass on their deps. The real work is done in the transition
## functions, which set the ConfigState that controls build actions of
## deps.

################
def build_packed_module(
    ctx, ordered_manifest, inputs_depset,
    linkargs_depset, paths_depset, cmi_depset, ccInfo_list):

    print("BUILDING PACKED MODULE: %s" % ctx.attr.pack_ns)

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    module_name = ctx.attr.pack_ns[:1].capitalize() + ctx.attr.pack_ns[1:]
    out_cm_ = ctx.actions.declare_file(tmpdir + module_name + ".cmo")
    out_cmi = ctx.actions.declare_file(tmpdir + module_name + ".cmi")

    args = ctx.actions.args()
    # args.add_all(tool_args)

    _options = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

    args.add("-pack")

    for dep in ordered_manifest:
        if dep.extension != "cmi":
            args.add(dep)

    if ctx.attr.stdlib:
        inputs = depset(
            transitive = [ctx.attr.stdlib[0][BootInfo].inputs,
                          inputs_depset]
        )
        args.add("-I", ctx.file.stdlib.dirname)
    else:
        inputs = inputs_depset

    args.add("-o", out_cm_)

    ctx.actions.run(
        # env = env,
        executable = tc.compiler[DefaultInfo].files_to_run,
        arguments = [args],
        inputs    = inputs,
        outputs   = [out_cm_, out_cmi],
        tools = [tc.compiler[DefaultInfo].files_to_run],
        # tools = [tool] + tool_args,
        mnemonic = "CompilePackedModule",
        progress_message = "{mode} packing {rule}: {ws}//{pkg}:{tgt}".format(
            mode = "TEST", # mode,
            rule=ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name,
        )
    )

    providers = []

    default_depset = depset(
        order = dsorder,
        # direct = default_outputs,
        transitive = [depset(direct=[out_cm_, out_cmi])]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )
    providers.append(defaultInfo)

    ocamlProvider = BootInfo(
        # files = ocamlProvider_files_depset,
        cmi      = cmi_depset,
        fileset  = defaultInfo, # fileset_depset,
        inputs   = depset(direct = [out_cm_, out_cmi],
                          transitive = [inputs_depset]),
        linkargs = linkargs_depset,
        paths    = paths_depset,
        # archive_manifests = archiveManifestDepset
    )
    providers.append(ocamlProvider)

    if ccInfo_list:
        ccInfo_merged = cc_common.merge_cc_infos(cc_infos = ccInfo_list)
        providers.append(ccInfo_merged)

    return providers

#################
def impl_library(ctx): # , mode, tool): # , tool_args):

    debug = False
    # print("**** NS_LIB {} ****************".format(ctx.label))

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []
    for dep in ctx.attr.manifest:
        manifest.append(dep[DefaultInfo].files)

    for dep in ctx.attr.manifest:
        depsets = aggregate_deps(ctx, dep, depsets, manifest)

    ################################
    ## merge BootInfo deps
    sigs_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "sigs")])

    cli_link_deps_depset = depset(
        order = dsorder,
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
        transitive = [merge_depsets(depsets, "paths")]
    )

    inputs_depset = depset(ctx.files.manifest)
    # for f in ctx.files.manifest:
    #     inputs_depset.append(f)

    # print("inputs: %s" % inputs_depset)
    # fail("x")

    ################################################################
    ##    ACTION
    ## archives share this impl but do not have attrib 'pack_ns'
    # if hasattr(ctx.attr, "pack_ns"):
    #     if ctx.attr.pack_ns:
    #         print("PACKING")
    #         return build_packed_module(
    #             ctx,
    #             ordered_manifest, inputs_depset,
    #             linkargs_depset, paths_depset, cmi_depset, ccInfo_list)
    #     else:
    ctx.actions.do_nothing(
        mnemonic = "Library",
        inputs = inputs_depset
    )

    #######################
    # print("INPUTS_DEPSET: %s" % inputs_depset)

    # print("the_ns_resolvers: %s" % the_ns_resolvers)

    #### PROVIDERS ####
    default_depset = depset(
        order = dsorder,
        # direct = normalized_ctx.files.manifest, # ns_resolver_module,
        # transitive = [depset(direct = the_ns_resolvers)]

        # direct = the_ns_resolvers + [ns_resolver_module] if ns_resolver_module else [],
        # transitive = [depset(ctx.files.manifest)]
        # transitive = [depset(normalized_ctx.files.manifest)]
        transitive = [inputs_depset]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
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
        # outputGroupInfo,
        bootProvider,
        OcamlLibraryMarker(marker = "OcamlLibraryMarker")
    ]

    return providers
