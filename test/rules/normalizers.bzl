## ocamlcc_diff_test - diff actual v. expected
## macro - generates one test target per compiler

load("@bazel_skylib//lib:paths.bzl", "paths")

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:functions.bzl", "filestem")

load(":test_transitions.bzl", "test_in_transitions")

load("//bzl:providers.bzl", "DumpInfo", "ModuleInfo", "BootInfo")

################
def _in_transition_impl(settings, attr):
    debug = False

    if debug:
        print("normalize in transition")
        print("attr.compiler: %s" % attr.compiler)
        fail()

    if not attr.compiler:
        return {} # no transition

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

    else:
        fail("Unrecognized compiler: %s" % attr.compiler)

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

##############################
def _test_stdlog_normalize_impl(ctx):

    # expo = expected out file
    (expo_base,expo_ext
     ) = paths.split_extension(ctx.outputs.expected_out.basename)
    if expo_base != ctx.file.expected.basename:
        fail("expected_out stem must equal expected basename; got {a} and {b}".format(a=expo_base, b = ctx.file.expected.basename))

    (actual_base, actual_ext
     ) = paths.split_extension(ctx.outputs.actual_out.basename)
    if actual_base != ctx.file.actual.basename:
        fail("actual_out stem must equal actual basename; got {a} and {b}".format(a=actual_base, b = ctx.file.actual.basename))

    cmd_prologue = []
    if (ctx.attr.verbose
        or ctx.attr._sh_verbose[BuildSettingInfo].value):
        cmd_prologue.append("echo PWD: $(PWD);")
        cmd_prologue.append("echo EXPECTED: %s" % ctx.file.expected.path)
        cmd_prologue.append("echo ACTUAL: %s" % ctx.file.actual.path)
        # cmd_prologue.append("echo ACTUAL short: %s" % ctx.file.actual.short_path)
        # cmd_prologue.append("echo ACTUAL stem: %s" % ctx.file.actual_stem)
        cmd_prologue.append("set -x;")

    # stripped_expected = expected.basename + ".stripped"
    # normalized_expected = expected.basename + ".normalized"

    # stripped_actual   = actual.basename + ".stripped"
    # normalized_actual   = actual.basename + ".normalized"
    # awked_actual   = actual.basename + ".awked"

    # actual_normalized=ctx.actions.declare_file(
    #     ctx.file.actual.basename + ctx.attr.ext)
    # expected_normalized=ctx.actions.declare_file(
    #     ctx.file.expected.basename + ctx.attr.ext)

    (actual_base,actual_ext)=paths.split_extension(ctx.file.actual.basename)

    # actual_stripped = ctx.file.actual.basename + ".stripped"
    actual_stripped = ctx.actions.declare_file(ctx.file.actual.basename + ".stripped")

    ctx.actions.run_shell(
        inputs    = [ctx.file.actual,
                     ctx.file.expected],
        outputs   = [ctx.outputs.actual_out,
                     actual_stripped,
                     ctx.outputs.expected_out],
        command = "\n".join([
            # "set -x;",

            "cat {actual} | tr -d '\\n' > {actual_stripped}".format(
                actual = ctx.file.actual.path,
                actual_stripped = actual_stripped.path
            ),

            # "awk \\",
            # "'match($0, /bazel-[^/]+([^/]+\\/)*/) {{print \"{bn2}\"; next }}".format(
            # # "'/bazel-/ {{ sub(/bazel-.*{bn1}/, \"{bn2}\") }}".format(
            #     bn1 = actual_base, bn2 = actual_base),
            # "!/bazel-/ {{print}}' \\",

            "sed -e 's|bazel-[^/]*/\\([^/ ]*/\\)*{bn}|{bn}|g' {src} 1> {dst}".format(
                bn = actual_base,
            src = actual_stripped.path, # ctx.file.actual.path,
            # src = actual_awked, # ctx.file.actual.path,
            dst = ctx.outputs.actual_out.path
            # dst = ctx.file.actual.short_path + ".awked",
            ),


            "cat {expected} | tr -d '\\n' 1> {expected_norm}".format(
                expected = ctx.file.expected.path,
                expected_norm = ctx.outputs.expected_out.path
            ),

        ]),
        mnemonic = "NormalizeStdlog",
        # arguments = [],
        # tools = ["awk"],
        # progress_message = progress_msg(workdir, ctx)
    )

    # myrunfiles = ctx.runfiles(
    #     files = [
    #         # ctx.attr.test_module[DumpInfo].dump,
    #         ctx.file.stderr_expected,
    #         ctx.file.stderr_actual
    #     ],
    #     transitive_files =  depset(
    #         transitive = []
    #         + [ctx.attr._runfiles_bash[DefaultInfo].files]
    #         + [ctx.attr._runfiles_bash[DefaultInfo].default_runfiles.files]
    #     )
    # )

    defaultInfo = DefaultInfo(
        # executable=runner,
        files = depset([
            ctx.outputs.expected_out,
            ctx.outputs.actual_out,
            actual_stripped
        ]),
        # runfiles = myrunfiles
    )

    return [defaultInfo]

