load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

# load("//toolchain:tc_transitions.bzl", "tool_out_transition")

load("//bzl/transitions:tc_transitions.bzl",
     "tc_boot_in_transition",
     "tc_lexer_out_transition",
     "tc_runtime_out_transition")

##########################################
def _boot_toolchain_adapter_impl(ctx):

    return [platform_common.ToolchainInfo(
        name                   = ctx.label.name,
        dev                    = False,
        config_executor        = ctx.attr.config_executor,
        config_emitter         = ctx.attr.config_emitter,

        target_executor        = ctx.attr.target_executor, # [TargetInfo],
        target_emitter         = ctx.attr.target_emitter,
        ## vm
        ocamlrun               = ctx.file.ocamlrun,
        vmargs                 = ctx.attr.vmargs,

        ## core tools
        compiler               = ctx.attr.compiler,
        runtime                = ctx.file.runtime,
        copts                  = ctx.attr.copts,
        sigopts                = ctx.attr.sigopts,
        structopts             = ctx.attr.structopts,
        linkopts               = ctx.attr.linkopts,
        warnings               = ctx.attr.warnings,
        lexer                  = ctx.attr.lexer,
        # yaccer                 = ctx.file.yaccer,
    )]

###################################
## the rule interface
boot_toolchain_adapter = rule(
    _boot_toolchain_adapter_impl,
    doc = "Toolchain for building build_tool preprocessors",
    attrs = {
        "config_executor": attr.label(default = "//config/target/executor"),
        "config_emitter" : attr.label(default = "//config/target/emitter"),
        "target_executor": attr.label(default = "//toolchain/target/executor"),
        "target_emitter" : attr.label(default = "//toolchain/target/emitter"),

        "ocamlrun": attr.label(
            doc = "ocaml",
            allow_single_file = True,
            default = "//toolchain:ocamlrun",
            executable = True,
            # cfg = "exec"
            cfg = reset_cc_config_transition
        ),

        ## Virtual Machine
        ## putting runtime in tc w/transitions caused spurious rebuilds on transition (????)
        # "target_runtime" : attr.label(default = "//toolchain:runtime"),
        "runtime": attr.label( # the lib, not ocamlrun
            doc = "Batch interpreter. ocamlrun, usually",
            # default = "//toolchain:runtime",
            default = "//runtime:camlrun",
            allow_single_file = True,
            executable = False,
            # cfg = "exec"
            cfg = tc_runtime_out_transition
        ),

        "vmargs": attr.label( ## string list
            doc = "Args to pass to all invocations of ocamlrun",
            default = "//runtime:args"
        ),

        ################################
        ## Core Tools
        "compiler": attr.label(
            default = "//boot:ocamlc.boot",
            allow_single_file = True,
            executable = True,
            cfg = "exec"
            # cfg = tc_boot_out_transition
        ),

        "lexer": attr.label(
            default = "//boot:ocamllex.boot",
            executable = True,
            cfg = "exec",
            # cfg = tc_lexer_out_transition
        ),

        # "yaccer": attr.label(
        #     default = "//yacc:ocamlyacc",
        #     allow_single_file = True,
        #     executable = True,
        #     # cfg = "exec",
        #     cfg = tc_compiler_out_transition
        # ),

        "copts" : attr.string_list(
            doc = "Common compile options, for both .ml and .mli"
        ),
        "sigopts" : attr.string_list(
            doc = "Compile options .mli files"
        ),
        "structopts" : attr.string_list(
            doc = "Compile options .ml files"
        ),
        # "archiveopts" : attr.string_list(
        #     doc = "Options for building archive files."
        # ),
        "linkopts" : attr.string_list( ),
        "warnings" : attr.label( ## string list
            default = "//config:warnings",
        ),

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
    cfg = tc_boot_in_transition,
    provides = [platform_common.ToolchainInfo],

    ## NB: config frags evidently expose CLI opts like `--cxxopt`;
    ## see https://docs.bazel.build/versions/main/skylark/lib/cpp.html

    ## fragments: linux, apple?
    fragments = ["cpp", "platform"], ## "apple"],
    host_fragments = ["cpp", "platform"], ##, "apple"],

    ## executables need this to link cc stuff:
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"]
)
