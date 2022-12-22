load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

load(":ocaml_boot_transitions.bzl",
     "boot_ocamlc_byte_in_transition",
     "boot_ocamlopt_byte_in_transition",
     "boot_ocamlopt_opt_in_transition",
     "boot_ocamlc_opt_in_transition")

##############################
def _boot_ocamlc_byte_impl(ctx):

    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule ocamlc_byte must end in '.byte'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlc.byte", tc.workdir)

#####################
boot_ocamlc_byte = rule(
    implementation = _boot_ocamlc_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlc_byte" ),
    ),
    cfg = boot_ocamlc_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _boot_ocamlopt_byte_impl(ctx):

    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule ocamlopt_byte must end in '.byte'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlopt.byte", tc.workdir)

#####################
boot_ocamlopt_byte = rule(
    implementation = _boot_ocamlopt_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlopt_byte" ),
    ),
    cfg = boot_ocamlopt_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _boot_ocamlopt_opt_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule ocamlopt_opt must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlopt.opt", tc.workdir)

#####################
boot_ocamlopt_opt = rule(
    implementation = _boot_ocamlopt_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlopt_opt" ),
    ),
    cfg = boot_ocamlopt_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _boot_ocamlc_opt_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule ocamlc_opt must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlc.opt", tc.workdir)

#####################
boot_ocamlc_opt = rule(
    implementation = _boot_ocamlc_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlc_opt" ),
    ),
    cfg = boot_ocamlc_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
def _boot_import_vm_executable(ctx):

    tool = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.symlink(output = tool,
                        target_file = ctx.file.tool)

    runfiles = ctx.runfiles(
        files = [ctx.file._ocamlrun]
    )

    defaultInfo = DefaultInfo(
        executable = tool,
        runfiles   = runfiles
    )
    return defaultInfo

#####################
boot_import_vm_executable = rule(
    implementation = _boot_import_vm_executable,

    doc = "Imports a precompiled vm executble and the executor (ocamlrun) needed to run it.",

    attrs = dict(
        tool = attr.label(
            allow_single_file = True,
        ),
        _ocamlrun = attr.label(
            allow_single_file = True,
            default = "//runtime:ocamlrun",
            executable = True,
            # cfg = "exec"
            cfg = reset_cc_config_transition
        ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
    ),
    # executable = True,
    # cfg = exec
)

################################################################
####  MACRO
################################################################
def boot_ocaml_compilers(name,
                         visibility = ["//visibility:public"],
                         **kwargs):

    boot_ocamlc_byte(
        name = "ocamlc.byte",
        stdlib   = "//stdlib",
        prologue = [
            "//compilerlibs:ocamlcommon",
            "//bytecomp:ocamlbytecomp"
        ],
        main = "//driver:Main",
        opts = [ ] + select({
            # ocamlc.byte: ["-compat-32"]
        "//conditions:default": []
        }) + [
        ] + select({
            "//platform/target/os:linux?": [
                "-cclib", "-lm",
                "-cclib", "-ldl",
                "-cclib", "-lpthread",
            ],
            "//conditions:default": []
        }),
        visibility             = ["//visibility:public"]
    )

    boot_ocamlopt_byte(
        name = "ocamlopt.byte",
        # stdlib   = "//stdlib",
    prologue = [
        "//compilerlibs:ocamlcommon",
        "//asmcomp:ocamloptcomp"
    ],
        main = "//driver:Optmain",
        opts = [ ] + select({
            # ocamlc.byte: ["-compat-32"]
        "//conditions:default": []
        }) + [
        ] + select({
            "//platform/target/os:linux?": [
                "-cclib", "-lm",
                "-cclib", "-ldl",
                "-cclib", "-lpthread",
            ],
            "//conditions:default": []
        }),
        visibility             = ["//visibility:public"]
    )

    boot_ocamlopt_opt(
        name = "ocamlopt.opt",
        stdlib   = "//stdlib",
        prologue = [
            "//compilerlibs:ocamlcommon",
            "//asmcomp:ocamloptcomp"
        ],
        main = "//driver:Optmain",
        opts = [ ] + select({
            "//platform/target/os:linux?": [
                "-cclib", "-lm",
                "-cclib", "-ldl",
                "-cclib", "-lpthread",
            ],
            "//conditions:default": []
        }),
        visibility             = ["//visibility:public"]
    )

    boot_ocamlc_opt(
        name = "ocamlc.opt",
        stdlib   = "//stdlib",
        prologue = [
            "//compilerlibs:ocamlcommon",
            "//bytecomp:ocamlbytecomp"
        ],
        main = "//driver:Main",
        opts = [ ] + select({
            "//platform/target/os:linux?": [
                "-cclib", "-lm",
                "-cclib", "-ldl",
                "-cclib", "-lpthread",
            ],
            "//conditions:default": []
        }),
        visibility             = ["//visibility:public"]
    )

