## compile_dump_diff_test - tests compilation logging, not executable run

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load(":test_transitions.bzl", "test_in_transitions")

load("//bzl:providers.bzl", "DumpInfo", "ModuleInfo")

#################
def _rule_attrs(kind):
    return dict(
        test_module = attr.label(
            allow_single_file = True,
            providers = [DumpInfo]
        ),
        expected = attr.label(
            allow_single_file = True,
        ),

        verbose = attr.bool(),
        _sh_verbose = attr.label(default = "//testsuite/tests:verbose"),

        _rule = attr.string( default = "compile_dump_diff_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    )

##############################
def _compile_dump_diff_test_impl(ctx):

    runner = ctx.actions.declare_file(ctx.label.name + "_runner.sh")
    lambdafile = ctx.attr.test_module[DumpInfo].src.basename + ".fixed"
    # src_path = ctx.attr.test_module[ModuleInfo].struct_src
    # src_path = ctx.attr.test_module[DumpInfo].dump.path
    src_file = ctx.attr.test_module[DumpInfo].src
    dump_file = ctx.attr.test_module[DumpInfo].dump

    cmd_prologue = []
    # if True:  ## ctx.attr.verbose:
    if (ctx.attr.verbose
        or ctx.attr._sh_verbose[BuildSettingInfo].value):
        cmd_prologue.append("echo PWD: $(PWD);")
        cmd_prologue.append("echo SRC: %s" % src_file.path)
        cmd_prologue.append("echo ACTUAL: %s" % dump_file.path)
        cmd_prologue.append("echo EXPECTED: %s" % ctx.file.expected.path)
        cmd_prologue.append("set -x;")

    cmd_prologue.append("")

    cmd = "\n".join([
        ## strip newlines from both files, then sed the actual to
        ## remove paths, then compare, ignoring spaces
        ## assumption: whitespace is insignificant

        "cat {} | tr -d '\n' > stripped.expected.txt".format(
            ctx.file.expected.path),
        "cat {} | tr -d '\n' > stripped.txt".format(dump_file.short_path),

        "sed -e 's|{src}|{name}|g;' {dumpfile} > {lambdafile};".format(
            src    = src_file.path,
            name   = src_file.basename, # "anonymous.ml",
            dumpfile = "stripped.txt",
            lambdafile = lambdafile
        ),

        "diff -wbB {a} {b};".format(
        a = lambdafile,
        b = "stripped.expected.txt")
    ])

    cmd_epilogue = "\n".join([
        # # skip first line containing src file path - non-portable
        # "diff <(tail -n \\+2 {}) <(tail -n \\+2 compile.stdout)".format(
        #     ctx.file.expected.short_path
        # )
    ])


    ctx.actions.write(
        output  = runner,
        content = "\n".join(cmd_prologue) + cmd + cmd_epilogue,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [ctx.attr.test_module[DumpInfo].dump, ctx.file.expected]
        # transitive_files =  depset(
        #     transitive = [
        #         depset(direct=runfiles),
        #         sigs_depset
        #     ]
        # )
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]

#####################
## Inline rule definitions
def _compile_dump_diff_test_rule(kind):

    return rule(
        implementation = _compile_dump_diff_test_impl,
        doc = "Compile dumpfile diff test with {} compiler".format(kind),
        attrs = _rule_attrs(kind),
        cfg = test_in_transitions[kind],
        test = True,
        fragments = ["cpp"],
        toolchains = ["//toolchain/type:ocaml",
                      "@bazel_tools//tools/cpp:toolchain_type"])

#######################
compile_dump_diff_vv_test = _compile_dump_diff_test_rule("vv")
compile_dump_diff_vs_test = _compile_dump_diff_test_rule("vs")
compile_dump_diff_ss_test = _compile_dump_diff_test_rule("ss")
compile_dump_diff_sv_test = _compile_dump_diff_test_rule("sv")
# flambda - 'x' = optx
compile_dump_diff_xv_test = _compile_dump_diff_test_rule("xv")
compile_dump_diff_xs_test = _compile_dump_diff_test_rule("xs")
compile_dump_diff_vx_test = _compile_dump_diff_test_rule("vx")
compile_dump_diff_sx_test = _compile_dump_diff_test_rule("sx")
compile_dump_diff_xx_test = _compile_dump_diff_test_rule("xx")

###############################################################
####  MACROS - generate *_test targets
################################################################
def compile_dump_diff_test_macro(name,
                                  test_module,
                                  vm_expected = None,
                                  sys_expected = None,
                                  flambda_expected = None,
                                  tags = [],
                                  timeout = "short",
                                  **kwargs):

    if name.endswith("_test"):
        stem = name[:-5]
    else:
        stem = name

    if test_module.startswith(":"):
        test_name = test_module[1:]
    else:
        test_name = test_module
    print("test_name: %s" % test_name)

    executable = test_name + ".exe"

    vv_name = test_name + "_vv_test"
    vs_name = test_name + "_vs_test"
    ss_name = test_name + "_ss_test"
    sv_name = test_name + "_sv_test"
    # flambda executor
    xv_name = test_name + "_xv_test"  # ocamlc.optx
    xs_name = test_name + "_xs_test"  # ocamlopt.optx
    # flambda emitter
    vx_name = test_name + "_vx_test"  # ocamloptx.byte
    sx_name = test_name + "_sx_test"  # ocamloptx.opt
    # flambda executor & emitter
    xx_name = test_name + "_xx_test"  # ocamloptx.optx

    native.test_suite(
        name  = stem + "_test",
        tests = [vv_name, vs_name, ss_name, sv_name,
                 xv_name, xs_name, vx_name, sx_name,
                 xx_name]
    )

    if vm_expected:
        compile_dump_diff_vv_test(
            name = vv_name,
            test_module = test_module,
            expected = vm_expected,
            timeout = timeout,
            tags = ["vv", "dump"] + tags,
            **kwargs
        )
        compile_dump_diff_sv_test(
            name = sv_name,
            test_module = test_module,
            expected = vm_expected,
            timeout = timeout,
            tags = ["sv", "dump"] + tags,
            **kwargs
        )
        if flambda_expected:
            compile_dump_diff_xv_test(
                name = xv_name,
                test_module = test_module,
                expected = vm_expected,
                timeout = timeout,
                tags = ["xv", "flambda", "dump"] + tags,
                **kwargs
            )

    if sys_expected:
        compile_dump_diff_ss_test(
            name = ss_name,
            test_module = test_module,
            expected = sys_expected,
            timeout = timeout,
            tags = ["ss", "dump"] + tags,
            **kwargs
        )
        compile_dump_diff_vs_test(
            name = vs_name,
            test_module = test_module,
            expected = sys_expected,
            timeout = timeout,
            tags = ["vs", "dump"] + tags,
            **kwargs
        )
        if flambda_expected:
            compile_dump_diff_xs_test(
                name = xs_name,
                test_module = test_module,
                expected = sys_expected,
                timeout = timeout,
                tags = ["vs", "dump"] + tags,
                **kwargs
            )

    if flambda_expected:
        compile_dump_diff_vx_test(
            name = vx_name,
            test_module = test_module,
            expected = flambda_expected,
            timeout = timeout,
            tags = ["flambda", "vx", "dump"] + tags,
            **kwargs
        )
        compile_dump_diff_sx_test(
            name = sx_name,
            test_module = test_module,
            expected = flambda_expected,
            timeout = timeout,
            tags = ["flambda", "sx", "dump"] + tags,
            **kwargs
        )
        compile_dump_diff_xx_test(
            name = xx_name,
            test_module = test_module,
            expected = flambda_expected,
            timeout = timeout,
            tags = ["flambda", "xx", "dump"] + tags,
            **kwargs
        )
