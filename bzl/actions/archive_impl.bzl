load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load(":BUILD.bzl", "progress_msg", "get_build_executor")

load("//bzl:providers.bzl",
     "ArchiveCcMarker",
     "BootInfo",
     "ModuleInfo",
     "new_deps_aggregator",
     "StdLibMarker",
     "StdlibLibMarker")

load("//bzl/rules/common:impl_common.bzl", "dsorder")
load("//bzl/rules/common:impl_ccdeps.bzl",
     "extract_cclibs",
     "dump_CcInfo", "ccinfo_to_string")

load("//bzl/rules/common:options.bzl", "get_options")

load("//bzl/rules/common:DEPS.bzl",
     "aggregate_deps",
     "merge_depsets")

###############################
def archive_impl(ctx):
    debug = False
    debug_ccdeps = True

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    #########################
    args = ctx.actions.args()

    toolarg = tc.tool_arg
    if toolarg:
        args.add(toolarg.path)
        toolarg_input = [toolarg]
    else:
        toolarg_input = []

    tgt_name = ctx.label.name
    if ctx.label.name.endswith(".cmxa"):
        tgt_name = ctx.label.name[:-5]
    #     ext = ".cmxa"
    # elif tc.config_executor == "sys":
    #     ext = ".cmxa"
    # else:
    #     ext = ".cma"

    compiler = tc.compiler[DefaultInfo].files_to_run.executable
    if compiler.basename in [
        "ocamlc.byte", "ocamlc.opt", "ocamlc.boot",
        "ocamlc.optx",
    ]:
        # fail("XXXXXXXXXXXXXXXX %s" % ctx.label)
        ext = ".cma"
    elif compiler.basename in [
        "ocamlopt.opt", "ocamlopt.byte",
        "ocamloptx.optx", "ocamloptx.byte"
    ]:
        # fail("YYYYYYYYYYYYYYYY: %s" % ctx.label)
        ext = ".cmxa"
    else:
        fail("bad compiler basename: %s" % compiler.basename)

    ################################################################
    ################  OUTPUTS: out_archive  ################
    ## same for plain and ns archives
    if ctx.attr._rule.startswith("ocaml_ns"):
        if ctx.attr.ns:
            archive_name = ctx.attr.ns ## normalize_module_name(ctx.attr.ns)
        else:
            archive_name = tgt_name ## normalize_module_name(ctx.label.name)
    else:
        archive_name = tgt_name ## normalize_module_name(ctx.label.name)

    if debug:
        print("archive_name: %s" % archive_name)

    action_outputs = []

    archive_filename = archive_name + ext
    out_archive = ctx.actions.declare_file(workdir + archive_filename)

    action_outputs.append(out_archive)

    afile = []
    if ext == ".cmxa":
        archive_a_filename = archive_name + ".a"
        archive_a_file = ctx.actions.declare_file(workdir + archive_a_filename)
        afile.append(archive_a_file)
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

    if len(depsets.ccinfos) > 0:
        ccInfo_provider = cc_common.merge_cc_infos(
            cc_infos = depsets.ccinfos
            # cc_infos = cc_deps_primary + cc_deps_secondary
        )
        if ctx.attr._cc_debug[BuildSettingInfo].value:
            if debug_ccdeps:
                dump_CcInfo(ctx, ccInfo_provider)
            print("ccInfo_provider for %s" % ctx.label)
            print("%s" % ccinfo_to_string(ctx, ccInfo_provider))
    else:
        ccInfo_provider = None

    paths_depset  = depset(
        order = dsorder,
        direct = [out_archive.dirname],
        transitive = [merge_depsets(depsets, "paths")]
    )

    args.add_all(tc.linkopts)

    (_options, cancel_opts) = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

    ## Submodules can be listed in ctx.files.submodules in any order,
    ## so we need to put them in correct order on the command line.
    ## Order is encoded in their depsets, which were merged by
    ## impl_ns_library; the result contains the files of
    ## ctx.files.submodules in the correct order.
    ## submod[DefaultInfo].files won't work, it contains only one
    ## module BootInfo. linkargs contains the deptree we need,
    ## but it may contain additional modules, so we need to filter.

    ## ns_archives have submodules, plain archives have modules
    manifest = ctx.files.manifest
    # or: manifest = libDefaultInfo.files.to_list()

    ## solve double-link problem:

    # print("manifest: %s" % manifest)

    includes = []

    ## to construct cmd line we need to extract the cc files from
    ## merged CcInfo provider:
    if ccInfo_provider:
        [static_cc_deps, dynamic_cc_deps] = extract_cclibs(ctx, ccInfo_provider)
        if debug_ccdeps:
            print("static_cc_deps:  %s" % static_cc_deps)
            print("dynamic_cc_deps: %s" % dynamic_cc_deps)

        sincludes = []

        if ctx.attr.archive or ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
            if ctx.attr.archive_cc:
                args.add("-custom")

                for dep in static_cc_deps:
                    # args.add(dep.basename)
                    bn = dep.basename[3:] # drop initial 'lib'
                    bn = bn[:-2]  # drop final '.a'
                    # args.add("-cclib", dep.path)
                    args.add("-cclib", "-l" + bn)
                    # args.add("-dllpath", dep.dirname)
                    includes.append(dep.dirname)
                    # sincludes.append("-L" + paths.dirname(dep.short_path))
                    sincludes.append("-L" + dep.dirname)

                args.add_all(sincludes, before_each="-ccopt", uniquify=True)

            for dep in dynamic_cc_deps:
                bn = dep.basename[3:] # drop initial 'lib'
                bn = bn[:-3]  # drop final '.so'  ##FIXME: dylib on mac?
                if dep.basename.startswith("dll"):
                    # args.add("-foo", dep)
                    args.add("-dllib", "-l" + bn)
                    args.add("-dllpath", paths.dirname(dep.short_path))
                else:
                    args.add("-cclib", "-l" + bn)
                    sincludes.append("-L" + dep.dirname)
                args.add_all(sincludes, before_each="-ccopt", uniquify=True)

    ## FIXME: should be handled by aggregate_deps
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
    linkargs_list = []
    ## merge archive submanifests, to get list of all modules included
    ## in archives. use list to filter cmd line args

    ## To get cli args in right order, we need then merged depset of
    ## all deps. Then we use the manifest to filter.

    filtering_depset = depset(
        direct = ctx.files.manifest, ## only .cmo/.cmx files
        transitive = [cli_link_deps_depset]
    )

    args.add_all(includes, before_each="-I", uniquify=True)

    for dep in filtering_depset.to_list():
        if dep in manifest:
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

    mnemonic = "CompileOcamlArchive"

    ################
    ctx.actions.run(
        executable = tc.executable.path,
        arguments = [args],
        inputs = inputs_depset,
        outputs = action_outputs,
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

    ## now add archive to link_deps
    cli_link_deps_depset = depset(
        order = dsorder,
        direct = [out_archive],
        # transitive = [merge_depsets(depsets, "cli_link_deps")]
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
    )

    providers = [
        newDefaultInfo,
        bootProvider,
        # ocamlArchiveProvider
    ]

    if ccInfo_provider:
        providers.append(ccInfo_provider)

        if ctx.attr.archive or ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
            if ctx.attr.archive_cc:
                # this means we have included cc metadata in the archive
                providers.append(ArchiveCcMarker())

    if ctx.attr._rule == "stdlib_library":
        providers.append(StdlibLibMarker())

    if ctx.attr._rule in ["compiler_library", "test_library"]:
        providers.append(StdLibMarker())

    # print("boot provider:")
    # print(bootProvider)

    return providers
