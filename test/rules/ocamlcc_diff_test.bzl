## ocamlcc_diff_test - diff actuals of test_module v. expected
## macro - generates one test target per compiler

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:functions.bzl", "filestem")

load(":test_transitions.bzl", "test_in_transitions")

load("//bzl:providers.bzl", "DumpInfo", "ModuleInfo")

####################
def runfiles_bash(ctx):
# https://github.com/bazelbuild/bazel/blob/master/tools/bash/runfiles/runfiles.bash
    args = []
# --- begin runfiles.bash initialization v2 ---
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

    if (ctx.attr.verbose):
        args.append("if [ -x ${RUNFILES_DIR+x} ]")
        args.append("then")
        args.append("    echo \"MANIFEST: ${RUNFILES_MANIFEST_FILE}\"")
        args.append("else")
        args.append("    echo \"RUNFILES_DIR: ${RUNFILES_DIR}\"")
        # args.append("    echo \"MANIFEST: ${RUNFILES_MANIFEST_FILE}\"")
        args.append("fi")

    return args

##############################
def _ocamlcc_diff_test_impl(ctx):

    runner = ctx.actions.declare_file(ctx.label.name + "_runner.sh")
    expected  = ctx.file.expected
    actual  = ctx.file.actual
    actual_basename = actual.basename
    actual_stem     = filestem(actual)

    if not expected:
        fail("Not yet supported: expected == None")

    cmd_prologue = runfiles_bash(ctx)
    # if True:  ## ctx.attr.verbose:
    if (ctx.attr.verbose
        or ctx.attr._sh_verbose[BuildSettingInfo].value):
        cmd_prologue.append("echo PWD: $(PWD);")
        cmd_prologue.append("echo EXPECTED: %s" % expected.path)
        cmd_prologue.append("echo ACTUAL: %s" % actual.path)
        cmd_prologue.append("echo ACTUAL short: %s" % actual.short_path)
        cmd_prologue.append("echo ACTUAL stem: %s" % actual_stem)
        cmd_prologue.append("set -x;")

    cmd_prologue.append("")

    stripped_expected = expected.basename + ".stripped"
    normalized_expected = expected.basename + ".normalized"

    stripped_actual   = actual.basename + ".stripped"
    normalized_actual   = actual.basename + ".normalized"

    cmd = "\n".join([
        ## strip newlines from both files, then sed the actual to
        ## remove paths, then compare, ignoring spaces
        ## assumption: whitespace is insignificant

        "cat {expected} | tr -d '\\n' > {nexpected}".format(
            expected=expected.short_path,
            nexpected=stripped_expected
        ),
        # "echo \"EXPECTED (STRIPPED): `cat {}`\"".format(stripped_expected),

        "cat {actual} | tr -d '\\n' > {nactual}".format(
            actual=actual.short_path,
            nactual=stripped_actual
        ),
        # "echo \"ACTUAL (STRIPPED): `cat {}`\"".format(stripped_actual),

        ## normalize file name (strip path)
        # "echo PATH: {};".format(actual.path),
        # "P=\"$(rlocation ocamlcc/testsuite/tests/warnings/deprecated_module.ml.stderr)\"",

        # "echo P: $P",
        # "PDIR=$(dirname $P)",
        # "echo PDIR: $PDIR",

        # "sed -e \"s|$P|{bname}|g;\" {actual} > {fixed};".format(

        "sed -e \"s|File \\\"[^\\\"]*\\\",|File \\\"{bname}\\\",|g;\" {actual} > {fixed};".format(
            # fpath  = "$P,  # actual.path,
            bname  = actual_stem, # e.g. "anonymous.ml",
            actual = stripped_actual,
            fixed  = normalized_actual
        ),

        # "echo \"ACTUAL (NORM): `cat {}`\"".format(normalized_actual),

        "diff -wbB {a} {b};".format(
            a = stripped_expected,
            b = normalized_actual
        )
    ])

    cmd_epilogue = "\n".join([
        # # skip first line containing src file path - non-portable
        # "diff <(tail -n \\+2 {}) <(tail -n \\+2 compile.stdout)".format(
        #     ctx.file.expected.short_path
        # )
    ])

    ctx.actions.write(
        output  = runner,
        # content = "\n".join(cmd_prologue),
        content = "\n".join(cmd_prologue) + cmd + cmd_epilogue,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [
            # ctx.attr.test_module[DumpInfo].dump,
            ctx.file.expected,
            ctx.file.actual
        ],
        transitive_files =  depset(
            transitive = []
            + [ctx.attr._runfiles_bash[DefaultInfo].files]
            + [ctx.attr._runfiles_bash[DefaultInfo].default_runfiles.files]
        )
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]

