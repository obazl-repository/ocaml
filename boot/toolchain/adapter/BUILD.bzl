load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//toolchain:transitions.bzl", "tool_out_transition")

load("//bzl/rules/common:transitions.bzl",
     "emitter_out_transition",
     "tc_compiler_out_transition",
     "toolchain_in_transition")

##########################################
def _toolchain_adapter_impl(ctx):

    return [platform_common.ToolchainInfo(
        name                   = ctx.label.name,
        _stage                 = ctx.attr._stage,
        build_host             = ctx.attr.build_host,
        target_host            = ctx.attr.target_host,
        _build_emitter        = ctx.attr._build_emitter,
        _target_emitter        = ctx.attr._target_emitter,
        xtarget_host           = ctx.attr.xtarget_host,
        ## vm
        runtime                = ctx.file.runtime,
        vmargs                 = ctx.attr.vmargs,
        repl                   = ctx.file.repl,
        vmlibs                 = ctx.files.vmlibs,
        linkmode               = ctx.attr.linkmode,
        ## runtime
        # stdlib                 = ctx.attr.stdlib,
        # std_exit               = ctx.attr.std_exit,
        # camlheaders            = ctx.files.camlheaders,
        ## core tools
        compiler               = ctx.attr.compiler,
        copts                  = ctx.attr.copts,
        linkopts               = ctx.attr.linkopts,
        warnings               = ctx.attr.warnings,
        lexer                  = ctx.attr.lexer,
        yaccer                 = ctx.file.yaccer,
    )]

###################################
## the rule interface
toolchain_adapter = rule(
    _toolchain_adapter_impl,
    attrs = {
        "_stage" : attr.label( # int_flag
            default = "//config/stage"
        ),

        "build_host": attr.string(
            doc     = "OCaml host platform: vm (bytecode) or an arch.",
            default = "vm"
        ),
        "target_host": attr.label( # string
            doc     = "OCaml target platform: vm (bytecode) or an arch.",
            default = "//config:target_host"
        ),
        "_build_emitter" : attr.label(
            default = "//config/build/emitter",
            # cfg = emitter_out_transition,
        ),
        "_target_emitter" : attr.label(
            default = "//config/target/emitter",
            # cfg = emitter_out_transition,
        ),
        "xtarget_host": attr.label(
            doc     = "Cross-cross target platform: vm (bytecode) or an arch.",
            # default = ""
        ),

        ## Virtual Machine
        "runtime": attr.label(
            doc = "Batch interpreter. ocamlrun, usually",
            allow_single_file = True,
            executable = True,
            cfg = "exec"
            # cfg = runtime_out_transition
        ),

        "vmargs": attr.label( ## string list
            doc = "Args to pass to all invocations of ocamlrun",
            default = "//runtime:args"
        ),

        "repl": attr.label(
            doc = "A/k/a 'toplevel': 'ocaml' command.",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "vmlibs": attr.label_list(
            doc = "Dynamically-loadable libs needed by the ocamlrun vm. Standard location: lib/stublibs. The libs are usually named 'dll<name>_stubs.so', e.g. 'dllcore_unix_stubs.so'.",
            allow_files = True,
        ),
        "linkmode": attr.string(
            doc = "Default link mode: 'static' or 'dynamic'"
            # default = "static"
        ),

        #### runtime stuff ####
        # "stdlib": attr.label(
        #     default   = "//boot/toolchain:stdlib",
        #     executable = False,
        #     # allow_single_file = True,
        #     # cfg = "exec",
        # ),

        # "std_exit": attr.label(
        #     # default = Label("//stdlib:Std_exit"),
        #     executable = False,
        #     allow_single_file = True,
        #     # cfg = "exec",
        # ),

        # "camlheaders": attr.label_list(
        #     allow_files = True,
        #     default = ["//stdlib:camlheaders"]
        # ),

        ################################
        ## Core Tools
        "compiler": attr.label(
            default = "//boot/toolchain:compiler",
            allow_files = True,
            executable = True,
            # cfg = "exec"
            cfg = tc_compiler_out_transition
        ),

        "lexer": attr.label(
            default = "//boot/toolchain:lexer",
            executable = True,
            # cfg = "exec",
            cfg = tc_compiler_out_transition
        ),

        "yaccer": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),

        "copts" : attr.string_list(
        ),
        "warnings" : attr.label( ## string list
            default = "//config:warnings",
        ),
        "linkopts" : attr.string_list(
        ),

        #### other tools - just those needed for builds ####
        # ocamldep ocamlprof ocamlcp ocamloptp
        # ocamlmklib ocamlmktop
        # ocamlcmt
        # dumpobj ocamlobjinfo
        # primreq stripdebug cmpbyt

        ## https://bazel.build/docs/integrating-with-rules-cc
        ## hidden attr required to make find_cpp_toolchain work:
        # "_cc_toolchain": attr.label(
        #     default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        # ),
        # "_cc_opts": attr.string_list(
        #     default = ["-Wl,-no_compact_unwind"]
        # ),

        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),

    },
    # cfg = toolchain_in_transition,
    doc = "Defines a toolchain for bootstrapping the OCaml toolchain",
    provides = [platform_common.ToolchainInfo],

    ## NB: config frags evidently expose CLI opts like `--cxxopt`;
    ## see https://docs.bazel.build/versions/main/skylark/lib/cpp.html

    ## fragments: linux, apple?
    fragments = ["cpp", "platform"], ## "apple"],
    host_fragments = ["cpp", "platform"], ##, "apple"],

    ## executables need this to link cc stuff:
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##########################################
# def _stdlib_toolchain_adapter_impl(ctx):

#     return [platform_common.ToolchainInfo(
#         # Public fields
#         name                   = ctx.label.name,
#         build_host             = ctx.attr.build_host,
#         target_host            = ctx.attr.target_host,
#         ## runtime
#         stdlib                 = ctx.attr.stdlib,
#         std_exit               = ctx.file.std_exit,
#         # camlheaders            = ctx.files.camlheaders,
#     )]

# ###################################
# ## the rule interface
# stdlib_toolchain_adapter = rule(
#     _stdlib_toolchain_adapter_impl,
#     attrs = {
#         "stdlib": attr.label(
#             default   = "//boot/toolchain:stdlib",
#             executable = False,
#             # allow_single_file = True,
#             # cfg = "exec",
#         ),

#         "std_exit": attr.label(
#             default = Label("//boot/toolchain:std_exit"),
#             executable = False,
#             allow_single_file = True,
#             # cfg = "exec",
#         ),

#         # "camlheaders": attr.label_list(
#         #     allow_files = True,
#         #     default = ["//stdlib:camlheaders"]
#         # ),

#         "build_host": attr.string(
#             doc     = "OCaml host platform: vm (bytecode) or an arch.",
#             default = "vm"
#         ),
#         "target_host": attr.string(
#             doc     = "OCaml target platform: vm (bytecode) or an arch.",
#             default = "vm"
#         ),
#         "xtarget_host": attr.string(
#             doc     = "Cross-cross target platform: vm (bytecode) or an arch.",
#             default = ""
#         ),



#     },
#     cfg = toolchain_in_transition,
#     doc = "Defines a stdlib for bootstrapping the OCaml toolchain",
#     provides = [platform_common.ToolchainInfo],
# )
