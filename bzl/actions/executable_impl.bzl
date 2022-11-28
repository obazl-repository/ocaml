load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load("//bzl:providers.bzl",
     "new_deps_aggregator",
     "OcamlExecutableMarker",
     "OcamlTestMarker"
)

load("//bzl:functions.bzl", "get_workdir", "tc_compiler")

load("//bzl/rules/common:impl_common.bzl", "dsorder")

load("//bzl/rules/common:options.bzl", "get_options")

load("//bzl/rules/common:DEPS.bzl",
     "aggregate_deps",
     "merge_depsets")

#########################
def executable_impl(ctx):  ## , tc):

    debug = False
    # if ctx.label.name == "test":
        # debug = True

    # print("++ EXECUTABLE {}".format(ctx.label))

    if debug:
        print("EXECUTABLE TARGET: {kind}: {tgt}".format(
            kind = ctx.attr._rule,
            tgt  = ctx.label.name
        ))

    # tc = ctx.toolchains["//toolchain/type:boot"]
    # print("boot tc: %s" % tc)

    cc_toolchain = find_cpp_toolchain(ctx)

    # tc = ctx.exec_groups["boot"].toolchains["//toolchain/type:boot"]
    tc = ctx.toolchains["//toolchain/type:boot"]
    (stage, executor, emitter, workdir) = get_workdir(tc)

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []

    aggregate_deps(ctx, ctx.attr._stdlib, depsets, manifest)
    aggregate_deps(ctx, ctx.attr._std_exit, depsets, manifest)

    for dep in ctx.attr.prologue:
        aggregate_deps(ctx, dep, depsets, manifest)

    if ctx.attr.main:
        depsets = aggregate_deps(ctx, ctx.attr.main, depsets, manifest)

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

    # if ctx.label.name == "compiler":
    #     print("depsets: %s" % depsets)
        # fail("x")

    ################
    # direct_cc_deps    = {}
    # direct_cc_deps.update(ctx.attr.cc_deps)
    # indirect_cc_deps  = {}

    ################
    # includes  = []
    # cmxa_args  = []

    out_exe = ctx.actions.declare_file(workdir + ctx.label.name)

    runtime = []
    if ctx.file._runtime:
        runtime.append(ctx.file._runtime)

    ####  flags and options for bootstrapping executables

    ## some examples from mac make log:
    ## ocamldep: -nostdlib, -g, -use-prims
    ## ocamlc: -nostdlib, -use-prims, -g, -compat-32
    ## ocamlopt: -nostdlib, -use-prims, -g
    ## ocamllex: -nostdlib, -use-prims, -compat-32
    ## ocamlc.opt: -nostdlib, -g, -cclib "-lm  -lpthread"
    ## ocamlopt.opt: -nostdlib, -g
    ## ocamllex.opt: -nostdlib

    #########################
    args = ctx.actions.args()

    executable = None
    if executor == "vm":
        ## ocamlrun
        for f in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
            if f.basename == "ocamlrun":
                # print("LEX RF: %s" % f.path)
                executable = f
            # the bytecode executable
        args.add(tc_compiler(tc)[DefaultInfo].files_to_run.executable.path)
    else:
        executable = tc_compiler(tc)[DefaultInfo].files_to_run.executable.path

    args.add("-o", out_exe)

    use_prims = False
    if hasattr(ctx.attr, "use_prims"):
        if ctx.attr.use_prims:
            use_prims = True
    else:
        if ctx.attr._use_prims[BuildSettingInfo].value:
            use_prims = True

    if use_prims:
        args.add_all(["-use-prims", ctx.file._primitives.path])
        primitives_depset = [depset([ctx.file._primitives])]
    else:
        primitives_depset = []

    # args.add_all(tc.linkopts)

    # if ext == ".cmx":
    #     args.add("-dstartup")

    _options = get_options(rule, ctx)
    args.add_all(_options)

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
    if ctx.files._camlheaders:
        data_inputs = [depset(direct = ctx.files._camlheaders)]

    includes = []
    print("CAMLHEADERS: %s" % ctx.files._camlheaders)
    for hdr in ctx.files._camlheaders:
        includes.append(hdr.dirname)

    for path in paths_depset.to_list():
        includes.append(path)

    if ctx.file._stdlib:
        includes.append(ctx.file._stdlib.dirname)

    # includes.append(ctx.file._std_exit.dirname)

    ##FIXME: if we're building a sys compiler we need to add
    ## libasmrun.a to runfiles, and if we're using a sys compiler we
    ## need to add libasmrun.a to in puts and add its dir to search
    ## path (-I).

    # compiler_runfiles = []
    # for rf in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
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

    filtering_depset = depset(
        order = dsorder,
        direct = ctx.files.prologue, #  + [ctx.file.main],
        transitive = [cli_link_deps_depset]
    )

    if ctx.file._runtime:
        # args.add(ctx.file._runtime.path)
        includes.append(ctx.file._runtime.dirname)

    args.add_all(includes, before_each="-I", uniquify=True)

    for dep in filtering_depset.to_list():
        if dep in manifest:
            args.add(dep)

    # for dep in cli_link_deps_depset.to_list():
    #     if dep.basename == "stdlib.cma":
    #         fail("STDLIB")
    #     if dep.extension in ["cma", "cmxa"]:  # for now
    #         args.add(dep)

    # ## 'main' dep must come last on cmd line
    if ctx.file.main:
        args.add(ctx.file.main)

    runfiles = []
    runfiles.append(ctx.file._primitives)
    if tc_compiler(tc)[DefaultInfo].default_runfiles:
        runfiles.append(tc_compiler(tc)[DefaultInfo].default_runfiles)
    # else:
    #     runfiles = []

    ## action input deps sources:
    ##  a. the target attributes
    ##  b. the compiler
    ##  c. the toolchain?

    inputs_depset = depset(
        direct = []
        + [ctx.file._std_exit]
        + [ctx.file.main] if ctx.file.main else []
        # compiler runfiles *should* contain camlheader files & stdlib:
        # + ctx.files._camlheaders
        # + camlheader_deps
        + tc
        + tc_compiler(tc)[DefaultInfo].files_to_run
        + runfiles
        ,
        transitive = []
        + [depset(
            ctx.files._camlheaders + [ctx.file._runtime]
            + [ctx.file._stdlib]
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
    # print("lbl: %s" % ctx.label)
    # print("ARCHIVED CMX: %s" % archived_cmx_depset)
    # print("AFILES: %s" % afiles_depset)
    # print("stdlib: %s" % ctx.file._stdlib.path)
    # if ctx.label.name == "cvt_emit.byte":
    #     if ctx.file._stdlib.dirname.endswith("2"):
    #         print("inputs %s" % inputs_depset)
            # fail()

    # for dep in inputs_depset.to_list():
    #     print("XDEP: %s" % dep)

    if ctx.attr._rule == "boot_executable":
        mnemonic = "CompileBootstrapExecutable"
    elif ctx.attr._rule == "bootstrap_repl":
        mnemonic = "CompileToplevel"
    elif ctx.attr._rule == "baseline_test":
        mnemonic = "CompileBootstrapTest"
    elif ctx.attr._rule == "boot_compiler":
        mnemonic = "CompileOcamlcBoot"
    elif ctx.attr._rule == "build_tool":
        mnemonic = "CompileBuildTool"
    elif ctx.attr._rule == "baseline_compiler":
        mnemonic = "CompileOcamlcKick"
    elif ctx.attr._rule == "ocaml_tool":
        mnemonic = "CompileOCamlTool"
    else:
        fail("Unknown rule for executable: %s" % ctx.attr._rule)

    # for rf in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
    #     if rf.path.endswith("ocamlrun"):
    #         print("exec OCAMLRUN: %s" % rf)

    ################
    ctx.actions.run(
        env = {"DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer",
               "SDKROOT": "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"},
        executable = executable,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [out_exe],
        tools = [
            tc_compiler(tc)[DefaultInfo].default_runfiles.files,
            tc_compiler(tc)[DefaultInfo].files_to_run
        ],
        mnemonic = mnemonic,
        progress_message = "stage {s} linking {rule}: {ws}//{pkg}:{tgt}".format(
            s = stage,
            rule = ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else "", ## ctx.workspace_name,
            pkg = ctx.label.package,
            tgt = ctx.label.name,
        )
    )
    ################

    #### RUNFILE DEPS ####

    compiler_runfiles = []
    for rf in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
        if rf.short_path.startswith("stdlib"):
            # print("STDLIB: %s" % rf)
            compiler_runfiles.append(rf)
        if rf.path.endswith("ocamlrun"):
            # print("OCAMLRUN: %s" % rf)
            compiler_runfiles.append(rf)
    ##FIXME: add tc.stdlib, tc.std_exit
    for f in ctx.files._camlheaders:
        compiler_runfiles.append(f)

    if ctx.attr.strip_data_prefixes:
      myrunfiles = ctx.runfiles(
        # files = ctx.files.data + compiler_runfiles + [ctx.file._std_exit],
        #   transitive_files =  depset([ctx.file._stdlib])
      )
    else:
        myrunfiles = ctx.runfiles(
            files = ctx.files.data,
            transitive_files =  depset(
                direct=compiler_runfiles,
                transitive = [depset(
                    # [ctx.file._std_exit, ctx.file._stdlib]
                )]
            )
        )

    ##########################
    defaultInfo = DefaultInfo(
        executable=out_exe,
        files = depset([out_exe]),
        runfiles = myrunfiles
    )

    exe_provider = None
    if ctx.attr._rule in ["boot_compiler"]:
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "baseline_compiler":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule in ["build_tool", "ocaml_tool"]:
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "boot_executable":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "bootstrap_repl":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "baseline_test":
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
