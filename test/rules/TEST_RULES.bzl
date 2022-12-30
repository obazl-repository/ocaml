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
def _t_ocamlc_byte_in_transition_impl(settings, attr):
    protocol = "test"
    config_executor = "vm"
    config_emitter  = "vm"

    compiler = "@baseline//bin:ocamlc.byte"
    runtime  = "@baseline//lib:libcamlrun.a"

    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

####
t_ocamlc_byte_in_transition = transition(
    implementation = _t_ocamlc_byte_in_transition_impl,
    inputs  = TRANSITION_CONFIGS,
    outputs = TRANSITION_CONFIGS
)

########
def _t_ocamlc_byte_impl(ctx):

    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule t_ocamlc_byte must end in '.byte'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    return executable_impl(ctx, tc, "ocamlc.byte", tc.workdir)

#####################
t_ocamlc_byte = rule(
    implementation = _t_ocamlc_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "t_ocamlc_byte" ),
    ),
    cfg = t_ocamlc_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
def _t_ocamlopt_byte_in_transition_impl(settings, attr):
    protocol = "test"
    config_executor = "sys"
    config_emitter  = "vm"
    compiler = "@baseline//bin:ocamlc.opt"
    runtime  = "@baseline//lib:libasmrun.a"
    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

####
t_ocamlopt_byte_in_transition = transition(
    implementation = _t_ocamlopt_byte_in_transition_impl,
    inputs  = TRANSITION_CONFIGS,
    outputs = TRANSITION_CONFIGS
)

##############################
def _t_ocamlopt_byte_impl(ctx):
    if not ctx.label.name.endswith(".byte"):
        fail("Target name for rule t_ocamlopt_byte must end in '.byte'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamloptx.byte"
    else:
        exe_name = "ocamlopt.byte"
    return executable_impl(ctx, tc, exe_name, tc.workdir)

################################################################
#####################
t_ocamlopt_byte = rule(
    implementation = _t_ocamlopt_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "t_ocamlopt_byte" ),
    ),
    cfg = t_ocamlopt_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
def _t_ocamlopt_opt_in_transition_impl(settings, attr):
    protocol = "test"
    config_executor = "sys"
    config_emitter  = "sys"
    compiler = "@baseline//bin:ocamlopt.opt"
    runtime  = "@baseline//lib:libasmrun.a"
    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

####
t_ocamlopt_opt_in_transition = transition(
    implementation = _t_ocamlopt_opt_in_transition_impl,
    inputs  = TRANSITION_CONFIGS,
    outputs = TRANSITION_CONFIGS
)

##############################
def _t_ocamlopt_opt_impl(ctx):
    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule t_ocamlopt_opt must end in '.opt'")
    tc = ctx.toolchains["//toolchain/type:ocaml"]
    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamloptx.optx"
    else:
        exe_name = "ocamlopt.opt"
    return executable_impl(ctx, tc, exe_name, tc.workdir)

#####################
t_ocamlopt_opt = rule(
    implementation = _t_ocamlopt_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "t_ocamlopt_opt" ),
    ),
    cfg = t_ocamlopt_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
################################################################
def _t_ocamlc_opt_in_transition_impl(settings, attr):
    protocol = "test"
    # we use ocamlopt.opt to build ocamlc.opt
    config_executor = "sys"
    config_emitter  = "sys"
    compiler = "@baseline//bin:ocamlopt.opt"
    runtime  = "@baseline//lib:libasmrun.a"
    return {
        "//config/build/protocol" : protocol,
        "//config/target/executor": config_executor,
        "//config/target/emitter" : config_emitter,
        "//toolchain:compiler"  : compiler,
        "//toolchain:runtime"   : runtime,
    }

####
t_ocamlc_opt_in_transition = transition(
    implementation = _t_ocamlc_opt_in_transition_impl,
    inputs  = TRANSITION_CONFIGS,
    outputs = TRANSITION_CONFIGS
)

