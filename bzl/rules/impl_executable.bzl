load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "BootInfo",
     "DepsAggregator",
     "new_deps_aggregator",

     "CompilationModeSettingProvider",
     "OcamlArchiveProvider",
     "OcamlExecutableMarker",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlNsMarker",
     "OcamlSignatureProvider",
     "OcamlTestMarker")

load(":impl_ccdeps.bzl", "link_ccdeps", "dump_CcInfo")

load(":impl_common.bzl", "dsorder", "opam_lib_prefix")

load(":options.bzl",
     # "options",
     # "options_executable",
     "get_options")

load(":DEPS.bzl",
     "aggregate_deps",
     "merge_depsets",
     "COMPILE", "LINK", "COMPILE_LINK")

###############################
def impl_executable(ctx):

    scope = ""

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    debug = False
    # if ctx.label.name == "test":
        # debug = True

    # print("++ EXECUTABLE {}".format(ctx.label))

    if debug:
        print("EXECUTABLE TARGET: {kind}: {tgt}".format(
            kind = ctx.attr._rule,
            tgt  = ctx.label.name
        ))

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    manifest = []

    if ctx.attr.main:
        depsets = aggregate_deps(ctx, ctx.attr.main, depsets, manifest)

    for dep in ctx.attr.prologue:
        aggregate_deps(ctx, dep, depsets, manifest)

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

    out_exe = ctx.actions.declare_file(scope + ctx.label.name)

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

    if ctx.attr.use_prims:
        # ps = tc.primitives[DefaultInfo].files.to_list()
        # print("P: %s" % ps[0])
        args.add_all(["-use-prims", tc.primitives.path])

    # args.add_all(tc.linkopts)

    _options = get_options(rule, ctx)
    args.add_all(_options)

    if ctx.attr.warnings == [  ]:
        args.add_all(ctx.attr.warnings)
    else:
        args.add_all(tc.warnings[BuildSettingInfo].value)

    data_inputs = []
    if ctx.attr.data:
        data_inputs = [depset(direct = ctx.files.data)]
        # for f in ctx.files.data:
        #     includes.append(f.dirname)

    includes = []
    for path in paths_depset.to_list():
        includes.append(path)

    includes.append(ctx.file._stdlib.dirname)
    includes.append(ctx.file._std_exit.dirname)

    args.add_all(includes, before_each="-I", uniquify=True)

    ## To get cli args in right order, we need then merged depset of
    ## all deps. Then we use the manifest to filter.

    manifest = ctx.files.prologue

    filtering_depset = depset(
        order = dsorder,
        direct = ctx.files.prologue, #  + [ctx.file.main],
        transitive = [cli_link_deps_depset]
    )

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

    if tc.compiler[DefaultInfo].default_runfiles:
        runfiles = tc.compiler[DefaultInfo].default_runfiles
    else:
        runfiles = []

    # if ctx.label.name == "compiler":
    # print("sigs_depset: %s" % sigs_depset)
    # print("cli_link_deps_depset: %s" % cli_link_deps_depset)
    # print("ctx.file._stdlib: %s" % ctx.file._stdlib)
    # print("ctx.file._std_exit: %s" % ctx.file._std_exit)
    # print("runfiles: %s" % tc.compiler[DefaultInfo].default_runfiles.files)

    inputs_depset = depset(
        direct = []
        + [ctx.file._std_exit, ctx.file._stdlib]
        + [ctx.file.main] if ctx.file.main else []
        # compiler runfiles contain camlheader files:
        + runfiles
        ,
        transitive = []
        + [depset([tc.primitives])] # if tc.primitives else []
        + [
            sigs_depset,
            cli_link_deps_depset,
            archived_cmx_depset
        ]
        + data_inputs
        # + [depset(action_inputs_ccdep_filelist)]
    )

    # for dep in inputs_depset.to_list():
    #     print("XDEP: %s" % dep)

    if ctx.attr._rule == "boot_executable":
        mnemonic = "CompileBootstrapExecutable"
    elif ctx.attr._rule == "bootstrap_repl":
        mnemonic = "CompileToplevel"
    elif ctx.attr._rule == "bootstrap_test":
        mnemonic = "CompileBootstrapTest"

    elif ctx.attr._rule == "boot_compiler":
        mnemonic = "CompileOcamlcBoot"
    else:
        fail("Unknown rule for executable: %s" % ctx.attr._rule)

    ################
    ctx.actions.run(
        # env = env,
        executable = tc.compiler[DefaultInfo].files_to_run,
        # executable = tool,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [out_exe],
        tools = [tc.compiler[DefaultInfo].files_to_run],
        # tools = [tool] + tool_args,  # [tc.ocamlopt],
        mnemonic = mnemonic,
        progress_message = "{mode} linking {rule}: {ws}//{pkg}:{tgt}".format(
            mode = tc.build_host + ">" + tc.target_host,
            rule = ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else "", ## ctx.workspace_name,
            pkg = ctx.label.package,
            tgt = ctx.label.name,
        )
    )
    ################

    #### RUNFILE DEPS ####

    compiler_runfiles = []
    for rf in tc.compiler[DefaultInfo].default_runfiles.files.to_list():
        if rf.short_path.startswith("stdlib"):
            compiler_runfiles.append(rf)

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
    if ctx.attr._rule == "boot_compiler":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "boot_executable":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "bootstrap_repl":
        exe_provider = OcamlExecutableMarker()
    elif ctx.attr._rule == "bootstrap_test":
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
