load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/rules:COMPILER.bzl",
     "OCAMLC_PROLOGUE",
     "OCAMLC_MAIN",
     "OCAMLOPT_PROLOGUE",
     "OCAMLOPT_MAIN",
     "OCAML_COMPILER_OPTS")

load(":ocaml_transitions.bzl",
     # "ocamlc_byte_in_transition",
     "std_ocamlopt_byte_in_transition",
     "std_ocamlopt_opt_in_transition",
     "std_ocamlc_opt_in_transition")

################################################################
################################################################
def _std_ocamlc_byte_in_transition_impl(settings, attr):
    debug = False
    if debug:
        print("TRANSITION: std_ocamlc_byte_in_transition: %s" % attr.name)
        print("tc name: %s" % attr.name)

    protocol = settings["//config/build/protocol"]

    if debug:
        print("protocol: %s" % protocol)
        print("config_executor: %s" % settings["//config/target/executor"])
        print("config_emitter: %s" % settings["//config/target/emitter"])
        print("compiler: %s" % settings["//toolchain:compiler"])
        print("runtime: %s" % settings["//toolchain:runtime"])

    # if protocol == "std":
    #     return {}

    config_executor = "vm"
    config_emitter  = "vm"

    if protocol == "std":  ## default, from the cmd line
        # goal: build ocamlc.byte from boot/ocamlc.boot
        config_executor = "boot"
        config_emitter  = "boot"
        compiler = "//boot:ocamlc.boot"
        runtime  = "//runtime:camlrun"

    # elif protocol == "boot":
    #     # goal: build _boot/ocamlc.byte from boot/ocamlc.boot
    #     # then _boot_ocamlc_byte/ocamlc.byte from _boot/ocamlc.byte
    #     protocol = "std"
    #     config_executor = "vm"
    #     config_emitter  = "vm"
    #     compiler = "//bin:ocamlc.byte"
    #     runtime  = "//runtime:camlrun"
    #     # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol in ["boot", "tool"]:
        # during coldstart: use ocamlc.boot
        # after coldstart: use .bazeline/bin/ocamlc.opt
        protocol = "std"
        # config settings used by tc selector
        config_executor = "vm"
        config_emitter  = "vm"
        compiler = "//bin:ocamlc.byte"
        runtime  = "//runtime:camlrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "test":
        compiler = "@baseline//bin:ocamlc.opt"
        runtime  = "@baseline//lib:camlrun"
        # cvt_emit = "@baseline//bin:cvt_emit.byte"

    # elif protocol == "dev":
    #     ## use coldstart ocamlc.opt to build ocamlc.byte
    #     config_executor = "sys"
    #     config_emitter  = "vm"
    #     compiler = "@baseline//bin:ocamlc.opt"
    #     runtime  = "@baseline//lib:asmrun"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"

    else:
        fail("Protocol not supported for this target: %s" % protocol)

    if debug:
        print("setting //config/build/protocol:  %s" % protocol)
        print("setting //config/target/executor: %s" % config_executor)
        print("setting //config/target/emitter:  %s" % config_emitter)
        print("setting //toolchain:compiler:     %s" % compiler)
        print("setting//toolchain:runtime:       %s" % runtime)
        # print("setting//toolchain:cvt_emit:      %s" % cvt_emit)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
        # "//toolchain:cvt_emit"  : cvt_emit
    }

############################################
_std_ocamlc_byte_in_transition = transition(
    implementation = _std_ocamlc_byte_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

##############################
def _std_ocamlc_byte_impl(ctx):

    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule std_ocamlc_byte must end in '.byte'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, ctx.label.name, tc.workdir)

#####################
std_ocamlc_byte = rule(
    implementation = _std_ocamlc_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "std_ocamlc_byte" ),
    ),
    cfg = _std_ocamlc_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##############################
def _std_ocamlopt_byte_impl(ctx):

    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule std_ocamlopt_byte must end in '.byte'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    # if tc.flambda[BuildSettingInfo].value:
    #     exe_name = "ocamloptx.byte"
    # else:
    #     exe_name = "ocamlopt.byte"

    return executable_impl(ctx, tc, ctx.label.name, tc.workdir)

#####################
std_ocamlopt_byte = rule(
    implementation = _std_ocamlopt_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "std_ocamlopt_byte" ),
    ),
    cfg = std_ocamlopt_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##############################
def _std_ocamlopt_opt_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule std_ocamlopt_opt must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    # if tc.flambda[BuildSettingInfo].value:
    #     exe_name = "ocamloptx.optx"
    # else:
    #     exe_name = "ocamlopt.opt"

    return executable_impl(ctx, tc, ctx.label.name, tc.workdir)

#####################
std_ocamlopt_opt = rule(
    implementation = _std_ocamlopt_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "std_ocamlopt_opt" ),
    ),
    cfg = std_ocamlopt_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##############################
def _std_ocamlc_opt_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule std_ocamlc_opt must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    # if tc.flambda[BuildSettingInfo].value:
    #     exe_name = "ocamlc.optx"
    # else:
    #     exe_name = "ocamlc.opt"

    return executable_impl(ctx, tc, ctx.label.name, tc.workdir)

#####################
std_ocamlc_opt = rule(
    implementation = _std_ocamlc_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "std_ocamlc_opt" ),
    ),
    cfg = std_ocamlc_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
####  MACRO
################################################################
def std_ocaml_compilers(name,
                    visibility = ["//visibility:public"],
                    **kwargs):

    ## Standard Big Four
    std_ocamlc_byte(
        name       = "ocamlc.byte",
        prologue   = OCAMLC_PROLOGUE,
        main       = OCAMLC_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        visibility = ["//visibility:public"]
    )

    std_ocamlopt_byte(
        name       = "ocamlopt.byte",
        prologue   = OCAMLOPT_PROLOGUE,
        main       = OCAMLOPT_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        visibility = ["//visibility:public"]
    )

    std_ocamlopt_opt(
        name       = "ocamlopt.opt",
        prologue   = OCAMLOPT_PROLOGUE,
        main       = OCAMLOPT_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        visibility = ["//visibility:public"]
    )

    std_ocamlc_opt(
        name       = "ocamlc.opt",
        prologue   = OCAMLC_PROLOGUE,
        main       = OCAMLC_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        visibility = ["//visibility:public"]
    )

    ##FIXME: put profiling variants here? (ocamlcp.byte etc.)

    ################################################################
    ## Profiling variants

################################################################
################################################################
## recursive rule - obsolete
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
