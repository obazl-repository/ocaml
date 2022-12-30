load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load(":ocaml_transitions.bzl",
#      "ocamlc_byte_in_transition",
#      "ocamlopt_byte_in_transition",
#      "ocamlopt_opt_in_transition",
#      "ocamlc_opt_in_transition",
#      ## flambda:
#      "ocamloptx_byte_in_transition",
#      "ocamloptx_optx_in_transition",
#      "ocamlc_optx_in_transition",
#      "ocamlopt_optx_in_transition")

TRANSITION_CONFIGS = [
    "//config/build/protocol",
    "//config/target/executor",
    "//config/target/emitter",
    "//toolchain:compiler",
    "//toolchain:runtime",
]

################################################################
################################################################
def _boot_ocamlc_byte_in_transition_impl(settings, attr):
    protocol = "std"
    config_executor = "vm"
    config_emitter  = "vm"
    compiler = "//bin:ocamlc.byte"
    runtime  = "//runtime:camlrun"

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

####
boot_ocamlc_byte_in_transition = transition(
    implementation = _boot_ocamlc_byte_in_transition_impl,
    inputs  = TRANSITION_CONFIGS,
    outputs = TRANSITION_CONFIGS
)

########
def _boot_ocamlc_byte_impl(ctx):

    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule boot_ocamlc_byte must end in '.byte'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlc.byte", tc.workdir)

#####################
boot_ocamlc_byte = rule(
    implementation = _boot_ocamlc_byte_impl,
    doc = "Bootstraps a baseline compiler",
    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "boot_ocamlc_byte" ),
    ),
    cfg = boot_ocamlc_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
def _boot_ocamlopt_byte_in_transition_impl(settings, attr):
    protocol = "boot"
    config_executor = "vm"
    config_emitter  = "sys"
    compiler = "//boot:ocamlc.byte"
    runtime  = "//runtime:asmrun"

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

####
_boot_ocamlopt_byte_in_transition = transition(
    implementation = _boot_ocamlopt_byte_in_transition_impl,
    inputs  = TRANSITION_CONFIGS,
    outputs = TRANSITION_CONFIGS
)

##############################
def _boot_ocamlopt_byte_impl(ctx):
    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule boot_ocamlopt_byte must end in '.byte'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamloptx.byte"
    else:
        exe_name = "ocamlopt.byte"
    return executable_impl(ctx, tc, exe_name, tc.workdir)

#####################
boot_ocamlopt_byte = rule(
    implementation = _boot_ocamlopt_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "boot_ocamlopt_byte" ),
    ),
    cfg = _boot_ocamlopt_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
def _boot_ocamlopt_opt_in_transition_impl(settings, attr):
    protocol = "boot"
    config_executor = "vm"
    config_emitter  = "sys"
    compiler = "//boot:ocamlopt.byte"
    runtime  = "//runtime:asmrun"
    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

####
boot_ocamlopt_opt_in_transition = transition(
    implementation = _boot_ocamlopt_opt_in_transition_impl,
    inputs  = TRANSITION_CONFIGS,
    outputs = TRANSITION_CONFIGS
)

##############################
def _boot_ocamlopt_opt_impl(ctx):
    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule boot_ocamlopt_opt must end in '.opt'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamloptx.optx"
    else:
        exe_name = "ocamlopt.opt"
    return executable_impl(ctx, tc, exe_name, tc.workdir)

#####################
boot_ocamlopt_opt = rule(
    implementation = _boot_ocamlopt_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "boot_ocamlopt_opt" ),
    ),
    cfg = boot_ocamlopt_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
def _boot_ocamlc_opt_in_transition_impl(settings, attr):
    protocol = "test"
    config_executor = "sys"
    config_emitter  = "sys"
    compiler = "//boot:ocamlopt.opt"
    runtime  = "//runtime:asmrun"
    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

####
boot_ocamlc_opt_in_transition = transition(
    implementation = _boot_ocamlc_opt_in_transition_impl,
    inputs  = TRANSITION_CONFIGS,
    outputs = TRANSITION_CONFIGS
)

##############################
def _boot_ocamlc_opt_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule boot_ocamlc_opt must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamlc.optx"
    else:
        exe_name = "ocamlc.opt"

    return executable_impl(ctx, tc, exe_name, tc.workdir)

#####################
boot_ocamlc_opt = rule(
    implementation = _boot_ocamlc_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "boot_ocamlc_opt" ),
    ),
    cfg = boot_ocamlc_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
def _boot_import_vm_executable(ctx):

    tool = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.symlink(output = tool,
                        target_file = ctx.file.tool)

    runfiles = ctx.runfiles(
        files = ctx.files._stdlib
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
            mandatory = True,
            allow_single_file = True,
        ),
        # stdlib is a runtime dep of the linker, so we need to build
        # it and add it runfiles.
        _stdlib = attr.label(
            doc = "Stdlib archive", ## (not stdlib.cmx?a")
            default = "//stdlib", # archive, not resolver
            # allow_single_file = True, # won't work with boot_library
            executable = False,
            cfg = "exec"
            # cfg = exe_deps_out_transition,
        ),

        # _ocamlrun = attr.label(
        #     allow_single_file = True,
        #     default = "//runtime:ocamlrun",
        #     executable = True,
        #     # cfg = "exec"
        #     cfg = reset_cc_config_transition
        # ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
    ),
    # executable = True,
    # cfg = exec
)