#########################
test_stdlog_normalize = rule(
    implementation = _test_stdlog_normalize_impl,
    doc = "Normalize expected v. actual files, for diffing",
    attrs = dict(
        # compiler = attr.string(
        #     doc = "ocamlc.byte | ocamlopt.opt | etc."
        # ),

        expected = attr.label(
            mandatory = True,
            allow_single_file = True
        ),
        expected_out = attr.output(mandatory = True),

        actual = attr.label(
            mandatory = True,
            allow_single_file = True
        ),
        actual_out = attr.output(mandatory = True),

        # ext = attr.string(default = ".norm"),

        # for test_run_program outputs:
        # stdout_expected = attr.label(allow_single_file = True),
        # stdout_actual = attr.label(allow_single_file = True),

        # # for test_module and test_signature stderr outputs:
        # stderr_expected = attr.label(allow_single_file = True),
        # stderr_actual = attr.label(allow_single_file = True),

        # # test_module, test_signature -d logging outputs (e.g. -dlambda):
        # stdlog_expected = attr.label(allow_single_file = True),
        # stdlog_actual = attr.label(allow_single_file = True),

        verbose = attr.bool(),
        _sh_verbose = attr.label(default = "//testsuite/tests:verbose"),

        _runfiles_bash = attr.label(
            allow_single_file = True,
            default = "@bazel_tools//tools/bash/runfiles"
        ),

        _rule = attr.string( default = "compile_dump_diff_test" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = _in_transition,
    # test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _test_stderr_normalize_impl(ctx):

    cmd_prologue = []
    if (ctx.attr.verbose
        or ctx.attr._sh_verbose[BuildSettingInfo].value):
        cmd_prologue.append("echo PWD: $(PWD);")
        cmd_prologue.append("echo EXPECTED: %s" % ctx.file.expected.path)
        cmd_prologue.append("echo ACTUAL: %s" % ctx.file.actual.path)
        # cmd_prologue.append("echo ACTUAL short: %s" % ctx.file.actual.short_path)
        # cmd_prologue.append("echo ACTUAL stem: %s" % ctx.file.actual_stem)
        cmd_prologue.append("set -x;")

    # stripped_expected = expected.basename + ".stripped"
    # normalized_expected = expected.basename + ".normalized"

    # stripped_actual   = actual.basename + ".stripped"
    # normalized_actual   = actual.basename + ".normalized"
    # awked_actual   = actual.basename + ".awked"

    # actual_normalized=ctx.actions.declare_file(
    #     ctx.file.actual.basename + ctx.attr.ext)
    # expected_normalized=ctx.actions.declare_file(
    #     ctx.file.expected.basename + ctx.attr.ext)


    if ctx.file.src:
        actual_base = ctx.file.src.basename
    else:
        (actual_base,actual_ext)=paths.split_extension(ctx.file.actual.basename)

    ctx.actions.run_shell(
        inputs    = [ctx.file.actual,
                     ctx.file.expected],
        outputs   = [ctx.outputs.actual_out,
                     ctx.outputs.expected_out],
        command = "\n".join([
            # "set -x;",
            ## use awk to remove srcfile paths from actual,
            ## then strip newlines from both files
            "awk '/File / {{ gsub(/File \"[^\"]*\",/, \"File \\\"{fname}\\\",\")}}".format(fname = actual_base),
            "{ print }' \\",
            "{} \\".format(ctx.file.actual.path),
            "1> actual_fixed ;",

            "cat {expected} | tr -d '\\n' 1> {expected_norm}".format(
                expected = ctx.file.expected.path,
                expected_norm = ctx.outputs.expected_out.path
            ),

            "cat actual_fixed | tr -d '\\n' > {actual_norm}".format(
                actual_norm = ctx.outputs.actual_out.path
            )
        ]),
        mnemonic = "NormalizeStderrs",
        # arguments = [],
        # tools = ["awk"],
        # progress_message = progress_msg(workdir, ctx)
    )

    # myrunfiles = ctx.runfiles(
    #     files = [
    #         # ctx.attr.test_module[DumpInfo].dump,
    #         ctx.file.stderr_expected,
    #         ctx.file.stderr_actual
    #     ],
    #     transitive_files =  depset(
    #         transitive = []
    #         + [ctx.attr._runfiles_bash[DefaultInfo].files]
    #         + [ctx.attr._runfiles_bash[DefaultInfo].default_runfiles.files]
    #     )
    # )

    defaultInfo = DefaultInfo(
        # executable=runner,
        files = depset([
            ctx.outputs.expected_out,
            ctx.outputs.actual_out
        ]),
        # runfiles = myrunfiles
    )

    return [defaultInfo]

#########################
test_stderr_normalize = rule(
    implementation = _test_stderr_normalize_impl,
    doc = "Normalize expected v. actual files, for diffing",
    attrs = dict(
        compiler = attr.string(
            doc = "ocamlc.byte | ocamlopt.opt | etc."
        ),
        src = attr.label(
            #??? mandatory = True,
            allow_single_file = True
        ),

        expected = attr.label(
            mandatory = True,
            allow_single_file = True
        ),
        expected_out = attr.output(),

        actual = attr.label(
            mandatory = True,
            allow_single_file = True
        ),
        actual_out = attr.output(),

        ext = attr.string(default = ".norm"),

        # for test_run_program outputs:
        # stdout_expected = attr.label(allow_single_file = True),
        # stdout_actual = attr.label(allow_single_file = True),

        # # for test_module and test_signature stderr outputs:
        # stderr_expected = attr.label(allow_single_file = True),
        # stderr_actual = attr.label(allow_single_file = True),

        # # test_module, test_signature -d logging outputs (e.g. -dlambda):
        # stdlog_expected = attr.label(allow_single_file = True),
        # stdlog_actual = attr.label(allow_single_file = True),

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
    # test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
# genrule(
#     name = "W01_norm_gen",
#     outs = [
#         "w01.compilers.reference.norm",
#         "w01.ml.stderr.norm",
#     ],
#     srcs = [
#         "w01.compilers.reference",
#         ":w01.ml.stderr",
#     ],
#     cmd  = "\n".join([
#         "set -x;",
#         ## use awk to remove srcfile paths from actual,
#         ## then strip newlines from both files
#         "awk '/File / { gsub(/File \"[^\"]*\",/, \"File \\\"w01.ml\\\",\")}",
#         "{ print }' \\",
#         "$(location :w01.ml.stderr) \\",
#         "1> fixed.stderr ;",

#         "cat $(location w01.compilers.reference) | tr -d '\\n' 1> $(location w01.compilers.reference.norm)",

#         "cat fixed.stderr | tr -d '\\n' > $(location w01.ml.stderr.norm)"
#     ]),
# )
