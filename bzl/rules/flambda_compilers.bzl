load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/rules:COMPILER.bzl",
     "OCAMLC_PROLOGUE",
     "OCAMLC_MAIN",
     "OCAMLOPT_PROLOGUE",
     "OCAMLOPT_MAIN",
     "OCAML_COMPILER_OPTS")

load(":flambda_transitions.bzl",
     "ocamloptx_byte_in_transition",
     "ocamloptx_opt_in_transition",
     "ocamlc_optx_in_transition",
     "ocamlopt_optx_in_transition",
     "ocamloptx_optx_in_transition")

################################################################
## flambda: ocamloptx.byte, ocamlc_optx, ocamloptx.optx

#################
def optx_attrs():
    return dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlc_optx" ),
    )


##############################
def _ocamloptx_byte_impl(ctx):
    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule ocamloptx_bytes must end in '.optx'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamloptx.byte"
    else:
        fail("bad build setting: tc.flambda should be true: %s" % tc.flambda[BuildSettingInfo].value)
    return executable_impl(ctx, tc, exe_name, tc.workdir)

##############################
def _ocamloptx_opt_impl(ctx):
    if not ctx.label.name == "ocamloptx.opt":
        fail("Target name for rule ocamloptx_opt must be 'ocamloptx.opt'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamloptx.opt"
    else:
        fail("bad build setting: tc.flambda should be true: %s" % tc.flambda[BuildSettingInfo].value)
    return executable_impl(ctx, tc, exe_name, tc.workdir)

##############################
def _ocamlc_optx_impl(ctx):
    if not ctx.label.name.endswith(".optx"):
        fail("Target name for rule ocamlc_optx must end in '.optx'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamlc.optx"
    else:
        fail("bad build setting: tc.flambda should be true: %s" % tc.flambda[BuildSettingInfo].value)
    return executable_impl(ctx, tc, exe_name, tc.workdir)

##############################
def _ocamlopt_optx_impl(ctx):
    if not ctx.label.name == "ocamlopt.optx":
        fail("Target name for rule ocamlopt_optx must be 'ocamlopt.optx'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        fail("bad build setting: tc.flambda should be false: %s" % tc.flambda[BuildSettingInfo].value)
    else:
        ## we're using a flambda compiler to build a non-flambda compiler;
        ## target name is always:
        exe_name = "ocamlopt.optx"

    return executable_impl(ctx, tc, exe_name, tc.workdir)

##############################
def _ocamloptx_optx_impl(ctx):
    if not ctx.label.name.endswith(".optx"):
        fail("Target name for rule ocamloptx_optx must end in '.optx'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamloptx.optx"
    else:
        fail("bad build setting: tc.flambda should be true: %s" % tc.flambda[BuildSettingInfo].value)
    return executable_impl(ctx, tc, exe_name, tc.workdir)

##############################

optx_impls = struct(
    optx_byte = _ocamloptx_byte_impl,
    optx_opt  = _ocamloptx_opt_impl,
    c_optx    = _ocamlc_optx_impl,
    opt_optx    = _ocamlopt_optx_impl,
    optx_optx = _ocamloptx_optx_impl,
)
optx_in_transitions = struct(
    optx_byte = ocamloptx_byte_in_transition,
    optx_opt  = ocamloptx_opt_in_transition,
    c_optx    = ocamlc_optx_in_transition,
    opt_optx    = ocamlopt_optx_in_transition,
    optx_optx = ocamloptx_optx_in_transition,
)

################################################################
def optx_rule(name,
              # impl,
              # cfg,
              doc = "Builds flambda-enabled compiler"):
    return rule(
        implementation = getattr(optx_impls, name),
        cfg = getattr(optx_in_transitions, name),
        doc = doc,
        attrs = optx_attrs(),
        executable = True,
        toolchains = ["//toolchain/type:ocaml",
                      "@bazel_tools//tools/cpp:toolchain_type"])

#####################
ocamloptx_byte = optx_rule("optx_byte")

ocamloptx_opt  = optx_rule("optx_opt")

ocamlc_optx    = optx_rule("c_optx")

ocamlopt_optx  = optx_rule("opt_optx")

ocamloptx_optx = optx_rule("optx_optx")

################################################################
####  MACRO: flambda variants:
####  ocamloptx.byte, ocamloptx.opt,
####  ocamlc.optx, ocamlopt.optx,
####  ocamloptx.optx
################################################################
def flambda_compilers(name,
                            visibility = ["//visibility:public"],
                            **kwargs):

    ocamloptx_byte(
        name       = "ocamloptx.byte",
        prologue   = OCAMLOPT_PROLOGUE,
        main       = OCAMLOPT_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        tags = ["compiler"],
        visibility = ["//visibility:public"]
    )

    ocamloptx_opt(
        name       = "ocamloptx.opt",
        prologue   = OCAMLOPT_PROLOGUE,
        main       = OCAMLOPT_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        tags = ["compiler"],
        visibility = ["//visibility:public"]
    )

    ocamlc_optx(
        name       = "ocamlc.optx",
        prologue   = OCAMLC_PROLOGUE,
        main       = OCAMLC_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        tags = ["compiler"],
        visibility = ["//visibility:public"]
    )

    ## TODO:
    ## ocamlopt.optx - optimized, non-optimizing compiler
    ## built by ocamloptx.optx, but built w/o flambda
    ## (ocamlc.optx is already an optimized non-optimizing compiler)
    ocamlopt_optx(
        name       = "ocamlopt.optx",
        prologue   = OCAMLOPT_PROLOGUE,
        main       = OCAMLOPT_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        tags = ["compiler"],
        visibility = ["//visibility:public"]
    )

    ocamloptx_optx(
        name       = "ocamloptx.optx",
        prologue   = OCAMLOPT_PROLOGUE,
        main       = OCAMLOPT_MAIN,
        opts       = OCAML_COMPILER_OPTS,
        tags = ["compiler"],
        visibility = ["//visibility:public"]
    )