##############################
def _t_ocamlc_opt_impl(ctx):

    if not ctx.label.name.endswith(".opt"):
        fail("Target name for rule t_ocamlc_opt must end in '.opt'")

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    if tc.flambda[BuildSettingInfo].value:
        exe_name = "ocamlc.optx"
    else:
        exe_name = "ocamlc.opt"

    return executable_impl(ctx, tc, exe_name, tc.workdir)

#####################
t_ocamlc_opt = rule(
    implementation = _t_ocamlc_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "t_ocamlc_opt" ),
    ),
    cfg = t_ocamlc_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
## flambda: ocamloptx.byte, ocamlc_optx, ocamloptx.optx

# #################
# def optx_attrs():
#     return dict(
#         executable_attrs(),
#         _allowlist_function_transition = attr.label(
#             default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
#         ),
#         _rule = attr.string( default = "ocamlc_optx" ),
#     )


# ##############################
# def _ocamloptx_byte_impl(ctx):
#     if not ctx.label.name.endswith(".byte"):
#         fail("Target name for rule ocamloptx_bytes must end in '.optx'")
#     tc = ctx.toolchains["//toolchain/type:ocaml"]
#     if tc.flambda[BuildSettingInfo].value:
#         exe_name = "ocamloptx.byte"
#     else:
#         fail("bad build setting: tc.flambda should be true: %s" % tc.flambda[BuildSettingInfo].value)
#     return executable_impl(ctx, tc, exe_name, tc.workdir)

# ##############################
# def _ocamloptx_optx_impl(ctx):
#     if not ctx.label.name.endswith(".optx"):
#         fail("Target name for rule ocamloptx_optx must end in '.optx'")
#     tc = ctx.toolchains["//toolchain/type:ocaml"]
#     if tc.flambda[BuildSettingInfo].value:
#         exe_name = "ocamloptx.optx"
#     else:
#         fail("bad build setting: tc.flambda should be true: %s" % tc.flambda[BuildSettingInfo].value)
#     return executable_impl(ctx, tc, exe_name, tc.workdir)

# ##############################
# def _ocamlopt_optx_impl(ctx):
#     if not ctx.label.name.endswith(".optx"):
#         fail("Target name for rule ocamlc_optx must end in '.optx'")
#     tc = ctx.toolchains["//toolchain/type:ocaml"]
#     if tc.flambda[BuildSettingInfo].value:
#         exe_name = "ocamlopt.optx"
#     else:
#         fail("bad build setting: tc.flambda should be true: %s" % tc.flambda[BuildSettingInfo].value)
#     return executable_impl(ctx, tc, exe_name, tc.workdir)

# ##############################
# def _ocamlc_optx_impl(ctx):
#     if not ctx.label.name.endswith(".optx"):
#         fail("Target name for rule ocamlc_optx must end in '.optx'")
#     tc = ctx.toolchains["//toolchain/type:ocaml"]
#     if tc.flambda[BuildSettingInfo].value:
#         exe_name = "ocamlc.optx"
#     else:
#         fail("bad build setting: tc.flambda should be true: %s" % tc.flambda[BuildSettingInfo].value)
#     return executable_impl(ctx, tc, exe_name, tc.workdir)

##############################

# optx_impls = struct(
#     optx_byte = _ocamloptx_byte_impl,
#     optx_optx = _ocamloptx_optx_impl,
#     c_optx    = _ocamlc_optx_impl,
#     opt_optx    = _ocamlopt_optx_impl,
# )
# optx_in_transitions = struct(
#     optx_byte = ocamloptx_byte_in_transition,
#     optx_optx = ocamloptx_optx_in_transition,
#     c_optx    = ocamlc_optx_in_transition,
#     opt_optx    = ocamlopt_optx_in_transition,
# )

# ################################################################
# def optx_rule(name,
#               # impl,
#               # cfg,
#               doc = "Builds flambda-enabled compiler"):
#     return rule(
#         implementation = getattr(optx_impls, name),
#         cfg = getattr(optx_in_transitions, name),
#         doc = doc,
#         attrs = optx_attrs(),
#         executable = True,
#         toolchains = ["//toolchain/type:ocaml",
#                       "@bazel_tools//tools/cpp:toolchain_type"])

