load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "new_deps_aggregator",
     "OcamlExecutableMarker",
     "OcamlTestMarker"
)

load("//bzl:functions.bzl", "stage_name", "tc_compiler")

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

    tc = ctx.exec_groups["boot"].toolchains[
        "//boot/toolchain/type:boot"]

    # build_emitter = tc.build_emitter[BuildSettingInfo].value
    # print("BEMITTER: %s" % build_emitter)

    target_executor = tc.target_executor[BuildSettingInfo].value
    target_emitter  = tc.target_emitter[BuildSettingInfo].value

    print("executable: %s" % ctx.label)
    print("tc.name: %s" % tc.name)
    print("tc.target_executor: %s" % target_executor)
    print("tc.target_emitter : %s" % target_emitter)
    print("host_platform: %s" % ctx.fragments.platform.host_platform)
    print("platform: %s" % ctx.fragments.platform.platform)

    stage = tc._stage[BuildSettingInfo].value
    print("module _stage: %s" % stage)
    # fail("XEX")

    if stage == 2:
        ext = ".cmx"
    else:
        if target_executor == "vm":
            ext = ".cmo"
        elif target_executor == "sys":
            ext = ".cmx"
        else:
            fail("Bad target_executor: %s" % target_executor)

    workdir = "_{b}{t}{stage}/".format(
        b = target_executor, t = target_emitter, stage = stage)

    # print("executable _stage: %s" % tc._stage)

    # if tc._stage == 0:
    #     workdir = "_boot/"
    # elif tc._stage == 1:
    #     workdir = "_baseline/"
    # elif tc._stage == 2:
    #     workdir = "_dev/"
    # elif tc._stage == 3:
    #     workdir = "_prod/"
    # else:
    #     fail("exec UHANDLED STAGE: %s" % tc._stage)

   # if hasattr(attr, "stage"):
   #      stage = ctx.attr.stage
   #  else:
   #      stage = ctx.attr._stage[BuildSettingInfo].value

    # tc = None
    # if stage == "boot":
    #     tc = ctx.exec_groups["boot"].toolchains[
    #         "//boot/toolchain/type:boot"]
    # elif stage == "baseline":
    #     tc = ctx.exec_groups["baseline"].toolchains[
    #         "//boot/toolchain/type:baseline"]
    # elif stage == "dev":
    #     tc = ctx.exec_groups["dev"].toolchains[
    #         "//boot/toolchain/type:baseline"]
    # else:
    #     print("UNHANDLED STAGE: %s" % stage)
    #     tc = ctx.exec_groups["boot"].toolchains[
    #         "//boot/toolchain/type:boot"]

    # print("xtc boot tc: %s" % tc)
    # fail("X")

    # xtc = ctx.exec_groups["boot"].toolchains["//boot/toolchain/type:boot"]
    # print("xtc boot tc: %s" % xtc)

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []

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

    tool = None
    for f in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
        if f.basename == "ocamlrun":
            # print("LEX RF: %s" % f.path)
            tool = f

    # the bytecode executable
    args.add(tc_compiler(tc)[DefaultInfo].files_to_run.executable.path)

    if hasattr(ctx.attr, "use_prims"):
        if ctx.attr.use_prims:
            args.add_all(["-use-prims",
                          ctx.file._primitives])
    else:
        if ctx.attr._use_prims[BuildSettingInfo].value:
            args.add_all(["-use-prims", ctx.file._primitives.path])

    # args.add_all(tc.linkopts)

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
    data_inputs = [depset(direct = ctx.files._camlheaders)]
        # for f in ctx.files.data:
        #     includes.append(f.dirname)

    includes = []
    for path in paths_depset.to_list():
        includes.append(path)

    if ctx.file._stdlib:
        includes.append(ctx.file._stdlib.dirname)

    # includes.append(ctx.file._std_exit.dirname)

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

    args.add("-o", out_exe)

    if tc_compiler(tc)[DefaultInfo].default_runfiles:
        runfiles = tc_compiler(tc)[DefaultInfo].default_runfiles
    else:
        runfiles = []

    ## action input deps sources:
    ##  a. the target attributes
    ##  b. the compiler
    ##  c. the toolchain?

    inputs_depset = depset(
        direct = []
        + [ctx.file._std_exit, ctx.file._stdlib]
        + [ctx.file.main] if ctx.file.main else []
        # compiler runfiles contain camlheader files & stdlib:
        # + ctx.files._camlheaders
        # + camlheader_deps
        + tc_compiler(tc)[DefaultInfo].files_to_run
        + runfiles
        ,
        transitive = []
        + [depset(ctx.files._camlheaders)]
        #FIXME: primitives should be provided by target, not tc?
        # + [depset([tc.primitives])] # if tc.primitives else []
        + [
            sigs_depset,
            cli_link_deps_depset,
            archived_cmx_depset
        ]
        # + data_inputs
        # + [depset(action_inputs_ccdep_filelist)]
    )

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
        # env = env,
        executable = tool,
        # executable = tc_compiler(tc)[DefaultInfo].files_to_run,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [out_exe],
        tools = [tc_compiler(tc)[DefaultInfo].files_to_run],
        # tools = [tool] + tool_args,  # [tc.ocamlopt],
        mnemonic = mnemonic,
        progress_message = "{mode} linking {rule}: {ws}//{pkg}:{tgt}".format(
            mode = tc.build_host + ">" + tc.target_host[BuildSettingInfo].value,
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
