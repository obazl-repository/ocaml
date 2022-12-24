load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load(":ocaml_transitions.bzl",
     "ocamlc_byte_in_transition",
     "ocamlopt_byte_in_transition",
     "ocamlopt_opt_in_transition",
     "ocamlc_opt_in_transition")

##############################
def _ocaml_compiler_r_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    executor = tc.config_executor
    emitter  = tc.config_emitter

    if executor == "boot":
        exe_name = "ocamlc.byte"
    elif executor == "baseline":
        exe_name = "ocamlc.baseline"
    elif executor == "vm":
        if emitter == "vm":
            exe_name = "ocamlc.byte"
        elif emitter == "sys":
            exe_name = "ocamlopt.byte"
        else:
            fail("unknown emitter: %s" % emitter)
    elif executor in ["sys"]:
        if emitter in ["boot", "vm"]:
            exe_name = "ocamlc.opt"
        elif emitter == "sys":
            exe_name = "ocamlopt.opt"
        else:
            fail("sys unknown emitter: %s" % emitter)
    elif executor == "unspecified":
        fail("unspecified executor: %s" % executor)
    else:
        fail("unknown executor: %s" % executor)

    return executable_impl(ctx, tc, exe_name, workdir)

#####################
ocaml_compiler_r = rule(
    implementation = _ocaml_compiler_r_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

        _rule = attr.string( default = "ocaml_compiler" ),
    ),
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##############################
def _ocamlc_byte_impl(ctx):

    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule ocamlc_byte must end in '.byte'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlc.byte", tc.workdir)

#####################
ocamlc_byte = rule(
    implementation = _ocamlc_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlc_byte" ),
    ),
    cfg = ocamlc_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _ocamlopt_byte_impl(ctx):

    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule ocamlopt_byte must end in '.byte'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlopt.byte", tc.workdir)

#####################
ocamlopt_byte = rule(
    implementation = _ocamlopt_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlopt_byte" ),
    ),
    cfg = ocamlopt_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _ocamlopt_opt_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule ocamlopt_opt must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlopt.opt", tc.workdir)

#####################
ocamlopt_opt = rule(
    implementation = _ocamlopt_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlopt_opt" ),
    ),
    cfg = ocamlopt_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _ocamlc_opt_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule ocamlc_opt must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlc.opt", tc.workdir)

#####################
ocamlc_opt = rule(
    implementation = _ocamlc_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlc_opt" ),
    ),
    cfg = ocamlc_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
####  MACRO
################################################################
def ocaml_compilers(name,
                    visibility = ["//visibility:public"],
                    **kwargs):

    ocamlc_byte(
        name = "ocamlc.byte",
        # stdlib   = "@//stdlib",
        prologue = [
            # "//stdlib:primitives",
            # "//stdlib:Stdlib",
            # "//stdlib:Stdlib.Arg",
            "//stdlib",
            "@//compilerlibs:ocamlcommon",
            "@//bytecomp:ocamlbytecomp"
        ],
        main = "@//driver:Main",
        opts = [ ] + select({
            # ocamlc.byte: ["-compat-32"]
        "//conditions:default": []
        }) + [
        ] + select({
            "@//platform/target/os:linux?": [
                "-cclib", "-lm",
                "-cclib", "-ldl",
                "-cclib", "-lpthread",
            ],
            "//conditions:default": []
        }),
        visibility             = ["//visibility:public"]
    )

    ocamlopt_byte(
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

    ocamlopt_opt(
        name = "ocamlopt.opt",
        # stdlib   = "//stdlib",
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

    ocamlc_opt(
        name = "ocamlc.opt",
        # stdlib   = "//stdlib",
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