# #####################
# ocamloptx_byte = optx_rule("optx_byte")

# ocamloptx_optx = optx_rule("optx_optx")

# ocamlc_optx    = optx_rule("c_optx")

# ocamlopt_optx    = optx_rule("opt_optx")

# #####################
# # ocamloptx_byte = rule(
# #     implementation = _ocamloptx_byte_impl,
# #     doc = "Builds an opt.byte compiler with flambda enabled",
# #     cfg = ocamloptx_byte_in_transition,
# #     attrs = optx_attrs(),
# #     # attrs = dict(
# #     #     executable_attrs(),
# #     #     _allowlist_function_transition = attr.label(
# #     #         default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
# #     #     ),
# #     #     _rule = attr.string( default = "ocamlc_optx" ),
# #     # ),
# #     executable = True,
# #     fragments = ["cpp"],
# #     toolchains = ["//toolchain/type:ocaml",
# #                   ## //toolchain/type:profile,",
# #                   "@bazel_tools//tools/cpp:toolchain_type"]
# # )

# #####################
# # ocamlc_optx = rule(
# #     implementation = _ocamlc_optx_impl,
# #     doc = "Builds a compiler with flambda enabled",
# #     cfg = ocamlc_optx_in_transition,
# #     attrs = optx_attrs(),
# #     executable = True,
# #     fragments = ["cpp"],
# #     toolchains = ["//toolchain/type:ocaml",
# #                   ## //toolchain/type:profile,",
# #                   "@bazel_tools//tools/cpp:toolchain_type"]
# # )

# ########################
# # ocamloptx_optx = rule(
# #     implementation = _ocamloptx_optx_impl,
# #     doc = "Builds an opt.opt compiler with flambda enabled",

# #     attrs = dict(
# #         executable_attrs(),
# #         _allowlist_function_transition = attr.label(
# #             default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
# #         ),
# #         _rule = attr.string( default = "ocamlc_optx" ),
# #     ),
# #     cfg = ocamlc_optx_in_transition,
# #     executable = True,
# #     fragments = ["cpp"],
# #     toolchains = ["//toolchain/type:ocaml",
# #                   ## //toolchain/type:profile,",
# #                   "@bazel_tools//tools/cpp:toolchain_type"]
# # )

# ################################################################
# ####  MACRO
# ################################################################
# def ocaml_compilers(name,
#                     visibility = ["//visibility:public"],
#                     **kwargs):

#     t_ocamlc_byte(
#         name = "ocamlc.byte",
#         prologue = select({
#             "//config/ocaml/compiler/libs:archived?": ["//stdlib"],
#             "//conditions:default": []
#         }) + [
#             "@//compilerlibs:ocamlcommon",
#             "@//bytecomp:ocamlbytecomp"
#         ],
#         main = "@//driver:Main",
#         opts = [ ] + select({
#             # ocamlc.byte: ["-compat-32"]
#         "//conditions:default": []
#         }) + [
#         ] + select({
#             "@//platform/target/os:linux?": [
#                 "-cclib", "-lm",
#                 "-cclib", "-ldl",
#                 "-cclib", "-lpthread",
#             ],
#             "//conditions:default": []
#         }),
#         visibility             = ["//visibility:public"]
#     )

#     ocamlopt_byte(
#         name = "ocamlopt.byte",
#         # stdlib   = "//stdlib",
#         prologue = select({
#             "//config/ocaml/compiler/libs:archived?": ["//stdlib"],
#             "//conditions:default": []
#         }) + [
#         "//compilerlibs:ocamlcommon",
#         "//asmcomp:ocamloptcomp"
#         ],
#         main = "//driver:Optmain",
#         opts = [ ] + select({
#             # ocamlc.byte: ["-compat-32"]
#         "//conditions:default": []
#         }) + [
#         ] + select({
#             "//platform/target/os:linux?": [
#                 "-cclib", "-lm",
#                 "-cclib", "-ldl",
#                 "-cclib", "-lpthread",
#             ],
#             "//conditions:default": []
#         }),
#         visibility             = ["//visibility:public"]
#     )

