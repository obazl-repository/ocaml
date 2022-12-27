load("@bazel_skylib//lib:paths.bzl", "paths")

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load(":BUILD.bzl", "progress_msg", "get_build_executor")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "new_deps_aggregator",
     "OcamlExecutableMarker",
     "OcamlTestMarker"
)

load("//bzl/rules/common:impl_common.bzl", "dsorder")

load("//bzl/rules/common:options.bzl", "get_options")

load("//bzl/rules/common:DEPS.bzl",
     "aggregate_deps",
     "merge_depsets")

#########################
def executable_impl(ctx, tc, exe_name, workdir):

    debug = False

    if debug:
        print("EXECUTABLE TARGET: {kind}: {tgt}".format(
            kind = ctx.attr._rule,
            tgt  = ctx.label.name
        ))

    cc_toolchain = find_cpp_toolchain(ctx)

    # tc = ctx.toolchains["//toolchain/type:ocaml"]

    # config_executor = tc.config_executor

    if hasattr(ctx.attr, "vm_only"):
        if ctx.attr.vm_only:
            if tc.config_executor == "sys":
                fail("This target can only be built for vm executor. Try passing --//config/target/executor=vm")

    if debug:
        print("tc.name: %s" % tc.name)
        # print("config_executor: %s" % tc.config_executor)
        # print("config_emitter: %s" % config_emitter)
        print("tc.compiler: %s" % tc.compiler)
        # for f in tc.compiler[DefaultInfo].default_runfiles.files.to_list():
        #     print("tc rf: %s" % f)
        # x = tc.compiler[DefaultInfo].files_to_run.executable
        # print("tc executable: %s" % x)

    #########################
    args = ctx.actions.args()

    toolarg = tc.tool_arg
    if toolarg:
        args.add(toolarg.path)
        toolarg_input = [toolarg]
    else:
        toolarg_input = []

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    includes  = []

    manifest = []

    # aggregate_deps(ctx, ctx.attr.stdlib, depsets, manifest)
    # aggregate_deps(ctx, ctx.attr._std_exit, depsets, manifest)

    open_stdlib = False
    stdlib_module_target  = None
    stdlib_library_target = None

    for dep in ctx.attr.prologue:
        depsets = aggregate_deps(ctx, dep, depsets, manifest)
        # depsets = aggregate_deps(ctx, dep, depsets, manifest)
        if dep.label.name in ["Stdlib", "Primitives"]:
            open_stdlib = True
            stdlib_module_target = dep
            break;
        elif dep.label.name.startswith("Stdlib"): ## stdlib submodule
            open_stdlib = True
        elif dep.label.name == "stdlib": ## stdlib archive OR library
            open_stdlib = True
            stdlib_library_target = dep
            break;

    if ctx.attr.main:
        depsets = aggregate_deps(ctx, ctx.attr.main, depsets, manifest)

    sigs_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "sigs")])

    cli_link_deps_depset = depset(
        order = dsorder,
        transitive = [merge_depsets(depsets, "cli_link_deps")]
    )

    # for ds in cli_link_deps_depset.to_list():
    #     print("LINKDEPS ds: %s" % ds)
    # for ds in sigs_depset.to_list():
    #     print("SIGDEPS ds: %s" % ds.path)

    # if ctx.label.name == "cvt_emit.byte":
    #     fail()


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
        transitive = [merge_depsets(depsets, "paths")]
    )

    ################
    if ctx.attr._protocol == "test":
        workdir = ""
    out_exe = ctx.actions.declare_file(workdir + exe_name)

    primitives_depset = []
    # if use_prims:
    #     args.add_all(["-use-prims", ctx.file._primitives.path])
    #     primitives_depset = [depset([ctx.file._primitives])]
    # else:
    #     primitives_depset = []

    ## runtime_files are link-time deps, not to be confused with
    ## runfiles, which are runtime deps.
    runtime_files = []
    runtime_depsets = []
    cc_libdirs    = []

    # if tc.config_executor == "sys":  ## target_executor
    if tc.compiler[DefaultInfo].files_to_run.executable.basename in ["ocamlopt.opt", "ocamlopt.byte"]:

        ## if target_executor(tc) == "sys"

        # native compilers need libasmrun
        # WARNING: if we do not add libasmrun.a as a dep here,
        # OCaml will try to link /usr/local/lib/ocaml/libasmrun.a
        # to see, pass -verbose to the ocaml_compiler.opts or use
        # --//config/ocaml/link:verbose
        # print("lbl: %s" % ctx.label)
        # print("exe runtime: %s" % ctx.attr._runtime)
        # print("exe runtime files: %s" % ctx.attr._runtime.files)

        # for f in ctx.files._runtime: ## libasmrun.a
        # for f in tc.runtime: ## libasmrun.a

        print("tc.COMPILER: %s" % tc.compiler)
        print("tc.RUNTIME: %s" % tc.runtime.path)
        args.add(tc.runtime.path)

        runtime_files.append(tc.runtime) # [0][DefaultInfo].files)
        ## NB: Asmlink looks for libasmrun.a in the std search
        ## space (-I dirs), not the link srch space (-L dirs)
        includes.append(tc.runtime.dirname) #[0][DefaultInfo].files.to_list()[0].dirname)
        # cc_libdirs.append(f.dirname)

        ## do not add to CLI - asmcomp/asmlink adds it to the
        ## OCaml cc link subcmd

        # print("runtime files: %s" % runtime_files)
    elif "-custom" in ctx.attr.opts:
        # for f in ctx.files._runtime:  # libcamlrun.a
        # for f in tc.runtime:  # libcamlrun.a
            # print("tc.RUNTIME: %s" % f)
            # runtime_files.append(f)
            # # will add -L<f.dirname> below
            # cc_libdirs.append(f.dirname)
        print("custom tc.RUNTIME: %s" % tc.runtime)
        runtime_depsets.append(tc.runtime[0][DefaultInfo].files)
        # will add -L<f.dirname> below
        cc_libdirs.append(tc.runtime[0][DefaultInfo].files.to_list()[0].dirname)

    (_options, cancel_opts) = get_options(rule, ctx)

    # if ext == ".cmx":
    #     args.add("-dstartup")

    if "-pervasives" in _options:
        cancel_opts.append("-nopervasives")
        _options.remove("-pervasives")
    # else:
    #     _options.append("-nopervasives")

    for opt in tc.linkopts:
        if opt not in cancel_opts:
            args.add(opt)

    args.add_all(_options)

    # args.add("-nopervasives")

    for w in ctx.attr.warnings:
        args.add_all(["-w",
                      w if w.startswith("-")
                      else "-" + w])
    # if ctx.attr.warnings == [  ]:
    #     args.add_all(ctx.attr.warnings)
    # else:
    #     args.add_all(tc.warnings[BuildSettingInfo].value)

    data_inputs = []
    # if ctx.attr.data:
    #     data_inputs = [depset(direct = ctx.files.data)]
    # if ctx.files._camlheaders:
    #     data_inputs = [depset(direct = ctx.files._camlheaders)]

    # print("CAMLHEADERS: %s" % ctx.files._camlheaders)
    # for hdr in ctx.files._camlheaders:
    #     includes.append(hdr.dirname)

    for path in paths_depset.to_list():
        includes.append(path)

    # if ctx.file.stdlib:
    #     includes.append(ctx.file.stdlib.dirname)
    # includes.append(ctx.files.stdlib[0].dirname)

    includes.append(ctx.file._std_exit.dirname)

    ##FIXME: if we're *building* a sys compiler we need to add
    ## libasmrun.a to runfiles, and if we're *using* a sys compiler we
    ## need to add libasmrun.a to inputs and add its dir to search
    ## path (-I).

    ## If we're building a vm executor tool, we need to add the
    ## ocamlrun runtime to runfiles.

    # compiler_runfiles = []
    # for rf in tc.compiler[DefaultInfo].default_runfiles.files.to_list():
    #     if rf.short_path.startswith("stdlib"):
    #         # print("STDLIB: %s" % rf)
    #         # args.add("-DFOOBAR")
    #         # args.add_all(["-I", rf.dirname])
    #         # includes.append(rf.dirname)
    #         compiler_runfiles.append(rf)
    #     if rf.path.endswith("ocamlrun"):
    #         # print("OCAMLRUN: %s" % rf)
    #         compiler_runfiles.append(rf)
    ##FIXME: add tc.stdlib, tc.std_exit

    # camlheader_deps = []

    # for f in ctx.files._camlheaders:
    #     print("CAMLHEADER: %s" % f.path)
    #     # includes.append(f.dirname)
    #     camlheader_deps.append(f)

    ## To get cli args in right order, we need then merged depset of
    ## all deps. Then we use the manifest to filter.

    manifest = ctx.files.prologue
    if ctx.label.name == "ocamlobjinfo":
        print("PROLOGUE: %s" % manifest)

    filtering_depset = depset(
        order = dsorder,
        direct = ctx.files.prologue, #  + [ctx.file.main],
        transitive = [cli_link_deps_depset]
    )

    compiler = tc.compiler[DefaultInfo].files_to_run.executable

    # if tc.config_executor in ["boot", "baseline", "vm"]:
    if compiler.basename in ["ocamlc.byte", "ocamlc.opt", "ocamlc.boot"]:
        # camlheaders only used by this rule so no need to put in tc
        # but camlheaders tgt is tc-dependent (uses tc.ocamlrun.path)
        camlheaders = ctx.files._camlheaders
        includes.append(camlheaders[0].dirname)
    else:
        camlheaders = []

    if stdlib_module_target:
        stdlib = ctx.expand_location("$(rootpath //stdlib:Stdlib)",
                                     targets=[stdlib_module_target])
        includes.append(paths.dirname(stdlib))
        # cmd_args.append("-I")
        # cmd_args.append(paths.dirname(stdlib))
    elif stdlib_library_target:
        if ctx.attr._libs_archived[BuildSettingInfo].value:
            stdlib = ctx.expand_location("$(rootpath //stdlib)",
                                         targets=[stdlib_library_target])
            includes.append(paths.dirname(stdlib))
            # cmd_args.append("-I")
            # cmd_args.append(paths.dirname(stdlib))
        else:
            stdlibstr = ctx.expand_location("$(rootpaths //stdlib)",
                                         targets=[stdlib_library_target])
            stdlibs = stdlibstr.split(" ")
            includes.append(paths.dirname(stdlibs[0]))
            # cmd_args.append("-I")
            # cmd_args.append(paths.dirname(stdlibs[0]))

    args.add_all(includes, before_each="-I", uniquify=True)

    if ctx.attr.cc_linkopts:
        for lopt in ctx.attr.cc_linkopts:
            if lopt == "verbose":
                # if platform == mac:
                args.add_all(["-ccopt", "-Wl,-v"])
            else:
                args.add_all(["-ccopt", lopt])

    for d in cc_libdirs:
        args.add_all(["-ccopt", "-L" + d])

    if ctx.attr.cc_deps:
        for f in ctx.files.cc_deps:
            # args.add_all(["-ccopt", "-L" + f.path])
            # args.add_all(["-ccopt", f.basename])
            args.add(f.path)
            runtime_files.append(f)
            includes.append(f.dirname)

    ## Choice: either use filtering_depset or cli_link_deps, not both
    if ctx.attr._libs_archived[BuildSettingInfo].value:
        for dep in filtering_depset.to_list():
            if dep in manifest:
                args.add(dep)
        # ## 'main' dep must come last on cmd line
        if ctx.file.main:
            args.add(ctx.file.main)
    else:
        for dep in cli_link_deps_depset.to_list():
            args.add(dep)

    if hasattr(ctx.attr, "epilogue"):
        args.add_all(ctx.files.epilogue)

    args.add_all(ctx.files._std_exit)

    args.add("-o", out_exe)

    ################################################################
    # if ctx.label.name == "ocamlc.byte":
    #     print("runfiles for: %s" % ctx.label)
    #     print(tc.compiler[DefaultInfo].default_runfiles.files)
    #     for f in tc.compiler[DefaultInfo].default_runfiles.files.to_list():
    #         print("RF: %s" % f)
    #     # fail()

    runfiles = []
    # if ...:
    #     runfiles.append(ctx.file._primitives)
    # if tc.compiler[DefaultInfo].default_runfiles:
    if tc.build_executor in ["boot", "baseline", "vm"]:  ## ocamlrun:
        runfiles.append(tc.compiler[DefaultInfo].default_runfiles)
    # else:
    #     runfiles = []

    ## action  deps sources:
    ##  a. the target attributes
    ##  b. the compiler
    ##  c. the toolchain?

    # if target is sys, add asmrun?

    # print("lbl: %s" % ctx.label)
    # print("exe effective_compiler: %s" % effective_compiler.path)

    std_exit_files = ctx.attr._std_exit[ModuleInfo].files
    # if ctx.label.name in ["cvt_emit.byte", "ocamlopt.opt"]:
    #     print("std_exit files: %s" % std_exit_files)
    #     print("sig: %s" % ctx.attr._std_exit[ModuleInfo].sig)
    #     print("struct: %s" % ctx.attr._std_exit[ModuleInfo].struct)


    inputs_depset = depset(
        direct = []
        + [ctx.file.main] if ctx.file.main else []
        # compiler runfiles *should* contain camlheader files & stdlib:
        # + ctx.files._camlheaders
        # + camlheader_deps
        # + tc                    # ???
        # + tc.compiler[DefaultInfo].files_to_run ???
        + runfiles
        ,
        transitive = []
        + runtime_depsets
        + [std_exit_files]
        + [depset(
             [tc.executable]
            + ctx.files.prologue  #
            + ctx.files.epilogue
            # + ctx.files.stdlib
            + runtime_files
            + toolarg_input
            # ctx.files._camlheaders
            # + ctx.files._runtime
            + camlheaders
        )]
        #FIXME: primitives should be provided by target, not tc?
        # + [depset([tc.primitives])] # if tc.primitives else []
        + [
            sigs_depset,
            cli_link_deps_depset,
            archived_cmx_depset,
            ofiles_depset,
            afiles_depset
        ]
        + primitives_depset
        + [cc_toolchain.all_files]
        # + data_inputs
        # + [depset(action_inputs_ccdep_filelist)]
    )

    if ctx.attr._rule == "boot_executable":
        mnemonic = "LinkBootstrapExecutable"
    elif ctx.attr._rule == "test_executable":
        mnemonic = "LinkTestExecutable"
    elif ctx.attr._rule == "bootstrap_repl":
        mnemonic = "LinkToplevel"
    elif ctx.attr._rule == "baseline_test":
        mnemonic = "LinkBootstrapTest"
    elif ctx.attr._rule in ["ocaml_compiler",
                            "build_tool_vm", "build_tool_sys",
                            "ocamlc_byte", "ocamlopt_byte",
                            "ocamlopt_opt", "ocamlc_opt"]:
        mnemonic = "LinkOcamlCompiler"
    elif ctx.attr._rule in ["ocamllex_byte", "ocamllex_opt"]:
        mnemonic = "LinkOCamlLex"
    elif ctx.attr._rule == "build_tool":
        mnemonic = "LinkBuildTool"
    # elif ctx.attr._rule == "baseline_compiler":
    #     mnemonic = "LinkBaseline"
    elif ctx.attr._rule in ["ocaml_tool_r",
                            "ocaml_tool_vm", "ocaml_tool_sys"]:
        mnemonic = "LinkOCamlTool"
    elif ctx.attr._rule in ["ocaml_test", "expect_test"]:
        mnemonic = "OcamlTest"
    else:
        fail("Unknown rule for executable: %s" % ctx.attr._rule)

    ################
    ctx.actions.run(
        # env = {"DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer",
        #        "SDKROOT": "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"},
        executable = tc.executable.path,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [out_exe],
        mnemonic = mnemonic,
        progress_message = progress_msg(workdir, ctx)
    )
    ################

    #### RUNFILE DEPS ####
    ## compilers: store the tool(s) used to build in runfiles
    ## e.g. if we're linking ocamlopt.byte, we store the ocamlc.byte used to compile/link
    ## if we're linking ocamlc.opt, we store the camlopt.byte used
    ## that way each (vm) executable carries its "history",
    ## and the coldstart can use that history to install all the compilers

    # compiler_runfiles = []
    # for rf in tc.compiler[DefaultInfo].default_runfiles.files.to_list():
    #     if rf.short_path.startswith("stdlib"):
    #         # print("STDLIB: %s" % rf)
    #         compiler_runfiles.append(rf)
    #     if rf.path.endswith("ocamlrun"):
    #         # print("OCAMLRUN: %s" % rf)
    #         compiler_runfiles.append(rf)
    ##FIXME: add tc.stdlib, tc.std_exit
    # for f in ctx.files._camlheaders:
    #     compiler_runfiles.append(f)

    runfiles = []
    # if ocamlrun:
    #     runfiles = [tc.compiler[DefaultInfo].default_runfiles.files]
    # print("runfiles tc.compiler: %s" % tc.compiler)
    # print("runfiles tc.ocamlrun: %s" % tc.ocamlrun)
    if tc.protocol == "dev":
        runfiles.append(tc.ocamlrun)
    # elif ocamlrun:

    if ctx.attr._rule == "run_ocamllex":
        runfiles = [tc.lexer[DefaultInfo].default_runfiles.files]
    else:
        runfiles = [tc.compiler[DefaultInfo].default_runfiles.files]

    # print("DATA: %s" % ctx.files.data)
    if ctx.attr.strip_data_prefixes:
      myrunfiles = ctx.runfiles(
        # files = ctx.files.data + compiler_runfiles + [ctx.file._std_exit],
        #   transitive_files =  depset([ctx.file._stdlib])
      )
    else:
        myrunfiles = ctx.runfiles(
            files =[
                # ctx.file.stdlib,
                ctx.file._std_exit
            ],
            transitive_files =  depset(
                transitive = runfiles + [
                    depset(direct=ctx.files.data),
                ]
            )
        )

    ##########################
    defaultInfo = DefaultInfo(
        executable=out_exe,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    exe_provider = None
    if ctx.attr._rule in ["ocaml_compiler",
                          "build_tool_vm", "build_tool_sys",
                          "ocamlc_byte", "ocamlopt_byte",
                          "ocamlopt_opt", "ocamlc_opt"]:
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "baseline_compiler":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule in ["build_tool",
                            "ocaml_tool_r",
                            "ocaml_tool_vm", "ocaml_tool_sys"]:
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "boot_executable":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule in ["test_executable"]:
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "bootstrap_repl":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "baseline_test":
        exe_provider = OcamlTestMarker()
    elif ctx.attr._rule in ["ocaml_test", "expect_test"]:
        exe_provider = OcamlTestMarker()
    else:
        fail("Wrong rule called impl_executable: %s" % ctx.attr._rule)

    providers = [
        defaultInfo,
        # exe_provider
    ]
    # print("out_exe: %s" % out_exe)
    # print("exe prov: %s" % defaultInfo)

    return providers
