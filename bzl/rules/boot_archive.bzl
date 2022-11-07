load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "DepsAggregator",
     "new_deps_aggregator",

     "OcamlArchiveProvider",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsMarker",
     "OcamlSignatureMarker")

load(":options.bzl", "options")

load("impl_library.bzl", "impl_library")

load(":impl_common.bzl", "tmpdir", "dsorder")

load(":options.bzl", "NEGATION_OPTS")

load(":DEPS.bzl",
     "aggregate_deps",
     "merge_depsets",
     "COMPILE", "LINK", "COMPILE_LINK")

################################################################
def _manifest_out_transition_impl(settings, attr):
    # print("manifest_out_transition")

    # print("settings: %s" % settings)

    # for d in dir(attr):
    #     print("attr: %s" % d)

    # for m in attr.manifest:
    #     print("item: %s" % m)

    # if settings["//platforms/xtarget"] == "sys":

    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    manifest = [str(f.package) + "/" + str(f.name) for f in attr.manifest]
    manifest.append(attr.name)

    return {
            "//config:manifest": manifest
    }

manifest_out_transition = transition(
    implementation = _manifest_out_transition_impl,
    inputs = [
        "//config:manifest"
    ],
    outputs = [
        "//config:manifest"
    ]
)

###############################
def _impl_boot_archive(ctx):

    tc = ctx.toolchains["//toolchain/type:bootstrap"]
    if tc.target_host in ["boot", "dev", "vm"]:
        tool = tc.tool_runner
        ext = ".cma"
    else:
        tool = tc.compiler
        ext = ".cmxa"

    debug = False # True
    # if ctx.label.name == "Bare_structs":
    #     debug = True #False

    # env = {"PATH": get_sdkpath(ctx)}

    ################################################################
    ################  OUTPUTS: out_archive  ################
    ## same for plain and ns archives
    if ctx.attr._rule.startswith("ocaml_ns"):
        if ctx.attr.ns:
            archive_name = ctx.attr.ns ## normalize_module_name(ctx.attr.ns)
        else:
            archive_name = ctx.label.name ## normalize_module_name(ctx.label.name)
    else:
        archive_name = ctx.label.name ## normalize_module_name(ctx.label.name)

    if debug:
        print("archive_name: %s" % archive_name)

    action_outputs = []

    archive_filename = archive_name + ext
    out_archive = ctx.actions.declare_file(tmpdir + archive_filename)
    # paths_direct.append(archive_file.dirname)
    action_outputs.append(out_archive)

    if not tc.target_host:
        archive_a_filename = archive_name + ".a"
        archive_a_file = ctx.actions.declare_file(tmpdir + archive_a_filename)
        # paths_direct.append(archive_a_file.dirname)
        action_outputs.append(archive_a_file)

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []
    for dep in ctx.attr.manifest:
        manifest.append(dep[DefaultInfo].files)

    for dep in ctx.attr.manifest:
        depsets = aggregate_deps(ctx, dep, depsets, manifest)

    sigs_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "sigs")])

    cli_link_deps_depset = depset(
        order = dsorder,
        direct = [out_archive],
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
        direct = [out_archive.dirname],
        transitive = [merge_depsets(depsets, "paths")]
    )

    ###   CALL THE LIB IMPLEMENTATION
    # lib_providers = impl_library(ctx) #, mode, tool) # , tool_args)
    # FIXME: improve the return vals handling

    # libDefaultInfo = lib_providers[0]
    # print("libDefaultInfo: %s" % libDefaultInfo.files.to_list())

    # outputGroupInfo = lib_providers[1]

    # libBootInfo = lib_providers[1]
    # print("libBootInfo.inputs type: %s" % type(libBootInfo.inputs))
    # print("libBootInfo.linkargs: %s" % libBootInfo.linkargs)
    # print("libBootInfo.paths type: %s" % type(libBootInfo.paths))
    # print("libBootInfo.ns_resolver: %s" % libBootInfo.ns_resolver)

    # ppxAdjunctsProvider = lib_providers[2] ## FIXME: only as needed

    # _ = lib_providers[2] # OcamlLibraryMarker

    # if ctx.attr._rule.startswith("ocaml_ns"):
    #     nsMarker = lib_providers[5]  # OcamlNsMarker
    #     ccInfo  = lib_providers[6] if len(lib_providers) == 7 else False
    # else:
    # ccInfo  = lib_providers[4] if len(lib_providers) == 6 else False

    # if ctx.label.name == "tezos-legacy-store":
    #     print("LEGACY CC: %s" % ccInfo)
        # dump_ccdep(ctx, dep)

    ################################
    # if libBootInfo.ns_resolver == None:
    #     print("NO NSRESOLVER FROM NSLIB")
    #     fail("NO NSRESOLVER FROM NSLIB")
    # else:
    #     ns_resolver = libBootInfo.ns_resolver
    #     if debug:
    #         print("ARCH GOT NSRESOLVER FROM NSLIB")
    #         for f in libBootInfo.ns_resolver: # .files.to_list():
    #             print("nsrsolver: %s" % f)

    # paths_direct = []
    # paths_indirect = libBootInfo.paths

    # _options = get_options(ctx.attr._rule, ctx)

    # shared = False
    # if ctx.attr.shared:
    #     shared = ctx.attr.shared or "-shared" in _options
    #     if shared:
    #         if "-shared" in ctx.attr.opts:
    #             _options.remove("-shared") ## avoid dup

    if tc.target_host:
        ext = ".cma"
        # if shared:
        #     ext = ".cmxs"
        # else:
    else:
        ext = ".cmxa"

    #########################
    args = ctx.actions.args()

    if tc.target_host in ["boot", "vm"]:
        # if stage == bootstrap:
        args.add_all(["-use-prims", tc.primitives])

    args.add("-o", out_archive)

    args.add("-a")

    ## examples from mac make log:
    ## ocamlbytecomp.cma, ocamloptcomp.cma:  -nostdlib, -use-prims

    # if tc.target_host:
    #     args.add(tc.compiler)
    # args.add_all(tool_args)

    args.add_all(tc.linkopts)

    for arg in ctx.attr.opts:
        if arg not in NEGATION_OPTS:
            args.add(arg)

    # primitives = []
    # if hasattr(ctx.attr, "primitives"):
    #     if ctx.attr.primitives:
    #         primitives.append(ctx.file.primitives)
    #         args.add("-use-prims", ctx.file.primitives.path)

    ## Submodules can be listed in ctx.files.submodules in any order,
    ## so we need to put them in correct order on the command line.
    ## Order is encoded in their depsets, which were merged by
    ## impl_ns_library; the result contains the files of
    ## ctx.files.submodules in the correct order.
    ## submod[DefaultInfo].files won't work, it contains only one
    ## module BootInfo. linkargs contains the deptree we need,
    ## but it may contain additional modules, so we need to filter.

    # submod_arglist = [] # direct deps

    ## ns_archives have submodules, plain archives have modules
    manifest = ctx.files.manifest
    # or: manifest = libDefaultInfo.files.to_list()

    ## solve double-link problem:

    # if BootInfo in ns_resolver:
    #     ns_resolver_files = ns_resolver[BootInfo].inputs.to_list()
    # else:
    #     ns_resolver_files = []
    # print("ns_resolver_files: %s" % ns_resolver_files)

    # print("manifest: %s" % manifest)

    if ctx.attr.cc_deps:
        for (dep, linkmode) in ctx.attr.cc_deps.items():
            print("CCDEP: {dep}, mode: {mode}".format(
                dep = dep, mode = linkmode))
            for dep in dep.files.to_list():
                print("DEP: %s" % dep)
                if dep.extension == "so":
                    if linkmode in ["shared", "dynamic"]:
                        (bn, ext) = paths.split_extension(dep.basename)
                        # NB -dllib for shared libs, -cclib for static?
                        args.add("-dllib", "-l" + bn[3:])
                        args.add("-dllpath", dep.dirname)
                ## FIXME: .a is expected with cmx, in bc it means cclib
                elif dep.extension == "a":
                    if linkmode == "static":
                        # if mode in ["boot", "bc_bc", "bc_n"]:
                        if tc.target_host:
                            (bn, extn) = paths.split_extension(dep.basename)
                            # args.add(dep)
                            ## or:
                            args.add("-cclib", "l" + bn[3:])
                            args.add("-ccopt", "-L" + dep.dirname)
                else:
                    fail("cc_deps files must be .a, .so, or .dylib")


    # NB: ns lib linkargs not same as ns archive linkargs
    # the former contains resolver and submodules, which we add to the
    # cmd for building archive;
    # the latter excludes them (since they are in the archive)
    # NB also: ns_resolver only present if lib is ns
    # for dep in libBootInfo.linkargs.to_list():
    ## libDefaultInfo is the DefaultInfo provider of the underlying lib
    # for dep in libDefaultInfo.files.to_list():
    #     # print("linkarg: %s" % dep)
    #     if dep in manifest: # add direct deps to cmd line...
    #         submod_arglist.append(dep)
    #     # elif ctx.attr._rule.startswith("ocaml_ns"):
    #     #     if dep in ns_resolver_files:
    #     #         submod_arglist.append(dep)
    #     #     else: # should not happen!
    #     #         ## nslib linkargs should only contain what's needed to
    #     #         ## link and executable or build and archive.
    #     #         # linkargs_list.append(dep)
    #     #         fail("ns lib contains extra linkarg: %s" % dep)
    #     else:
    #         # linkargs should match direct deps list?
    #         fail("lib contains extra linkarg: %s" % dep)
    #         # submod_arglist.append(dep)

    # ordered_submodules_depset = depset(direct=submod_arglist)

    # only direct deps go on cmd line:
    # if libBootInfo.ns_resolver != None:
    #     for ds in libBootInfo.ns_resolver:
    #         for f in ds.files.to_list():
    #             # print("ns_resolver: %s" % f)
    #             if f.extension == "cmx":
    #                 args.add(f)

    ## cmi files

    # for cmi in libBootInfo.cmi.to_list():
    #     print("DEP CMI: %s" % cmi)

    linkargs_list = []
    # lbl_name = "tezos-lwt-result-stdlib.bare.structs"
    # if ctx.label.name == lbl_name:
    #     print("ns_name: %s" % nsMarker.ns_name)

    ## merge archive submanifests, to get list of all modules included
    ## in archives. use list to filter cmd line args
    includes = []
    # manifest_list = []
    # for dep in ctx.attr.manifest:
    #     if BootInfo in dep:
    #         if hasattr(dep[BootInfo], "archive_manifests"):
    #             manifest_list.append(dep[BootInfo].archive_manifests)
        # else sig?

    # merged_manifests = depset(transitive = manifest_list)
    # archive_filter_list = merged_manifests.to_list()
    # print("Merged manifests: %s" % archive_filter_list)

    # for dep in libBootInfo.linkargs.to_list():

        #FIXME: dep is not namespaced so we won't match ever:
        # if ctx.label.name == lbl_name:
        #     print("RULE: %s" % ctx.attr._rule)
        #     print("TESTING: %s" % dep.basename)
        # if ctx.attr._rule.startswith("ocaml_ns"):
            # if ctx.label.name == lbl_name:
                # print("NS PFX: %s" % nsMarker.ns_name + "__")
                # print("TEST1: %s" % dep.basename.startswith(nsMarker.ns_name + "__"))
                # print("TEST2: %s" % (dep.basename != nsMarker.ns_name + ".cmxa"))

            #  OcamlNsMarker just for topdown aggregates?

            # if dep.basename.startswith(nsMarker.ns_name):
            #     if (dep.basename != nsMarker.ns_name + ".cmxa") and (dep.basename != nsMarker.ns_name + ".cma"):
            #         if not dep.basename.startswith(nsMarker.ns_name + "__"):
            #             # if ctx.label.name == lbl_name:
            #             #     print("xxxx")
            #             linkargs_list.append(dep)
            #         # else:
            #         #     if ctx.label.name == lbl_name:
            #         #         print("OMIT1 %s" % dep)
            #     # else:
            #     #     if ctx.label.name == lbl_name:
            #     #         print("OMIT RESOLVER: %s" % dep)
            # else:

                # if ctx.label.name == lbl_name:
                #     print("APPEND: %s" % dep)
        #         linkargs_list.append(dep)
        # else:
        # if dep not in manifest:
        #     if dep not in archive_filter_list:
        #         linkargs_list.append(dep)
            # else:
            #     print("removing double link: %s" % dep)

    # for dep in libBootInfo.inputs.to_list():
    #     # print("inputs dep: %s" % dep)
    #     # print("ns_resolver: %s" % ns_resolver)
    #     if dep not in submod_arglist:
    #         if dep not in archive_filter_list:
    #             if dep.extension not in ["cmi"]:
    #                 linkargs_list.append(dep)
    #                 includes.append(dep.dirname)

        #     args.add(dep)
        # elif dep == ns_resolver:
        #     includes.append(dep.dirname)
        #     args.add(dep)

    # linkargs_depset = depset(
    #     direct = linkargs_list,
    # )
    # for linkarg in linkargs_depset.to_list():
    #     # native: archives cannot be passed with -a

    #     # bc: seems to be ok, BUT if something depends on a member of
    #     # the archive (but not on the archive), we get double-linking
    #     # workaround until I fully grok this: do not put archives
    #     # on the command line here.
    #     if linkarg.extension not in ["cmxa"]:
    #         includes.append(dep.path)
    #         args.add(linkarg)


    # for dep in ordered_submodules_depset.to_list():
    # for dep in libBootInfo.inputs.to_list():
        # # print("inputs dep: %s" % dep)
        # # print("ns_resolver: %s" % ns_resolver)
        # if dep in submod_arglist:
        #     if dep.extension == "so":
        #         if tc.linkmode in ["shared", "dynamic"]:
        #             (bn, ext) = paths.split_extension(dep.basename)
        #             # NB -dllib for shared libs, -cclib for static?
        #             args.add("-dllib", "l" + bn[3:])
        #             args.add("-ccopt", "-L" + dep.dirname)
        #     ## FIXME: .a is expected with cmx, in bc it means cclib
        #     elif dep.extension == "a":
        #         if tc.linkmode == "static":
        #             # if mode in ["boot", "bc_bc", "bc_n"]:
        #             if tc.target_host:
        #                 (bn, ext) = paths.split_extension(dep.basename)
        #                 # args.add(dep)
        #                 ## or:
        #                 args.add("-cclib", "l" + bn[3:])
        #                 args.add("-ccopt", "-L" + dep.dirname)
        #     else:
        #         includes.append(dep.dirname)
        #         args.add(dep)
        # elif dep == ns_resolver:
        #     includes.append(dep.dirname)
        #     args.add(dep)
        # elif dep not in archive_filter_list:
        #     linkargs_list.append(dep)
        # else:
        #     print("removing double link: %s" % dep)

    ## To get cli args in right order, we need then merged depset of
    ## all deps. Then we use the manifest to filter.

    filtering_depset = depset(
        direct = ctx.files.manifest, ## only .cmo/.cmx files
        transitive = [cli_link_deps_depset]
    )

    for dep in filtering_depset.to_list():
        if dep in manifest:
            args.add(dep)

    args.add_all(includes, before_each="-I", uniquify=True)

    inputs_depset = depset(
        direct = ctx.files.data if ctx.files.data else [],
        transitive = []
        + [
            sigs_depset,
            afiles_depset,
            archived_cmx_depset]
        # cli_link_deps_depset contains this archive, do not add to inputs
        + depsets.deps.cli_link_deps
        # + [libBootInfo.cmi]
    )

    # if ctx.attr._rule == "ocaml_ns_archive":
    #     mnemonic = "CompileOcamlNsArchive"
    # elif ctx.attr._rule == "ocaml_archive":
    mnemonic = "CompileOcamlArchive"
    # else:
    #     fail("Unexpected rule type for impl_archive: %s" % ctx.attr._rule)

    ################
    ctx.actions.run(
        # env = env,
        executable = tc.compiler[DefaultInfo].files_to_run,
        # executable = tc.tool_runner,
        arguments = [args],
        inputs = inputs_depset,
        outputs = action_outputs,
        tools = [tc.compiler[DefaultInfo].files_to_run],
        # tools = [tc.tool_runner, tc.compiler],
        # tools = [tool] + tool_args, # [tc.ocamlopt, tc.compiler],
        mnemonic = mnemonic,
        progress_message = "{mode} archiving {rule}: @{ws}//{pkg}:{tgt}".format(
            mode = tc.build_host + ">" + tc.target_host,
            rule = ctx.attr._rule,
            ws  = ctx.label.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name,
        )
    )

    ###################
    #### PROVIDERS ####
    ###################
    defaultDepset = depset(
        order  = dsorder,
        direct = [out_archive] # .cmxa
    )
    newDefaultInfo = DefaultInfo(files = defaultDepset)

    # linkargs_depsets = depset(
    #     ## indirect deps (excluding direct deps, i.e. submodules & resolver)
    #     # direct = linkargs_list,
    #     transitive = [libBootInfo.linkargs]
    # )

    # linkargs_depset = depset()
    # #     direct     = linkargs_list
    # #     # transitive = [libBootInfo.linkargs]
    # #     # transitive = [linkargs_depsets]
    # # )

    # paths_depset  = depset(
    #     order = dsorder,
    #     direct = paths_direct,
    #     transitive = [libBootInfo.paths]
    # )

    # ## IMPORTANT: archives must deliver both the archive file and cmi
    # ## files for all archive members!
    # closure_depset = depset(
    #     # direct     = action_outputs, # + ns_resolver,
    #     # transitive = [libBootInfo.inputs]
    #     direct=action_outputs,
    #     transitive = [libBootInfo.cmi]
    # )

    # ocamlProvider = BootInfo(
    #     files   = libBootInfo.files,
    #     fileset = libBootInfo.fileset,
    #     cmi     = libBootInfo.cmi,
    #     inputs  = closure_depset,
    #     linkargs = linkargs_depset,
    #     paths    = paths_depset,
    # )

    # manifest_depset = depset(
    #     transitive = [linkargs_depset, libBootInfo.files]
    # )

    ocamlArchiveProvider = OcamlArchiveProvider(
        # manifest = manifest_depset
    )

    bootProvider = BootInfo(
        sigs     = sigs_depset,
        cli_link_deps = cli_link_deps_depset,
        afiles   = afiles_depset,
        archived_cmx  = archived_cmx_depset,
        paths    = paths_depset,

        # ofiles   = ofiles_depset,
        # archives = archives_depset,
        # astructs = astructs_depset,
    )

    providers = [
        newDefaultInfo,
        # libBootInfo,
        bootProvider,
        ocamlArchiveProvider
    ]

    # FIXME: only if needed
    # if has ppx codeps:
    # providers.append(ppxAdjunctsProvider)
    # ppx_codeps_depset = ppxAdjunctsProvider.ppx_codeps

    # outputGroupInfo = OutputGroupInfo(
    #     fileset  = defaultDepset,
    #     cmi      = libBootInfo.cmi,
    #     linkargs = linkargs_depset,
    #     manifest = manifest_depset,
    #     closure = closure_depset,
    #     # closure = depset(direct=action_outputs),
    #     # all = depset(transitive=[
    #     #     closure_depset,
    #     #     # ppx_codeps_depset,
    #     #     # cclib_files_depset,
    #     # ])
    # )
    # providers.append(outputGroupInfo)

    # if ccInfo:
    #     providers.append(ccInfo)

    # we may be called by ocaml_ns_archive, so:
    # if ctx.attr._rule.startswith("ocaml_ns"):
    #     providers.append(OcamlNsMarker(
    #         marker = "OcamlNsMarker",
    #         ns_name     = nsMarker.ns_name
    #     ))

    return providers

