load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "OcamlProvider",
     "OcamlNsResolverProvider",
     "OcamlLibraryMarker",
     "OcamlModuleMarker")
     # "OcamlNsMarker")

load(":impl_common.bzl", "dsorder", "module_sep", "resolver_suffix")

load(":impl_ccdeps.bzl", "dump_CcInfo")

load("//bzl:functions.bzl", "config_tc")

load(":options.bzl", "get_options")

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

    (mode, tc, tool, tool_args, scope, ext) = config_tc(ctx)

    module_name = ctx.attr.pack_ns[:1].capitalize() + ctx.attr.pack_ns[1:]

    out_cm_ = ctx.actions.declare_file(scope + module_name + ".cmo")

    out_cmi = ctx.actions.declare_file(scope + module_name + ".cmi")

    args = ctx.actions.args()
    args.add_all(tool_args)

    _options = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

    args.add("-pack")

    for dep in ordered_manifest:
        if dep.extension != "cmi":
            args.add(dep)

    if ctx.attr.stdlib:
        inputs = depset(
            transitive = [ctx.attr.stdlib[0][OcamlProvider].inputs,
                          inputs_depset]
        )
        args.add("-I", ctx.file.stdlib.dirname)
    else:
        inputs = inputs_depset

    args.add("-o", out_cm_)

    ctx.actions.run(
        # env = env,
        executable = tool,
        arguments = [args],
        inputs    = inputs,
        outputs   = [out_cm_, out_cmi],
        tools = [tool] + tool_args,
        mnemonic = "CompilePackedModule",
        progress_message = "{mode} packing {rule}: {ws}//{pkg}:{tgt}".format(
            mode = mode,
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

    providers.append(OcamlModuleMarker(marker="OcamlModule"))

    ocamlProvider = OcamlProvider(
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

    ns_resolver_depset = None
    ns_resolver_module = None
    ns_resolver = []
    ns_resolver_files = []
    the_ns_resolvers = []

    ################
    ## FIXME: does lib need to handle adjunct deps? they're carried by
    ## modules
    indirect_adjunct_depsets      = []
    indirect_adjunct_path_depsets = []

    ################
    paths_direct   = []
    # resolver_depsets_list = []

    #######################
    # direct_deps_attr = None
    # if ctx.attr._rule in ["bootstrap_archive", "bootstrap_library"]:
    #     direct_deps_files = ctx.files.manifest
    #     direct_deps_attr = ctx.attr.manifest
    # else:
    #     fail("impl_library called by non-aggregator: %s" % ctx.attr._rule)

    ## FIXME: manifest list is in the order set by the
    ## submodule/modules attribute; they must be put in
    ## dependency-order.

    ## FIXME: don't need this? we get paths depset for each dep below
    for f in ctx.files.manifest:
        paths_direct.append(f.dirname)

    #### INDIRECT DEPS first ####
    # these are "indirect" from the perspective of the consumer
    indirect_fileset_depsets = []
    indirect_cmi_depsets = []
    indirect_inputs_depsets = []
    indirect_linkargs_depsets = []
    indirect_paths_depsets = []

    ccInfo_list = []

    for dep in ctx.attr.manifest:

        if OcamlProvider in dep: # should always be True
            # print("LBL: %s" % ctx.label)
            # print("OcamlProv: %s" % dep[OcamlProvider])
            indirect_fileset_depsets.append(dep[OcamlProvider].fileset)

            # if hasattr(dep[OcamlProvider], "cmi"):
            indirect_cmi_depsets.append(dep[OcamlProvider].cmi)
            # else:
            #     print("NO CMI: %s" % dep)

            # linkargs: what goes on cmd line to build archive or
            # executable.

            # FIXME: __excluding__ sibling modules! Why?
            # because even if we put only indirect deps in linkargs,
            # the head (direct) dep could still appear anywhere in the
            # dep closure; in particular, we may have sibling deps, in
            # which case omitting the head dep for linkargs would do
            # us no good. So we need to filter to remove ALL
            # (sub)modules from linkargs.

            # if linkarg not in direct_module_deps_files:
            indirect_linkargs_depsets.append(dep[OcamlProvider].linkargs)

            ## inputs == closure (all deps)
            indirect_inputs_depsets.append(dep[OcamlProvider].inputs)

            indirect_paths_depsets.append(dep[OcamlProvider].paths)

        indirect_linkargs_depsets.append(dep[DefaultInfo].files)

        if CcInfo in dep:
            ## we do not need to do anything with ccdeps here,
            ## just pass them on in a provider
            # if ctx.label.name == "tezos-legacy-store":
            #     dump_CcInfo(ctx, dep)
            ccInfo_list.append(dep[CcInfo])

    ## end: for dep in ctx.attr.manifest

    # print("indirect_inputs_depsets: %s" % indirect_inputs_depsets)

    cmi_depset = depset(
        transitive = indirect_cmi_depsets
    )

    inputs_depset = depset(
        order = dsorder,
        ## FIXME: no need for direct manifest, already in indirect_inputs_depsets?
        direct = ctx.files.manifest,
        transitive = ([ns_resolver_depset] if ns_resolver_depset else [])
        + indirect_inputs_depsets
        + indirect_cmi_depsets
        # + [depset(ctx.files.manifest)]
    )

    ## use inputs closure to put manifest deps in dependency order
    ordered_manifest = []
    for dep in inputs_depset.to_list():
        # print("input dep: %s" % dep)
        if dep in ctx.files.manifest:
            ordered_manifest.append(dep)

    # print("ORDERED manifest: %s" % ordered_manifest)

    ## To put direct deps in dep-order, we need to merge the linkargs
    ## deps and iterate over them:
    # new_linkargs = []

    linkargs_depset = depset(
        order = dsorder,
        ## direct = ns_resolver_files,
        transitive = indirect_linkargs_depsets
        # transitive = ([ns_resolver_depset] if ns_resolver_depset else []) + indirect_linkargs_depsets
    )
    # for dep in inputs_depset.to_list():
    #     if dep in ctx.files.manifest:
    #         new_linkargs.append(dep)

    ## FIXME: new_linkargs should be same as ordered_manifest

    paths_depset  = depset(
        order = dsorder,
        direct = paths_direct,
        transitive = indirect_paths_depsets
    )

    ################################################################
    ##    ACTION
    ## archives share this impl but do not have attrib 'pack_ns'
    if hasattr(ctx.attr, "pack_ns"):
        if ctx.attr.pack_ns:
            print("PACKING")
            return build_packed_module(
                ctx, ordered_manifest, inputs_depset,
                linkargs_depset, paths_depset, cmi_depset, ccInfo_list)
        else:
            ctx.actions.do_nothing(
                mnemonic = "NS_LIB",
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

        direct = the_ns_resolvers + [ns_resolver_module] if ns_resolver_module else [],
        # transitive = [depset(ctx.files.manifest)]
        # transitive = [depset(normalized_ctx.files.manifest)]
        transitive = [depset(ordered_manifest)]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )

    closure_depset = depset(
        order = dsorder,
        ## direct = ns_resolver_files,
        transitive = ([ns_resolver_depset] if ns_resolver_depset else []) + [inputs_depset]
        # + indirect_inputs_depsets
    )

    fileset_depset = depset()
    #     transitive=([ns_resolver_depset] if ns_resolver_depset else []) + indirect_fileset_depsets
    # )

    # print("new_linkargs: %s" % new_linkargs)
    ## FIXME: new_linkargs or ordered_manifest?
    ocamlProvider = OcamlProvider(
        files   = default_depset, # depset(direct=new_linkargs),
        fileset = fileset_depset,
        cmi     = cmi_depset,
        inputs   = closure_depset,
        linkargs = linkargs_depset,
        paths    = paths_depset,
        ns_resolver = ns_resolver,
    )
    # print("ocamlProvider: %s" % ocamlProvider)

    outputGroupInfo = OutputGroupInfo(
        resolver = ns_resolver_files,
        fileset  = fileset_depset,
        cmi      = cmi_depset,
        manifest = default_depset,
        # cc = ... extract from CcInfo?
        all = depset(
            order = dsorder,
            transitive=[
                closure_depset,
            ]
        )
    )

    providers = [
        defaultInfo,
        outputGroupInfo,
        ocamlProvider,
        OcamlLibraryMarker(marker = "OcamlLibraryMarker")
    ]

    # providers.append(
    # )

    # if ctx.attr._rule.startswith("ocaml_ns"):
    #     providers.append(
    #         OcamlNsMarker(
    #             marker = "OcamlNsMarker",
    #             ns_name = ns_name if ns_resolver else ""
    #         ),
    #     )

    if ccInfo_list:
        ccInfo_merged = cc_common.merge_cc_infos(cc_infos = ccInfo_list)
        providers.append(ccInfo_merged)

    return providers
