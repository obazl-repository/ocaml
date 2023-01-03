## ocaml_tool rules: used to build ocaml tools:
#    //tools:ocamlobjinfo etc.
#    //lex:ocamllex
#    //testsuite/tools:inline_expect
#    //toplevel:ocaml.tmp (temporary until we get expunge working)

# (in contrast to build_tool rules, which build tools used internally
# by the build protocols.)

# ocaml_tools: macro, expands to ocaml_tool_vm, ocaml_tool_sys

## the _vm version uses @baseline/bin/ocamlc.opt to build the tools
## the _sys version uses @baseline/bin/ocamlopt.opt to build the tools

## CAVEAT: these do NOT rebuild the compiler; to use a new version of the
## compiler to build them, run coldstart to install the new versions
## in .baseline/.


load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load(":ocaml_transitions.bzl",
#      # "ocaml_tool_vm_in_transition",
#      "ocaml_tool_sys_in_transition")

##########################################################
def _ocaml_tool_vm_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocaml_tool_vm_in_transition")

    ## always use @baseline opt tools to build ocaml_tool targets:
    ## FIXME: other way around: build_tools always use @baseline
    ## ocaml_tools should use whatever toolchain is selected by
    ## protocol. For now @baseline will work, but it won't pick up
    ## changes in the tool sources.
    compiler = "@baseline//bin:ocamlc.opt"
    ocamlrun = "@baseline//bin:ocamlrun"
    runtime  = "@baseline//lib:camlrun"
    # runtime  = "//runtime:camlrun"

    protocol = settings["//config/build/protocol"]

    # if protocol == "std":
    #     return {}

    # config_executor = "vm"
    # config_emitter  = "vm"

    # if protocol == "unspecified":
    #     protocol = "boot"
    #     compiler = "//boot:ocamlc.byte"
    #     runtime  = "//runtime:camlrun"
    #     cvt_emit = settings["//toolchain:cvt_emit"]

    # elif protocol == "dev":
    #     compiler = "@baseline//bin:ocamlc.opt"
    #     # lexer    = "@baseline//bin:ocamllex.opt"
    #     cvt_emit = "@baseline//bin:cvt_emit.byte"
    #     runtime  = "@baseline//lib:asmrun"
    # else:
    #     compiler = "//bin:ocamlc.byte"
    #     # lexer    = "//lex:ocamllex.byte"
    #     runtime  = "//runtime:asmrun"
    #     cvt_emit = "//asmcomp:cvt_emit.byte"

    return {
        # "//config/target/executor": config_executor,
        # "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:ocamlrun"  : ocamlrun,
        "//toolchain:runtime"   : runtime,
    }

################################################################
ocaml_tool_vm_in_transition = transition(
    implementation = _ocaml_tool_vm_in_transition_impl,
    inputs = [
        "//config/build/protocol",
    ],
    outputs = [
        # "//config/target/executor",
        # "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:ocamlrun",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

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

################################################################
################################################################
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
        # vm_only = attr.bool(default = False),
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
##########################################################
def _ocaml_tool_sys_in_transition_impl(settings, attr):
    debug = False
    if debug: print("ocaml_tool_sys_in_transition")

    protocol = settings["//config/build/protocol"]

    protocol = "boot"

    config_executor = "sys"
    config_emitter  = "sys"

    if protocol == "std":  ## default
        # protocol = "boot"
        compiler = "//bin:ocamlopt.opt"
        runtime  = "//runtime:asmrun"
        # cvt_emit = settings["//toolchain:cvt_emit"]

    # elif protocol == "boot":
    #     compiler = "//bin:ocamlopt.opt"
    #     runtime  = "//runtime:asmrun"
    #     # cvt_emit = settings["//toolchain:cvt_emit"]

    elif protocol == "boot":
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime  = "@baseline//lib:asmrun"

    else:
        fail("Protocol not yet supported: %s" % protocol)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        # "//toolchain:lexer"     : lexer,
        "//toolchain:runtime"   : runtime,
        # "//toolchain:cvt_emit"  : cvt_emit
    }

##########################################
_ocaml_tool_sys_in_transition = transition(
    implementation = _ocaml_tool_sys_in_transition_impl,
    inputs = [
        "//config/build/protocol",
    ],
    outputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        # "//toolchain:lexer",
        "//toolchain:runtime",
        # "//toolchain:cvt_emit"
    ]
)

##############################
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

        # _runtime = attr.label(
        #     allow_single_file = True,
        #     default = "//toolchain:runtime",
        #     executable = False,
        # ),

        _rule = attr.string( default = "ocaml_tool_sys" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    cfg = _ocaml_tool_sys_in_transition,
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

