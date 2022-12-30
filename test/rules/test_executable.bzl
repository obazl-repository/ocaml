load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

load(":test_transitions.bzl",
     "vv_test_in_transition",
     "vs_test_in_transition",
     "ss_test_in_transition",
     "sv_test_in_transition")

##############################
def _test_executable_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    # if tc.config_executor in ["boot", "vm"]:
    #     ext = ".byte"
    # else:
    #     ext = ".opt"

    exe_name = ctx.label.name

    return executable_impl(ctx, tc, exe_name, workdir)

#######################
vv_test_executable = rule(
    implementation = _test_executable_impl,
    doc = "Links OCaml executable binary using ocamlc.byte",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_executable" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    # cfg = dev_tc_compiler_out_transition,
    cfg = vv_test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
vs_test_executable = rule(
    implementation = _test_executable_impl,
    doc = "Links OCaml executable binary using ocamlopt.byte",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_executable" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = vs_test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
ss_test_executable = rule(
    implementation = _test_executable_impl,
    doc = "Links OCaml executable binary using ocamlopt.opt",
    attrs = dict(
        ##FIXME: remove prologue, epilogue
        executable_attrs(),
        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_executable" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    # cfg = dev_tc_compiler_out_transition,
    cfg = ss_test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

#######################
sv_test_executable = rule(
    implementation = _test_executable_impl,
    doc = "Links OCaml executable binary using ocamlc.opt",
    attrs = dict(
        executable_attrs(),
        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        #     # cfg = reset_cc_config_transition ## only build once
        #     # default = "//config/runtime" # label flag set by transition
        # ),
        _rule = attr.string( default = "test_executable" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = sv_test_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

###############################################################
####  MACRO - generates two exec targets, vm and sys
################################################################
def test_executable(name, main,
                    opts = [],
                    **kwargs):

    if main.startswith(":"):
        main = main[1:]
    else:
        main = main

    vv_test_executable(
        name    = main + ".vv.byte",
        main    = main,
        opts    = opts,  ##  + ["-pervasives"],
        # prologue = ["//stdlib"],
        tags = ["test_exe"],
        **kwargs
    )

    native.sh_binary(
        name = main + ".vv.byte.sh",
        srcs = ["//test/rules:test_executable.sh"],
        env  = select({
            "//test:verbose?": {"VERBOSE": "true"},
            "//conditions:default": {"VERBOSE": "false"}
        }),
        args = ["$(rootpath //runtime:ocamlrun)",
                "$(rootpath :{}.vv.byte)".format(name),
                # "$(rlocationpath //stdlib:stdlib)"
                ],
        data = [
            "//runtime:ocamlrun",
            ":{}.vv.byte".format(name),
            # "//stdlib",
            # "//stdlib:Std_exit",
            # "//config/camlheaders",
        ],
        deps = [
            # for the runfiles lib used in ocamlc.sh:
            "@bazel_tools//tools/bash/runfiles"
        ]
    )

    vs_test_executable(
        name    = main + ".vs.opt",
        main    = main,
        tags    = ["test_exe"],
        **kwargs
    )

    ss_test_executable(
        name    = main + ".ss.opt",
        main    = main,
        tags = ["test_exe"],
        **kwargs
    )

    sv_test_executable(
        name    = main + ".sv.byte",
        main    = main,
        tags    = ["test_exe"],
        **kwargs
    )

    native.sh_binary(
        name = main + ".sv.byte.sh",
        srcs = ["//test/rules:test_executable.sh"],
        env  = select({
            "//test:verbose?": {"VERBOSE": "true"},
            "//conditions:default": {"VERBOSE": "false"}
        }),
        args = ["$(rootpath //runtime:ocamlrun)",
                "$(rootpath :{}.sv.byte)".format(name),
                # "$(rlocationpath //stdlib:stdlib)"
                ],
        data = [
            "//runtime:ocamlrun",
            ":{}.sv.byte".format(name),
            # "//stdlib",
            # "//stdlib:Std_exit",
            # "//config/camlheaders",
        ],
        deps = [
            # for the runfiles lib used in ocamlc.sh:
            "@bazel_tools//tools/bash/runfiles"
        ]
    )

