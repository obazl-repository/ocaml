load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load(":BUILD.bzl", "progress_msg")

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
def executable_impl(ctx, exe_name):  ## , tc):

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
    (target_executor, target_emitter,
     config_executor, config_emitter,
     workdir) = get_workdir(ctx, tc)

    if target_executor == "unspecified":
        executor = config_executor
        emitter  = config_emitter
    else:
        executor = target_executor
        emitter  = target_emitter

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
    includes  = []
    # cmxa_args  = []

    ####  flags and options for bootstrapping executables

    ## some examples from mac make log:
    ## ocamldep: -nostdlib, -g, -use-prims
    ## ocamlc: -nostdlib, -use-prims, -g, -compat-32
    ## ocamlopt: -nostdlib, -use-prims, -g
    ## ocamllex: -nostdlib, -use-prims, -compat-32
    ## ocamlc.opt: -nostdlib, -g, -cclib "-lm  -lpthread"
    ## ocamlopt.opt: -nostdlib, -g
    ## ocamllex.opt: -nostdlib

    # out_exe = ctx.actions.declare_file(workdir + ctx.label.name)
    out_exe = ctx.actions.declare_file(workdir + exe_name)

    #########################
    args = ctx.actions.args()

    executable = None

    if tc.dev:
        ocamlrun = None
        effective_compiler = tc.compiler
    else:
        ocamlrun = tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list()[0]

        effective_compiler = tc_compiler(tc)[DefaultInfo].files_to_run.executable

    if tc.dev:
        build_executor = "opt"
    elif (target_executor == "unspecified"):
        if (config_executor == "sys"):
            if config_emitter == "sys":
                # ss built from ocamlopt.byte
                build_executor = "vm"
            else:
                # sv built from ocamlopt.opt
                build_executor = "sys"
        else:
            build_executor = "vm"
    elif target_executor in ["boot", "baseline", "vm"]:
        build_executor = "vm"
    elif (target_executor == "sys" and target_emitter == "sys"):
        ## ss always built by vs (ocamlopt.byte)
        build_executor = "vm"
    elif (target_executor == "sys" and target_emitter == "vm"):
        ## sv built by ss
        build_executor = "sys"

    if build_executor == "vm":
        executable = ocamlrun
        args.add(effective_compiler.path)
    else:
        executable = effective_compiler

    # ocamlrun = tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list()[0]
    # effective_compiler = tc_compiler(tc)[DefaultInfo].files_to_run.executable

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

    # if (executor in ["boot", "vm", "sys"] or ctx.attr._rule == "build_tool"):
    #     ## ocamlrun
    #     for f in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
    #         if f.basename == "ocamlrun":
    #             # print("LEX RF: %s" % f.path)
    #             executable = f
    #         # the bytecode executable
    #     args.add(tc_compiler(tc)[DefaultInfo].files_to_run.executable.path)
    # else:
    #     executable = tc_compiler(tc)[DefaultInfo].files_to_run.executable.path

    args.add("-o", out_exe)

    # use_prims = False
    # if hasattr(ctx.attr, "use_prims"):
    #     if ctx.attr.use_prims:
    #         use_prims = True
    # else:
    #     if ctx.attr._use_prims[BuildSettingInfo].value:
    #         use_prims = True

    primitives_depset = []
    # if use_prims:
    #     args.add_all(["-use-prims", ctx.file._primitives.path])
    #     primitives_depset = [depset([ctx.file._primitives])]
    # else:
    #     primitives_depset = []

    ## runtime_files are link-time deps, not to be confused with
    ## runfiles, which are runtime deps.
    runtime_files = []
    if executor == "sys":
        # only the native compilers need libasmrun
        # WARNING: if we do not add libasmrun.a as a dep here,
        # OCaml will try to link /usr/local/lib/ocaml/libasmrun.a
        # to see, pass -verbose to the ocaml_compiler.opts or use
        # --//config/ocaml/link:verbose
        print("lbl: %s" % ctx.label)
        print("exe runtime ccinfo: %s" % ctx.attr._runtime[CcInfo])
        print("exe runtime files: %s" % ctx.attr._runtime.files)
        # for f in ctx.files._runtime:
        #     runtime_files.append(f)
        #     includes.append(f.dirname)
            ## do not add to CLI - asmcomp/asmlink adds it to the
            ## OCaml cc link subcmd
            # args.add(f.path)
        print("runtime files: %s" % runtime_files)

    if ctx.attr.cc_deps:
        for f in ctx.files.cc_deps:
            runtime_files.append(f)
            includes.append(f.dirname)

    # args.add_all(tc.linkopts)

    # if ext == ".cmx":
    #     args.add("-dstartup")

    _options = get_options(rule, ctx)
    args.add_all(_options)

    if ctx.attr.cc_linkopts:
        for lopt in ctx.attr.cc_linkopts:
            if lopt == "verbose":
                # if platform == mac:
                args.add_all(["-ccopt", "-Wl,-v"])
            else:
                args.add_all(["-ccopt", lopt])

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

    if ctx.file._stdlib:
        includes.append(ctx.file._stdlib.dirname)
    # for f in ctx.files._stdlib:
    #     includes.append(f)

    # includes.append(ctx.file._std_exit.dirname)

    ##FIXME: if we're *building* a sys compiler we need to add
    ## libasmrun.a to runfiles, and if we're *using* a sys compiler we
    ## need to add libasmrun.a to inputs and add its dir to search
    ## path (-I).

    ## If we're building a vm executor tool, we need to add the
    ## ocamlrun runtime to runfiles.

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

    if (executor in ["boot", "baseline", "vm"] or ctx.attr._rule == "build_tool"):
        camlheaders = tc.camlheaders
        print("CAMLHEADERS: {lbl} {h}".format(
            lbl=ctx.label, h = camlheaders))
        includes.append(camlheaders[0].dirname)
    else:
        print("NO CAMLHEADERS for %s" % ctx.label)
        camlheaders = []

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
    # if ...:
    #     runfiles.append(ctx.file._primitives)
    # if tc_compiler(tc)[DefaultInfo].default_runfiles:
    if ocamlrun:
        runfiles.append(tc_compiler(tc)[DefaultInfo].default_runfiles)
    # else:
    #     runfiles = []

    ## action input deps sources:
    ##  a. the target attributes
    ##  b. the compiler
    ##  c. the toolchain?

    # if target is sys, add asmrun?

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
            runtime_files
            + [ctx.file._stdlib]
            # ctx.files._camlheaders
            # + ctx.files._runtime
            # + ctx.files._stdlib
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
        mnemonic = "LinkBootstrapExecutable"
    elif ctx.attr._rule == "bootstrap_repl":
        mnemonic = "LinkToplevel"
    elif ctx.attr._rule == "baseline_test":
        mnemonic = "LinkBootstrapTest"
    elif ctx.attr._rule == "ocaml_compiler":
        mnemonic = "LinkOcamlCompiler"
    elif ctx.attr._rule == "build_tool":
        mnemonic = "LinkBuildTool"
    elif ctx.attr._rule == "baseline_compiler":
        mnemonic = "LinkOcamlcKick"
    elif ctx.attr._rule == "ocaml_tool":
        mnemonic = "LinkOCamlTool"
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
            executable,
            # tc_compiler(tc)[DefaultInfo].default_runfiles.files,
            # tc_compiler(tc)[DefaultInfo].files_to_run
        ],
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
    # for rf in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
    #     if rf.short_path.startswith("stdlib"):
    #         # print("STDLIB: %s" % rf)
    #         compiler_runfiles.append(rf)
    #     if rf.path.endswith("ocamlrun"):
    #         # print("OCAMLRUN: %s" % rf)
    #         compiler_runfiles.append(rf)
    ##FIXME: add tc.stdlib, tc.std_exit
    # for f in ctx.files._camlheaders:
    #     compiler_runfiles.append(f)

    if ocamlrun:
        runfiles = [tc_compiler(tc)[DefaultInfo].default_runfiles.files]
    else:
        runfiles = []

    if ctx.attr.strip_data_prefixes:
      myrunfiles = ctx.runfiles(
        # files = ctx.files.data + compiler_runfiles + [ctx.file._std_exit],
        #   transitive_files =  depset([ctx.file._stdlib])
      )
    else:
        myrunfiles = ctx.runfiles(
            files = ctx.files.data,
            transitive_files =  depset(
                transitive = runfiles
                # direct=compiler_runfiles,
                # transitive = [depset(
                #     # [ctx.file._std_exit, ctx.file._stdlib]
                # )]
            )
        )

    ##########################
    defaultInfo = DefaultInfo(
        executable=out_exe,
        files = depset([out_exe]),
        runfiles = myrunfiles
    )

    exe_provider = None
    if ctx.attr._rule in ["ocaml_compiler"]:
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
