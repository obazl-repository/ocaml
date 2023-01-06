## inline_expect: generates a shell script that runs the inline_expect
## tool, then compares actual to expected outputs. All inputs,
## including ocamlrun, must be added to runfiles for the shell script.

## The inline_expect tool itself functions as the compiler, so it
## needs all the dependencies of the file under test; they must be
## added to runfiles too.

load("@bazel_skylib//lib:paths.bzl", "paths")
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

    ################  DEPS  ################
    depsets = new_deps_aggregator()

    includes  = []

    manifest = []

    # aggregate_deps(ctx, ctx.attr._stdlib, depsets, manifest)
    # aggregate_deps(ctx, ctx.attr._std_exit, depsets, manifest)

    open_stdlib = False
    stdlib_module_target  = None
    stdlib_library_target = None

    for dep in ctx.attr.deps:
        aggregate_deps(ctx, dep, depsets, manifest)
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
    # for dep in ctx.attr.deps:
    #     aggregate_deps(ctx, dep, depsets, manifest)

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

    #########################
    args = [] ## "#!/bin/sh"]

    # args.append("echo PATH: $PATH;")

    ## debugging
# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
# https://github.com/bazelbuild/bazel/blob/master/tools/bash/runfiles/runfiles.bash

    args.extend([
        # "set -x",
        # "echo PWD: $(PWD);",
        # "ls -la;",
        # "echo RUNFILES_DIR: $RUNFILES_DIR;",
        "set -uo pipefail; set +e;",
        "f=bazel_tools/tools/bash/runfiles/runfiles.bash ",
        "source \"${RUNFILES_DIR:-/dev/null}/$f\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"${RUNFILES_MANIFEST_FILE:-/dev/null}\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    source \"$0.runfiles/$f\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"$0.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"$0.exe.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    { echo \"ERROR: cannot find $f\"; exit 1; };", ##  f=; set -e; ",
    ])
    # --- end runfiles.bash initialization v2 ---

    args.append("if [ -x ${RUNFILES_DIR+x} ]")
    args.append("then")
    args.append("    echo \"MANIFEST: ${RUNFILES_MANIFEST_FILE}\"")
    args.append("else")
    args.append("    echo \"RUNFILES_DIR: ${RUNFILES_DIR}\"")
    args.append("fi")
    args.append("echo STDLIB: $(rlocation ocamlcc/stdlib/bin_ocamlc_byte_ocamlc_byte/Stdlib.cmo)")

    cmd_args = []
    cmd_args.append("echo PWD: $PWD;")
    cmd_args.append(tc.ocamlrun.short_path)

    executable = ctx.file._tool
    if debug:
        print("EXPECT executable: %s" % ctx.attr._tool)

    cmd_args.append(executable.short_path)

    ## inline-expect arg -repo-root - meaning?
    # cmd_args.append("-repo-root")

    ## FIXME: accomodate -use-primitives
    ## (currently we assume not needed)
    primitives_depset = []

    ## not to be confused with runfiles, which are runtime deps. but
    ## since we run the inline_expect tool, which does the linking,
    ## these linktime files must be added to runfiles (i.e. they are
    ## runfiles of the shell script we're generating).
    linktime_files = []
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
            linktime_files.append(f)
            includes.append(f.dirname)
            # cmd_args.add_all(["-ccopt", "-L" + f.dirname])

            ## do not add to CLI - asmcomp/asmlink adds it to the
            ## OCaml cc link subcmd
            # cmd_args.add(f.path)
        print("runtime files: %s" % linktime_files)
    elif "-custom" in ctx.attr.opts:
        print("lbl: %s" % ctx.label)
        print("tc.name: %s" % tc.name)
        print("EXE runtime: %s" % ctx.attr._runtime)
        print("exe runtime files: %s" % ctx.attr._runtime.files)
        for f in ctx.files._runtime:
            print("EXE runtime.path: %s" % f.path)
            linktime_files.append(f)
            # includes.append(f.dirname)
            # cmd_args.add_all(["-ccopt", "-L" + f.dirname])

    # if ctx.attr.cc_deps:
    #     for f in ctx.files.cc_deps:
    #         # cmd_args.add_all(["-ccopt", "-L" + f.path])
    #         # cmd_args.add_all(["-ccopt", f.basename])
    #         cmd_args.add(f.path)
    #         linktime_files.append(f)
    #         includes.append(f.dirname)

    # NB: These are options for the inline_expect tool. Since it
    # functions as a compiler it takes the same(?) options as
    # ocamlc.byte, plus a few others specific to the tool.
    (_options, cancel_opts) = get_options(rule, ctx)

    ## remove options that inline_expect does not understand:
    cancel_opts.extend(["-bin-annot", "-opaque", "-principal"])

    if "-pervasives" in _options:
        cancel_opts.append("-nopervasives")
        _options.remove("-pervasives")
    else:
        _options.append("-nopervasives")

    tc_opts = []

    # if not ctx.attr.nocopts:
        # for opt in tc.copts:
        #     if opt not in NEGATION_OPTS:
        #         cmd_args.add(opt)
        #     else:
        # cmd_args.add_all(tc.copts)
    tc_opts.extend(tc.copts) ## compile opts for both .ml, .mli

    # if src is .ml
    tc_opts.extend(tc.structopts) ## compile opts for .ml only

    # if src is .mli
    # tc_opts.extend(tc.sigopts)

    cmd_args.extend(_options)

    for opt in tc_opts:
        if opt not in cancel_opts:
            cmd_args.append(opt)

    ## do not use std warnings from toolchain:
    # cmd_args.extend(tc.warnings[BuildSettingInfo].value)

    for w in ctx.attr.warnings:
        cmd_args.extend(["-w",
                      w if w.startswith("-")
                      else "-" + w])

    # cmd_args.append("-nostdlib")  # always
    # cmd_args.append("-nocwd")
    ## FIXME: not all modules depend on stdlib
    if open_stdlib:
        cmd_args.append("-open")
        cmd_args.append("Stdlib")
    # cmd_args.append("-I")
    # cmd_args.append("ocamlcc/stdlib/bin_ocamlc_byte_ocamlc_byte")
    # cmd_args.append("-I")
    # cmd_args.append("stdlib/bin_ocamlc_byte_ocamlc_byte")
    # cmd_args.append("-I")

    ## NOTES: If target depends on stdlib, then we need the dirpath
    ## for the stdlib. Getting it from ctx.attr.deps will not work,
    ## since these are relative to this target, which just emits the
    ## shell script. We need a path that works for the shell script
    ## when we run it under Bazel. That's what runfiles are for - we
    ## add stdlib to runfiles when we generate the script, then when
    ## we run the script we need to path of the runfile. And that is
    ## what ctx.expand_location is for, together with "make vars", in
    ## this case '$(rootpath)'.

    ## If we passed --//config/ocaml/compiler/libs:archived, then
    ## //stdlib is one file, stdlib.cmx?a, and we use $(rootpath).
    ## Otherwise, it is the lib of cmo/x files and we use $(rootpaths).
    if stdlib_module_target:
        stdlib = ctx.expand_location("$(rootpath //stdlib:Stdlib)",
                                     targets=[stdlib_module_target])
        cmd_args.append("-I")
        cmd_args.append(paths.dirname(stdlib))
    elif stdlib_library_target:
        if ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
            stdlib = ctx.expand_location("$(rootpath //stdlib)",
                                         targets=[stdlib_library_target])
            cmd_args.append("-I")
            cmd_args.append(paths.dirname(stdlib))
        else:
            stdlibstr = ctx.expand_location("$(rootpaths //stdlib)",
                                         targets=[stdlib_library_target])
            stdlibs = stdlibstr.split(" ")
            cmd_args.append("-I")
            cmd_args.append(paths.dirname(stdlibs[0]))

    # cmd_args.append(paths.dirname(stdlib))
    # cmd_args.append("$(rlocation ocamlcc/stdlib/bin_ocamlc_byte_ocamlc_byte/Stdlib.cmo")


    # if ctx.attr.cc_linkopts:
    #     for lopt in ctx.attr.cc_linkopts:
    #         if lopt == "verbose":
    #             # if platform == mac:
    #             cmd_args.add_all(["-ccopt", "-Wl,-v"])
    #         else:
    #             cmd_args.add_all(["-ccopt", lopt])

    for path in paths_depset.to_list():
        includes.append(path)

    for inc in includes:
        cmd_args.append("-I")
        cmd_args.append(inc)

    cmd_args.append(ctx.file.src.path)
   # manifest = ctx.files.prologue

    # filtering_depset = depset(
    #     order = dsorder,
    #     direct = ctx.files.prologue, #  + [ctx.file.main],
    #     transitive = [cli_link_deps_depset]
    # )

    # for dep in filtering_depset.to_list():
    #     if dep in manifest:
    #         cmd_args.add(dep)

    mnemonic = "OcamlInlineExpectTest"

    cmd_args.append(";")
    cmd_args.extend(["diff", "-w",
                ctx.file.src.path,
                ctx.file.src.path + ".corrected;"])


    cmd = cmd_args[0]
    for arg in cmd_args[1:]:
        cmd = cmd + " \\\n" + arg

    runner = ctx.actions.declare_file(workdir + ctx.file.src.basename + ".test_runner.sh")

    ctx.actions.write(
        output  = runner,
        # content = "\n".join(args) + "\n",
        content = cmd,
        # content = "\n".join(args) + "\n" + cmd,
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
    # if ocamlrun:
    #     runfiles.append(tc.compiler[DefaultInfo].default_runfiles)
    # runfiles.append(executable)
    runfiles.append(ctx.file.src)
    # runfiles.append(ctx.file._stdlib)
    # if ocamlrun:
    #     runfiles = [tc.compiler[DefaultInfo].default_runfiles.files]
    # print("runfiles tc.compiler: %s" % tc.compiler)
    # print("runfiles tc.ocamlrun: %s" % tc.ocamlrun)
    # if tc.protocol == "dev":
    #     runfiles.append(tc.ocamlrun)
    # elif ocamlrun:
    #     runfiles.append(tc.compiler[DefaultInfo].default_runfiles.files.to_list)

    # print("EXE runfiles: %s" % runfiles)

    # if tc.config_executor in ["boot", "baseline","vm"]:
    #     # ocamlrun = exe[0].default_runfiles.files.to_list()[0]
    #     ocamlrun = tc.ocamlrun
    #     # pgm_cmd = ocamlrun.short_path + " " + pgm.short_path
    # else:
    #     ocamlrun = None
    #     # pgm_cmd = pgm.short_path


    data_runfiles = []
    # if ctx.attr.data:
    #     data_runfiles = [depset(direct = ctx.files.data)]


    inputs_depset = depset(
        direct = []
        + runfiles
        ,
        transitive = []
        + [depset(
            linktime_files
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

    if debug:
        print("EXPECT runfiles tool: %s" % ctx.attr._runfiles_tool[DefaultInfo].files)
        print("EXPECT runfiles file: %s" % ctx.files._runfiles_tool)

    # if ctx.attr.strip_data_prefixes:
    #   myrunfiles = ctx.runfiles(
    #     # files = ctx.files.data + compiler_runfiles + [ctx.file._std_exit],
    #     #   transitive_files =  depset([ctx.file._stdlib])
    #   )
    # else:
    myrunfiles = ctx.runfiles(
        files = [
            # tc.ocamlrun
            # ctx.files.data,
        ],
        transitive_files =  depset(
            transitive = [
                depset(ctx.files._runfiles_tool),
                ctx.attr._tool[DefaultInfo].default_runfiles.files,

                ## bash runfiles tool:
                ctx.attr._runfiles_tool[DefaultInfo].default_runfiles.files,
                depset(direct=runfiles),
                depset([tc.ocamlrun]),
                inputs_depset,

            sigs_depset,
            cli_link_deps_depset,
            archived_cmx_depset,
            ofiles_depset,
            afiles_depset,
                # ctx.attr._stdlib.files,
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

    providers = [
        defaultInfo,
        # exe_provider
    ]
    # print("out_exe: %s" % out_exe)
    # print("exe prov: %s" % defaultInfo)

    return providers
