load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:collections.bzl", "collections")

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load("//bzl/actions:BUILD.bzl", "progress_msg")

load("//bzl:providers.bzl",
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
def inline_expect_impl(ctx, tc, exe_name, workdir):

    debug = False
    # if ctx.label.name == "test":
        # debug = True

    if debug:
        print("inline_expect: {kind}: {tgt}".format(
            kind = ctx.attr._rule,
            tgt  = ctx.label.name
        ))

    # config_executor = tc.config_executor
    # executor = tc.config_executor[BuildSettingInfo].value
    # emitter  = tc.config_emitter[BuildSettingInfo].value

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []

    # aggregate_deps(ctx, ctx.attr._stdlib, depsets, manifest)
    # aggregate_deps(ctx, ctx.attr._std_exit, depsets, manifest)

    for dep in ctx.attr.deps:
        aggregate_deps(ctx, dep, depsets, manifest)

    # if ctx.attr.main:
    #     depsets = aggregate_deps(ctx, ctx.attr.main, depsets, manifest)

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
    includes  = []

    #########################
    args = []

    args.append(tc.ocamlrun.short_path)

    executable = ctx.file._tool
    print("EXPECT executable: %s" % ctx.attr._tool)
    args.append(executable.short_path)

    # for f in ctx.attr._tool[DefaultInfo].default_runfiles.files.to_list():
    #     # print("RF: %s" % f)
    #     args.append(f.short_path)

    # args.append("-help")
    # args.append("-repo-root")
    # args.append(
    #     "bazel-out/darwin-fastbuild-ST-b87981718c05/bin"
    #     # ctx.file._stdlib.dirname + "/../.."
    # )
    args.append("-nostdlib")
    # args.append("-verbose")

    # args.append("-I")
    # args.append("stdlib/_dev_boot")

    primitives_depset = []

    # includes.append(ctx.file._stdlib.dirname)

    ## runtime_files are link-time deps, not to be confused with
    ## runfiles, which are runtime deps.
    runtime_files = []
    if tc.config_executor == "sys":
        # native compilers need libasmrun
        # WARNING: if we do not add libasmrun.a as a dep here,
        # OCaml will try to link /usr/local/lib/ocaml/libasmrun.a
        # to see, pass -verbose to the ocaml_compiler.opts or use
        # --//config/ocaml/link:verbose
        print("lbl: %s" % ctx.label)
        print("exe runtime: %s" % ctx.attr._runtime)
        print("exe runtime files: %s" % ctx.attr._runtime.files)

        for f in ctx.files._runtime:
            runtime_files.append(f)
            includes.append(f.dirname)
            # args.add_all(["-ccopt", "-L" + f.dirname])

            ## do not add to CLI - asmcomp/asmlink adds it to the
            ## OCaml cc link subcmd
            # args.add(f.path)
        print("runtime files: %s" % runtime_files)
    elif "-custom" in ctx.attr.opts:
        print("lbl: %s" % ctx.label)
        print("tc.name: %s" % tc.name)
        print("EXE runtime: %s" % ctx.attr._runtime)
        print("exe runtime files: %s" % ctx.attr._runtime.files)
        for f in ctx.files._runtime:
            print("EXE runtime.path: %s" % f.path)
            runtime_files.append(f)
            # includes.append(f.dirname)
            # args.add_all(["-ccopt", "-L" + f.dirname])

    # if ctx.attr.cc_deps:
    #     for f in ctx.files.cc_deps:
    #         # args.add_all(["-ccopt", "-L" + f.path])
    #         # args.add_all(["-ccopt", f.basename])
    #         args.add(f.path)
    #         runtime_files.append(f)
    #         includes.append(f.dirname)

    # args.add_all(tc.linkopts)

    (_options, cancel_opts) = get_options(rule, ctx)
    args.extend(_options)

    # if ctx.attr.cc_linkopts:
    #     for lopt in ctx.attr.cc_linkopts:
    #         if lopt == "verbose":
    #             # if platform == mac:
    #             args.add_all(["-ccopt", "-Wl,-v"])
    #         else:
    #             args.add_all(["-ccopt", lopt])

    # for w in ctx.attr.warnings:
        # args.add_all(["-w",
        # args.append(["-w",
        #               w if w.startswith("-")
        #               else "-" + w])

    data_inputs = []
    # if ctx.attr.data:
    #     data_inputs = [depset(direct = ctx.files.data)]

    for path in paths_depset.to_list():
        includes.append(path)

    # manifest = ctx.files.prologue

    # filtering_depset = depset(
    #     order = dsorder,
    #     direct = ctx.files.prologue, #  + [ctx.file.main],
    #     transitive = [cli_link_deps_depset]
    # )

    for inc in includes:
        args.append("-I")
        args.append(inc)

    # for dep in filtering_depset.to_list():
    #     if dep in manifest:
    #         args.add(dep)

    runfiles = []
    # if ocamlrun:
    #     runfiles.append(tc.compiler[DefaultInfo].default_runfiles)

    inputs_depset = depset(
        direct = []
        + runfiles
        ,
        transitive = []
        + [depset(
            runtime_files
            # + [effective_compiler]
            # + [ctx.file._stdlib]
            # ctx.files._camlheaders
            # + ctx.files._runtime
            # + ctx.files._stdlib
            # + camlheaders
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
        # + [cc_toolchain.all_files]
        # + data_inputs
        # + [depset(action_inputs_ccdep_filelist)]
    )
    mnemonic = "OcamlInlineExpectTest"

    # args.append("-I")
    # args.append("stdlib/{}".format(workdir))
    # # last arg:
    # args.append(ctx.file.src.path + ";")

    runner = ctx.actions.declare_file(workdir + ctx.file.src.basename + ".test_runner.sh")

    # args.append("echo PWD: $PWD;")
    # args.append("echo 'listing: {}';".format(ctx.file.src.dirname))
    # args.append("ls -la {};".format(ctx.file.src.dirname))
    # args.append("cat {};".format(ctx.file.src.path + ".corrected"))

    args.extend(["diff", "-w",
                ctx.file.src.path,
                ctx.file.src.path + ".corrected;"])


    cmd = args[0]
    for arg in args[1:]:
        cmd = cmd + " \\\n" + arg

    ctx.actions.write(
        output  = runner,
        content = cmd,
        is_executable = True
    )

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
    # runfiles.append(executable)
    runfiles.append(ctx.file.src)
    # runfiles.append(ctx.file._stdlib)
    for f in ctx.attr._tool[DefaultInfo].default_runfiles.files.to_list():
        runfiles.append(f)
    # if ocamlrun:
    #     runfiles = [tc.compiler[DefaultInfo].default_runfiles.files]
    # print("runfiles tc.compiler: %s" % tc.compiler)
    # print("runfiles tc.ocamlrun: %s" % tc.ocamlrun)
    # if tc.protocol == "dev":
    #     runfiles.append(tc.ocamlrun)
    # elif ocamlrun:
    #     runfiles.append(tc.compiler[DefaultInfo].default_runfiles.files.to_list)

    # print("EXE runfiles: %s" % runfiles)

    # if ctx.attr.strip_data_prefixes:
    #   myrunfiles = ctx.runfiles(
    #     # files = ctx.files.data + compiler_runfiles + [ctx.file._std_exit],
    #     #   transitive_files =  depset([ctx.file._stdlib])
    #   )
    # else:
    myrunfiles = ctx.runfiles(
        # files = ctx.files.data,
        transitive_files =  depset(
            transitive = [
                depset(direct=runfiles),
                sigs_depset
            ]
            # direct=compiler_runfiles,
            # transitive = [depset(
            #     # [ctx.file._std_exit, ctx.file._stdlib]
            # )]
            )
    )

    ##########################
    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    # exe_provider = None
    # if ctx.attr._rule in ["ocaml_compiler"]:
    #     exe_provider = OcamlExecutableMarker()
    # elif ctx.attr._rule == "baseline_compiler":
    #     exe_provider = OcamlExecutableMarker()
    # elif ctx.attr._rule in ["build_tool", "ocaml_tool"]:
    #     exe_provider = OcamlExecutableMarker()
    # elif ctx.attr._rule == "boot_executable":
    #     exe_provider = OcamlExecutableMarker()
    # elif ctx.attr._rule in ["test_executable"]:
    #     exe_provider = OcamlExecutableMarker()
    # elif ctx.attr._rule == "bootstrap_repl":
    #     exe_provider = OcamlExecutableMarker()
    # elif ctx.attr._rule == "baseline_test":
    #     exe_provider = OcamlTestMarker()
    # elif ctx.attr._rule == "ocaml_test":
    #     exe_provider = OcamlTestMarker()
    # else:
    #     fail("Wrong rule called impl_executable: %s" % ctx.attr._rule)

    providers = [
        defaultInfo,
        # exe_provider
    ]
    # print("out_exe: %s" % out_exe)
    # print("exe prov: %s" % defaultInfo)

    return providers