#     ocamlopt_opt(
#         name = "ocamlopt.opt",
#         ## The Bazel rules cannot infer the ordering of archive file
#         ## deps, so the following order must be maintained:
#         prologue = select({
#             "//config/ocaml/compiler/libs:archived?": ["//stdlib"],
#             "//conditions:default": []
#         }) + [
#             "//compilerlibs:ocamlcommon",
#             "//asmcomp:ocamloptcomp"
#         ],
#         main = "//driver:Optmain",
#         opts = [ ] + select({
#             "//platform/target/os:linux?": [
#                 "-cclib", "-lm",
#                 "-cclib", "-ldl",
#                 "-cclib", "-lpthread",
#             ],
#             "//conditions:default": []
#         }),
#         visibility             = ["//visibility:public"]
#     )

#     ocamlc_opt(
#         name = "ocamlc.opt",
#         # stdlib   = "//stdlib",
#         prologue = [
#             "//compilerlibs:ocamlcommon",
#             "//bytecomp:ocamlbytecomp"
#         ],
#         main = "//driver:Main",
#         opts = [ ] + select({
#             "//platform/target/os:linux?": [
#                 "-cclib", "-lm",
#                 "-cclib", "-ldl",
#                 "-cclib", "-lpthread",
#             ],
#             "//conditions:default": []
#         }),
#         visibility             = ["//visibility:public"]
#     )

#     ################################################################
#     ## flambda variants

#     ocamloptx_byte(
#         name = "ocamloptx.byte",
#         prologue = [
#             "//compilerlibs:ocamlcommon",
#             "//asmcomp:ocamloptcomp"
#         ],
#         main = "//driver:Optmain",
#         opts = [ ] + select({
#             "//platform/target/os:linux?": [
#                 "-cclib", "-lm",
#                 "-cclib", "-ldl",
#                 "-cclib", "-lpthread",
#             ],
#             "//conditions:default": []
#         }),
#         visibility             = ["//visibility:public"]
#     )

#     ocamloptx_optx(
#         name = "ocamloptx.optx",
#         prologue = [
#             "//compilerlibs:ocamlcommon",
#             "//asmcomp:ocamloptcomp"
#         ],
#         main = "//driver:Optmain",
#         opts = [ ] + select({
#             "//platform/target/os:linux?": [
#                 "-cclib", "-lm",
#                 "-cclib", "-ldl",
#                 "-cclib", "-lpthread",
#             ],
#             "//conditions:default": []
#         }),
#         visibility             = ["//visibility:public"]
#     )

#     ocamlc_optx(
#         name = "ocamlc.optx",
#         prologue = [
#             "//compilerlibs:ocamlcommon",
#             "//bytecomp:ocamlbytecomp"
#         ],
#         main = "//driver:Main",
#         opts = [ ] + select({
#             "//platform/target/os:linux?": [
#                 "-cclib", "-lm",
#                 "-cclib", "-ldl",
#                 "-cclib", "-lpthread",
#             ],
#             "//conditions:default": []
#         }),
#         visibility             = ["//visibility:public"]
#     )

#     ## TODO:
#     ## ocamlopt.optx - optimized, non-optimizing compiler
#     ## built by ocamloptx.optx, but built w/o flambda
#     ## (ocamlc.optx is already an optimized non-optimizing compiler)
#     ocamlopt_optx(
#         name = "ocamlopt.optx",
#         prologue = [
#             "//compilerlibs:ocamlcommon",
#             "//asmcomp:ocamloptcomp"
#         ],
#         main = "//driver:Optmain",
#         opts = [ ] + select({
#             "//platform/target/os:linux?": [
#                 "-cclib", "-lm",
#                 "-cclib", "-ldl",
#                 "-cclib", "-lpthread",
#             ],
#             "//conditions:default": []
#         }),
#         visibility             = ["//visibility:public"]
#     )
