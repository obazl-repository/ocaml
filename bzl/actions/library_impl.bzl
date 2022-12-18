load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "new_deps_aggregator",
     "OcamlLibraryMarker")

load("//bzl/rules/common:impl_common.bzl", "dsorder")

load("//bzl/rules/common:DEPS.bzl",
     "aggregate_deps",
     "merge_depsets")

## Library targets do not produce anything, they just merge their deps
## and pass them on.

######################
def library_impl(ctx):

    debug = False
    # print("**** NS_LIB {} ****************".format(ctx.label))

    # tc = ctx.exec_groups["boot"].toolchains["//toolchain/type:ocaml"]
    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    # (target_executor, target_emitter,
    #  config_executor, config_emitter,
    #  workdir) = get_workdir(ctx, tc)
    # if target_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

    # if executor == "vm":
    #     ext = ".cmo"
    # else:
    #     ext = ".cmx"

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []
    for dep in ctx.attr.manifest:
        manifest.append(dep[DefaultInfo].files)

    for dep in ctx.attr.manifest:
        # if ctx.label == Label("@//bytecomp:ocamlcommon"):
        #     print("dep[ModuleInfo]: %s" % dep[ModuleInfo])
        depsets = aggregate_deps(ctx, dep, depsets, manifest)
    # if ctx.label == Label("@//bytecomp:ocamlcommon"):
    #     fail()

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

    paths_depset  = depset(
        order = dsorder,
        transitive = [merge_depsets(depsets, "paths")]
    )

    # if ctx.label == Label("@//typing:ocamlcommon"):
    #     print("sigs: %s" % sigs_depset)
    #     print("cli_link_deps: %s" % cli_link_deps_depset)
    #     # fail()

    inputs_depset = depset(
        ctx.files.manifest,
        # transitive = [cli_link_deps_depset]
    )

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
        structs  = structs_depset,
        cli_link_deps = cli_link_deps_depset,
        ofiles   = ofiles_depset,
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
