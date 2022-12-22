load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load(":ocaml_transitions.bzl",
     "ocaml_tool_vm_in_transition",
     "ocaml_tool_sys_in_transition")

##############################
def _ocaml_tool_r_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    print("OCAML TOOL.BYTE emitter: %s" % tc.config_emitter)

    if tc.config_emitter == "sys":
        # ext = ".opt"
        workdir = "_sys/"
    else:
        # ext = ".byte"
        workdir = "_vm/"

    exe_name = ctx.label.name

    return executable_impl(ctx, tc, exe_name, workdir)

#######################
ocaml_tool_r = rule(
    implementation = _ocaml_tool_r_impl,

    attrs = dict(
        executable_attrs(),

        vm_only = attr.bool(default = False),

        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
        ),

        _rule = attr.string( default = "ocaml_tool_r" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _ocaml_tool_vm_impl(ctx):

    debug = True
    if debug:
        print("ocaml_tool_vm: %s" % ctx.label)

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    print("OCAML TOOL.BYTE emitter: %s" % tc.config_emitter)

    if tc.config_emitter == "sys":
        # ext = ".opt"
        workdir = "_sys/"
    else:
        # ext = ".byte"
        workdir = "_vm/"

    exe_name = ctx.label.name

    return executable_impl(ctx, tc, exe_name, workdir)

#######################
ocaml_tool_vm = rule(
    implementation = _ocaml_tool_vm_impl,

    attrs = dict(
        executable_attrs(),

        vm_only = attr.bool(default = False),

        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        # ),

        _rule = attr.string( default = "ocaml_tool_vm" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = ocaml_tool_vm_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
def _ocaml_tool_sys_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule ocaml_tool_sys must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    exe_name = ctx.label.name

    return executable_impl(ctx, tc, exe_name, tc.workdir)

#######################
ocaml_tool_sys = rule(
    implementation = _ocaml_tool_sys_impl,

    attrs = dict(
        executable_attrs(),

        vm_only = attr.bool(default = False),

        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
        ),

        _rule = attr.string( default = "ocaml_tool_sys" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = ocaml_tool_sys_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
####  MACRO
################################################################
def ocaml_tools(name, main,
               prologue = None,
               visibility = ["//visibility:public"],
               **kwargs):

    ocaml_tool_vm(
        name       = name + ".byte",
        main       = main,
        prologue   = prologue,
        visibility = visibility,
        **kwargs
    )

    ocaml_tool_sys(
        name       = name + ".opt",
        main       = main,
        prologue   = prologue,
        visibility = visibility,
        **kwargs
    )