#####################
boot_archive = rule(
    implementation = _impl_boot_archive,
    doc = """Generates an OCaml archive file using the bootstrap toolchain.""",
    attrs = dict(
        # options("ocaml"),

        # _toolchain = attr.label(
        #     default = "//bzl/toolchain:tc"
        # ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        primitives = attr.label(
            allow_single_file = True,
        ),

        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),

        archive_name = attr.string(
            doc = "Name of generated archive file, without extension. Overrides `name` attribute."
        ),

        ## CONFIGURABLE DEFAULTS
        # _linkall     = attr.label(default = "@ocaml//archive/linkall"),
        # # _threads     = attr.label(default = "@ocaml//archive/threads"),
        # _warnings  = attr.label(default = "@ocaml//archive:warnings"),
        #### end options ####

        # shared = attr.bool(
        #     doc = "True: build a shared lib (.cmxs)",
        #     default = False
        # ),

        # standalone = attr.bool(
        #     doc = "True: link total depgraph. False: link only direct deps.  Default False.",
        #     default = False
        # ),

        manifest = attr.label_list(
            doc = "List of component modules.",
            providers = [[OcamlArchiveProvider],
                         [OcamlImportMarker],
                         [OcamlLibraryMarker],
                         [ModuleInfo],
                         [OcamlNsMarker],
                         [OcamlSignatureMarker],
                         [CcInfo]],
            # cfg = manifest_out_transition
        ),

        data = attr.label_list(
            doc = "Data file deps",
            allow_files = True,
        ),

        ## FIXME: do archive rules need to support cc_deps?
        ## They should be attached to members of the archive.
        ## OTOH, if the ocaml wrapper on a cc_dep consists of multiple modules
        ## it makes sense to aggregate them into an archive or library
        ## and attach the cc_dep to the latter.
        ## mklib too attaches to archive
        cc_deps = attr.label_keyed_string_dict(
            doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
            """,
            providers = [[CcInfo]]
        ),
        cc_linkopts = attr.string_list(
            doc = "List of C/C++ link options. E.g. `[\"-lstd++\", \"lunix\"]`.",
        ),
        # cc_linkall = attr.label_list( ## FIXME: not needed
        #     doc     = "True: use `-whole-archive` (GCC toolchain) or `-force_load` (Clang toolchain). Deps in this attribute must also be listed in cc_deps.",
        #     providers = [CcInfo],
        # ),
        _cc_linkmode = attr.label( ## FIXME: not needed?
            doc     = "Override platform-dependent link mode (static or dynamic). Configurable default is platform-dependent: static on Linux, dynamic on MacOS.",
            # default is os-dependent, but settable to static or dynamic
        ),
        # _mode = attr.label(
        #     default = "@ocaml//mode"
        # ),
        # _projroot = attr.label(
        #     default = "@ocaml//:projroot"
        # ),
        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath")
        # ),
        _rule = attr.string( default = "boot_archive" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    ## this is not an ns archive, and it does not use ns ConfigState,
    ## but we need to reset the ConfigState anyway, so the deps are
    ## not affected if this is a dependency of an ns aggregator.
    # cfg     = nsarchive_in_transition,
    # cfg = compile_mode_in_transition,

    # bug in custom provider initializers:
    # Illegal argument: element in 'provides' is of unexpected type.
    # Should be list of providers, but got item of type tuple.
    provides = [OcamlArchiveProvider, BootInfo],

    executable = False,
    fragments = ["platform", "cpp"],
    host_fragments = ["platform",  "cpp"],
    incompatible_use_toolchain_transition = True,
    toolchains = ["//toolchain/type:bootstrap",
                  # "//toolchain/type:profile",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
