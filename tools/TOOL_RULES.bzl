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
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:rules.bzl", "run_tool", "run_repl")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo")
load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

load("//bzl/actions:signature_impl.bzl", "signature_impl")
load("//bzl/attrs:signature_attrs.bzl", "signature_attrs")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load(":ocaml_transitions.bzl",
#      # "ocaml_tool_vm_in_transition",
#      "ocaml_tool_sys_in_transition")

################################################################
################################################################

#########################
def _tool_signature(ctx):

    (this, extension) = paths.split_extension(ctx.file.src.basename)
    module_name = this[:1].capitalize() + this[1:]

    return signature_impl(ctx, module_name)

#######################
tool_signature = rule(
    implementation = _tool_signature,
    doc = "Compiles a sig file for tools",
    attrs = dict(
        signature_attrs(),
        # stdlib_primitives = attr.bool(
        #     # FIXME: does False mean -nopervasives?
        #     doc = "Should be True only if -nopervasives does not work",
        #     default = False
        # ),
        # _stdlib = attr.label(
        #     ## only added to depgraph if stdlib_primitives == True
        #     allow_single_file = True,
        #     default = "//stdlib:Stdlib"
        # ),

        _rule = attr.string( default = "tool_signature" ),
    ),
    executable = False,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

######################
def _tool_module(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    return module_impl(ctx, module_name)

####################
tool_module = rule( # same as compiler_module(?)
    implementation = _tool_module,
    doc = "Compiles a module needed by a tool.",
    attrs = dict(
        module_attrs(),
        dump = attr.string_list(),
        # stdlib_primitives = attr.bool(default = False),
        # _stdlib = attr.label(
        #     ## only added to depgraph if stdlib_primitives == True
        #     default = "//stdlib:Stdlib"
        # ),
        # _resolver = attr.label(
        #     doc = "The compiler always opens Stdlib, so everything depends on it.",
        #     default = "//stdlib:Stdlib"
        # ),

        _rule = attr.string( default = "tool_module" ),
    ),
    provides = [BootInfo,ModuleInfo],
    executable = False,
    # fragments = ["platform", "cpp"],
    # host_fragments = ["platform",  "cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##########################################################
def _ocaml_tool_vm_in_transition_impl(settings, attr):
    debug = True
    if debug: print("ocaml_tool_vm_in_transition")

    protocol = settings["//config/build/protocol"]

    if protocol == "std":
        config_executor = "sys"
        config_emitter  = "vm"
        compiler = "//boot:ocamlc.boot"
        ocamlrun = "//runtime:ocamlrun"
        runtime  = "//runtime:camlrun"

    elif protocol == "boot":
        config_executor = "sys"
        config_emitter  = "vm"
        compiler = "//boot:ocamlc.byte"
        ocamlrun = "//runtime:ocamlrun"
        runtime  = "//runtime:camlrun"

    # elif protocol == "baseline":
    #     config_executor = "sys"
    #     config_emitter  = "vm"
    #     compiler = "@baseline//bin:ocamlc.opt"
    #     ocamlrun = "@baseline//lib:ocamlrun"
    #     runtime  = "@baseline//lib:camlrun"

    elif protocol == "test":
        config_executor = "sys"
        config_emitter  = "vm"
        compiler = "//test:ocamlc.opt"
        ocamlrun = "@baseline//bin:ocamlrun"
        runtime  = "@baseline//lib:camlrun"

    return {
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
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
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:ocamlrun",
        "//toolchain:runtime",
   ]
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

    # if tc.config_emitter == "sys":
    #     # ext = ".opt"
    #     workdir = "_sys/"
    # else:
    #     # ext = ".byte"
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

    if protocol == "std":  ## default
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "//bin:ocamlopt.opt"
        runtime  = "//runtime:asmrun"

    elif protocol == "boot":
        config_executor = "sys"
        config_emitter  = "sys"
        compiler = "@baseline//bin:ocamlopt.opt"
        runtime  = "@baseline//lib:asmrun"

    else:
        fail("Protocol not yet supported: %s" % protocol)

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,

        # "//toolchain:lexer"     : lexer,
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

    # if tc.config_emitter == "sys":
        # ext = ".opt"
    workdir = "_sys/"
    # else:
    #     # ext = ".byte"
    #     workdir = "_vm/"

    exe_name = ctx.label.name

    return executable_impl(ctx, tc, exe_name, workdir)

#######################
ocaml_tool_sys = rule(
    implementation = _ocaml_tool_sys_impl,

    attrs = dict(
        executable_attrs(),

        # vm_only = attr.bool(default = False),

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

    # run_tool(
    #     name = name + ".byte.sh",
    #     tool = ":" + name + ".byte",
    #     arg  = "//tools:arg",
    # )

    # native.sh_binary(
    #     name = name + ".byte.sh",
    #     srcs = [":TOOL_RUNNER.sh"],
    #     env  = select({
    #         ":verbose?": {"VERBOSE": "true"},
    #         "//conditions:default": {"VERBOSE": "false"}
    #     }),
    #     args = [
    #         "$(rlocationpath {}.byte)".format(name),
    #         "$(rlocationpath :arg)"
    #     ],
    #     data = [
    #         ":arg",
    #         ":" + name +  ".byte",
    #         "@ocamlcc//runtime:ocamlrun",
    #         # "@ocamlcc//runtime:asmrun",
    #         # "@ocamlcc//config/camlheaders",
    #         # "@bazel_tools//tools/cpp:current_cc_toolchain"
    #     ],
    #     deps = [
    #         # for the runfiles lib used in ocamlc.sh:
    #         "@bazel_tools//tools/bash/runfiles"
    #     ],
    #     toolchains = ["@bazel_tools//tools/cpp:current_cc_toolchain"]
    # )

    ocaml_tool_sys(
        name       = name + ".opt",
        main       = main,
        prologue   = prologue,
        visibility = visibility,
        **kwargs
    )

################################################################
################################################################
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
