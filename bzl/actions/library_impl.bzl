load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "new_deps_aggregator",
     "StdLibMarker",
     "StdlibLibMarker")

load("//bzl/rules/common:impl_common.bzl", "dsorder")

load("//bzl/rules/common:DEPS.bzl",
     "aggregate_deps",
     "merge_depsets")

load("//bzl/rules/common:impl_ccdeps.bzl", "dump_CcInfo", "ccinfo_to_string")

## Library targets do not produce anything, they just merge their deps
## and pass them on.

######################
def library_impl(ctx):

    debug = False
    debug_ccdeps = False

    # print("**** NS_LIB {} ****************".format(ctx.label))

    # tc = ctx.exec_groups["boot"].toolchains["//toolchain/type:ocaml"]
    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []
    for dep in ctx.attr.manifest:
        manifest.append(dep[DefaultInfo].files)

    for dep in ctx.attr.manifest:
        depsets = aggregate_deps(ctx, dep, depsets, manifest)

    if hasattr(ctx.attr, "cc_deps"):
        for dep in ctx.attr.cc_deps:
            depsets = aggregate_deps(ctx, dep, depsets, manifest)

    ################################
    ## merge BootInfo deps
    sigs_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "sigs")])

    structs_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "structs")])

    cli_link_deps_depset = depset(
        order = dsorder,
        transitive = [merge_depsets(depsets, "cli_link_deps")]
    )

    ofiles_depset  = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "ofiles")]
    )

    afiles_depset  = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "afiles")]
    )

    archived_cmx_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "archived_cmx")]
    )

    ccInfo_provider = cc_common.merge_cc_infos(
        cc_infos = depsets.ccinfos
            # cc_infos = cc_deps_primary + cc_deps_secondary
    )

    paths_depset  = depset(
        order = dsorder,
        transitive = [merge_depsets(depsets, "paths")]
    )

    inputs_depset = depset(
        ctx.files.manifest,
        # transitive = [cli_link_deps_depset]
    )

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
        transitive = [inputs_depset]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )

    bootProvider = BootInfo(
        sigs     = sigs_depset,
        structs  = structs_depset,
        cli_link_deps = cli_link_deps_depset,
        ofiles   = ofiles_depset,
        afiles   = afiles_depset,
        archived_cmx  = archived_cmx_depset,
        paths    = paths_depset,
    )

    if debug_ccdeps:
        dump_CcInfo(ctx, ccInfo_provider)
        print("x: %s" % ccinfo_to_string(ctx, ccInfo_provider))
        print("Module provides: %s" % ccInfo_provider)

    providers = [
        defaultInfo,
        bootProvider,
        ccInfo_provider,
    ]

    if ctx.attr._rule == "stdlib_library":
        providers.append(StdlibLibMarker())

    if ctx.attr._rule == "compiler_library":
        providers.append(StdLibMarker())

    return providers
