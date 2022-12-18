load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load(":BUILD.bzl", "progress_msg", "get_build_executor")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "new_deps_aggregator",
     "OcamlArchiveProvider")

load("//bzl/rules/common:impl_common.bzl", "dsorder")

load("//bzl/rules/common:options.bzl", "get_options")

load("//bzl/rules/common:DEPS.bzl",
     "aggregate_deps",
     "merge_depsets")

###############################
def archive_impl(ctx):
    debug = False

    # tc = ctx.exec_groups["boot"].toolchains["//toolchain/type:ocaml"]
    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    # (target_executor, # x
    #  target_emitter,  # x
    #  config_executor, # x
    #  config_emitter,  # x
    #  workdir) = get_workdir(ctx, tc)

    # (ocamlrun, # x
    #  executable, # in actions.run
    #  build_executor, # x
    #  target_executor # x
    #  ) = configure_action(ctx, tc)

    #########################
    args = ctx.actions.args()

    toolarg = tc.tool_arg
    if toolarg:
        args.add(toolarg.path)
        toolarg_input = [toolarg]
    else:
        toolarg_input = []

    # executable = None
    # if tc.dev:
    #     ocamlrun = None
    #     effective_compiler = tc.compiler
    # else:
    #     ocamlrun = tc.compiler[DefaultInfo].default_runfiles.files.to_list()[0]

    #     effective_compiler = tc.compiler[DefaultInfo].files_to_run.executable

    # if tc.dev:
    #     build_executor = "opt"
    # elif (target_executor == "unspecified"):
    #     if (config_executor == "sys"):
    #         if config_emitter == "sys":
    #             # ss built from ocamlopt.byte
    #             build_executor = "vm"
    #         else:
    #             # sv built from ocamlopt.opt
    #             build_executor = "sys"
    #     else:
    #         build_executor = "vm"
    # elif target_executor in ["boot", "vm"]:
    #     build_executor = "vm"
    # elif (target_executor == "sys" and target_emitter == "sys"):
    #     ## ss always built by vs (ocamlopt.byte)
    #     build_executor = "vm"
    # elif (target_executor == "sys" and target_emitter == "vm"):
    #     ## sv built by ss
    #     build_executor = "sys"

    # build_executor = get_build_executor(tc)
    # if build_executor == "vm":
    #     executable = ocamlrun
    #     args.add(effective_compiler.path)
    #     if config_executor in ["sys"]:
    #         ext = ".cmxa"
    #     else:
    #         ext = ".cma"
    # else:
    #     executable = effective_compiler
    #     ext = ".cmxa"

    # if tc.build_executor == "vm":
    if tc.config_executor in ["boot", "baseline", "vm"]:
        ext = ".cma"
    else:
        ext = ".cmxa"

    # if build_executor == "vm":
    #     executable = ocamlrun
    #     args.add(effective_compiler.path)
    # else:
    #     executable = effective_compiler


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
    out_archive = ctx.actions.declare_file(workdir + archive_filename)
    # paths_direct.append(archive_file.dirname)
    action_outputs.append(out_archive)

    afile = []
    if ext == ".cmxa":
        archive_a_filename = archive_name + ".a"
        archive_a_file = ctx.actions.declare_file(workdir + archive_a_filename)
        afile.append(archive_a_file)
        # paths_direct.append(archive_a_file.dirname)
        action_outputs.append(archive_a_file)

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []
    for dep in ctx.attr.manifest:
        manifest.append(dep[DefaultInfo].files)

    for dep in ctx.attr.manifest:
        # if ctx.label == Label("@//compilerlibs:ocamlcommon"):
        #     print("dep[ModuleInfo]: %s" % dep[BootInfo])
        depsets = aggregate_deps(ctx, dep, depsets, manifest)

    # if ctx.label == Label("@//compilerlibs:ocamlcommon"):
    #     print("ofiles: %s" % depsets.deps.ofiles)

    sigs_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "sigs")])

    cli_link_deps_depset = depset(
        order = dsorder,
        # direct = [out_archive],
        transitive = [merge_depsets(depsets, "cli_link_deps")]
    )

    afiles_depset  = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "afiles")]
    )

    ofiles_depset  = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "ofiles")]
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

    #########################
    # ocamlrun = tc.compiler[DefaultInfo].default_runfiles.files.to_list()[0]
    # effective_compiler = tc.compiler[DefaultInfo].files_to_run.executable

    # if (target_executor == "unspecified"):
    #     if (config_executor == "sys"):
    #         if config_emitter == "sys":
    #             # ss built from ocamlopt.byte
    #             executable = ocamlrun
    #             args.add(effective_compiler.path)
    #         else:
    #             # sv built from ocamlopt.opt
    #             executable = effective_compiler
    #     else:
    #         executable = ocamlrun
    #         args.add(effective_compiler.path)

    # elif target_executor in ["boot", "vm"]:
    #         executable = ocamlrun
    #         args.add(effective_compiler.path)

    # elif (target_executor == "sys" and target_emitter == "sys"):
    #     ## ss always built by vs (ocamlopt.byte)
    #     executable = ocamlrun
    #     args.add(effective_compiler.path)

    # elif (target_executor == "sys" and target_emitter == "vm"):
    #     ## sv built by ss
    #     executable = effective_compiler

    # if ctx.label.name == "CamlinternalFormatBasics_cmi":
    #     print("ocamlrun: %s" % ocamlrun)
    #     print("effective_compiler: %s" % effective_compiler)
    #     print("executable: %s" % executable)

    # if executor in ["boot", "vm", "sys"]:
    #     ## ocamlrun
    #     for f in tc.compiler[DefaultInfo].default_runfiles.files.to_list():
    #         if f.basename == "ocamlrun":
    #             # print("LEX RF: %s" % f.path)
    #             executable = f
    #         # the bytecode executable
    #     args.add(tc.compiler[DefaultInfo].files_to_run.executable.path)
    # else:
    #     executable = tc.compiler[DefaultInfo].files_to_run.executable.path

    ## -use-prims never needed for archive
    # if hasattr(ctx.attr, "use_prims"):
    #     if ctx.attr.use_prims:
    #         args.add_all(["-use-prims", ctx.attr._primitives])
    # else:
    #     if ctx.attr.use_prims[BuildSettingInfo].value:
    #         args.add_all(["-use-prims", ctx.attr._primitives])
    #     else:
    #         args.add("-nopervasives")


    ## show calls to ar:
    # args.add("-verbose")
    # args.add("-ccopt", "-v")

    ## examples from mac make log:
    ## ocamlbytecomp.cma, ocamloptcomp.cma:  -nostdlib, -use-prims

    args.add_all(tc.linkopts)

    _options = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

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

    args.add_all(includes, before_each="-I", uniquify=True)

    for dep in filtering_depset.to_list():
        if dep in manifest:
            # if ctx.label == Label("@//compilerlibs:ocamlcommon"):
            #     print("DEP: %s" % dep)
            args.add(dep)

    args.add("-a")
    args.add("-o", out_archive)

    inputs_depset = depset(
        direct = ctx.files.data if ctx.files.data else []
        + [tc.executable]
        + toolarg_input
        ,
        transitive = []
        + [
            sigs_depset,
            afiles_depset,
            ofiles_depset,
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
        executable = tc.executable.path,
        arguments = [args],
        inputs = inputs_depset,
        outputs = action_outputs,
        tools = [
            # executable
            # tc.compiler[DefaultInfo].default_runfiles.files,
            # tc.compiler[DefaultInfo].files_to_run
        ],
        mnemonic = mnemonic,
        progress_message = progress_msg(workdir, ctx)
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

    cli_link_deps_depset = depset(
        order = dsorder,
        direct = [out_archive],
        transitive = [merge_depsets(depsets, "cli_link_deps")]
    )

    afiles_depset  = depset(
        order=dsorder,
        direct = afile,
        transitive = [merge_depsets(depsets, "afiles")]
    )

    bootProvider = BootInfo(
        sigs     = sigs_depset,
        cli_link_deps = cli_link_deps_depset,
        afiles   = afiles_depset,
        ofiles   = ofiles_depset,
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