################
def _in_transition_impl(settings, attr):
    debug = False

    if debug:
        print("ocamlcc_diff_test in transition")
        print("attr.compiler: %s" % attr.compiler)
        fail()

    if attr.compiler == "ocamlc.byte":
        compiler = "@dev//bin:ocamlc.byte"
        runtime  = "@dev//lib:camlrun"
    elif attr.compiler == "ocamlopt.opt":
        compiler = "@dev//bin:ocamlopt.opt"
        runtime  = "@dev//lib:asmrun"
    elif attr.compiler == "ocamlc.opt":
        compiler = "@dev//bin:ocamlc.opt"
        runtime  = "@dev//lib:camlrun"
    elif attr.compiler == "ocamlopt.byte":
        compiler = "@dev//bin:ocamlopt.byte"
        runtime  = "@dev//lib:asmrun"

    elif attr.compiler == "ocamloptx.byte":
        compiler = "@dev//bin:ocamloptx.byte"
        runtime  = "@dev//lib:asmrun"
    elif attr.compiler == "ocamloptx.opt":
        compiler = "@dev//bin:ocamloptx.opt"
        runtime  = "@dev//lib:asmrun"
    elif attr.compiler == "ocamloptx.optx":
        compiler = "@dev//bin:ocamloptx.optx"
        runtime  = "@dev//lib:asmrun"

    return {
        # "//config/build/protocol" : "test",
        # "//config/target/executor": config_executor,
        # "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"    : compiler,
        "//toolchain:runtime"     : runtime
        # "//toolchain:ocamlrun"    : settings["//toolchain:ocamlrun"],
    }

_in_transition = transition(
    implementation = _in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/ocaml/compiler",
        "//toolchain:runtime",
    ],
    outputs = [
        # "//config/build/protocol",
        # "//config/target/executor",
        # "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
    ]
)

#########################
ocamlcc_diff_test = rule(
    implementation = _ocamlcc_diff_test_impl,
    doc = "Diff expected v. actual files",
    attrs = dict(
        compiler = attr.string(
            doc = "ocamlc.byte | ocamlopt.opt | etc."
        ),
        expected = attr.label(allow_single_file = True),
        actual = attr.label(allow_single_file = True),

        verbose = attr.bool(),
        _sh_verbose = attr.label(default = "//testsuite/tests:verbose"),

        _runfiles_bash = attr.label(
            allow_single_file = True,
            default = "@bazel_tools//tools/bash/runfiles"
        ),

        _rule = attr.string( default = "compile_dump_diff_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = _in_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
## MACRO
################################################################
def test_name(name, compiler):
    if compiler == "ocamlc.byte":
        name = name + "_vv_test"
    elif compiler == "ocamlc.opt":
        name = name + "_sv_test"
    elif compiler == "ocamlopt.opt":
        name = name + "_ss_test"
    elif compiler == "ocamlopt.byte":
        name = name + "_vs_test"

    elif compiler == "ocamloptx.optx":
        name = name + "_xx_test"
    elif compiler == "ocamloptx.opt":
        name = name + "_sx_test"
    elif compiler == "ocamloptx.byte":
        name = name + "_vx_test"
    return name

std_compilers = ["ocamlc.byte", "ocamlc.opt",
                 "ocamlopt.byte", "ocamlopt.opt",
                 "ocamloptx.byte","ocamloptx.opt",
                 "ocamloptx.optx"]

################################################################
def ocamlcc_diff_tests(name,
                       actual,
                       expected = None,
                       compilers = std_compilers,
                       timeout = "short",
                       **kwargs):

    if name.endswith("_tests"):
        stem = name[:-6]
    else:
        fail("ocamlcc_diff_tests: name must end with '_tests'; actual: {}".format(name))

    tests = []

    for compiler in compilers:
        if compiler not in std_compilers:
            fail("Unrecognized compiler: {c}. Valid compiler names: {cs}".format(
                c = compiler, cs=std_compilers
            ))
        tname = test_name(stem, compiler)
        tests.append(tname)
        ocamlcc_diff_test(
            name     = tname,
            compiler = compiler,
            expected = expected,
            actual   = actual,
            timeout  = timeout,
            **kwargs
        )

    native.test_suite(
        name = name,
        tests = tests
    )
