load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

# load("//bzl/rules/common:transitions.bzl", "compiler_in_transition")

load("//bzl/rules/common:cc_transitions.bzl", "reset_cc_config_transition")

load("//bzl:functions.bzl", "get_workdir", "tc_compiler")

##############################
def _ocaml_compiler_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:boot"]
    (target_executor, target_emitter,
     config_executor, config_emitter,
     workdir) = get_workdir(ctx, tc)

    executor = config_executor
    emitter  = config_emitter

    if executor == "boot":
        exe_name = "ocamlc.byte"
    elif executor == "baseline":
        exe_name = "ocamlc.byte"
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

    # for f in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
    #     print("CRF {executor}:{emitter} rf: {rf}".format(
    #         executor = executor, emitter = emitter, rf = f.path))

    return executable_impl(ctx, exe_name)

#####################
ocaml_compiler = rule(
    implementation = _ocaml_compiler_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),

        ## _runtime: for sys executor only
        _runtime = attr.label(
            # allow_single_file = True,
            default = "//runtime:asmrun",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _rule = attr.string( default = "ocaml_compiler" ),
    ),
    # cfg = compiler_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
