load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//toolchain:transitions.bzl", "tool_out_transition")

load("//bzl/rules/common:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")

##########################################
def _dev_toolchain_adapter_impl(ctx):

    ## avoid transition?
    return [platform_common.ToolchainInfo(
        name                   = ctx.label.name,
        dev                    = True,
        # _stage                 = ctx.attr._stage,
        # build_host             = ctx.attr.build_host,
        # target_host            = ctx.attr.target_host,
        # _build_executor        = ctx.attr._build_executor,
        # build_emitter          = ctx.attr.build_emitter,
        # target_runtime         = ctx.attr.target_runtime,

        config_executor        = ctx.attr.config_executor,
        config_emitter         = ctx.attr.config_emitter,

        target_executor        = ctx.attr.target_executor, # [TargetInfo],
        target_emitter         = ctx.attr.target_emitter,
        ## vm
        runtime                = ctx.file.runtime,
        vmargs                 = ctx.attr.vmargs,
        repl                   = ctx.file.repl,
        vmlibs                 = ctx.files.vmlibs,
        linkmode               = ctx.attr.linkmode,
        ## runtime
        # stdlib                 = ctx.attr.stdlib,
        # std_exit               = ctx.attr.std_exit,

        ##FIXME: camlheaders only for vm executor
        ## should we have separate tcs for vm and sys executors?
        camlheaders            = ctx.files.camlheaders,

        ## core tools
        compiler               = ctx.file.compiler,
        copts                  = ctx.attr.copts,
        linkopts               = ctx.attr.linkopts,
        warnings               = ctx.attr.warnings,
        lexer                  = ctx.attr.lexer,
        yaccer                 = ctx.file.yaccer,
    )]

###################################
## the rule interface
dev_toolchain_adapter = rule(
    _dev_toolchain_adapter_impl,
    attrs = {
        "config_executor": attr.label(default = "//config/target/executor"),
        "config_emitter" : attr.label(default = "//config/target/emitter"),
        "target_executor": attr.label(default = "//toolchain/target/executor"),
        "target_emitter" : attr.label(default = "//toolchain/target/emitter"),

        ## Virtual Machine
        "runtime": attr.label(
            doc = "Batch interpreter. ocamlrun, usually",
            allow_single_file = True,
            default = "@baseline//bin:ocamlrun",
            executable = True,
            cfg = "exec"
            # cfg = reset_config_transition
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
        ##FIXME: only for VM executor
        "camlheaders": attr.label_list(
            allow_files = True,
            default = ["//config/camlheaders"]
        ),

        ################################
        ## Core Tools
        "_ocamlc_opt": attr.label(
            default = "@baseline//bin:ocamlc.opt",
            allow_single_file = True,
            # allow_files = True,
            executable = True,
            cfg = "exec"),
        "_ocamlopt_opt": attr.label(
            default = "@baseline//bin:ocamlopt.opt",
            allow_single_file = True,
            # allow_files = True,
            executable = True,
            cfg = "exec"),

        "compiler": attr.label(
            default = "//toolchain/dev:compiler",
            allow_single_file = True,
            # allow_files = True,
            executable = True,
            # cfg = "exec"
            cfg = dev_tc_compiler_out_transition
        ),

        "lexer": attr.label(
            default = "//toolchain/dev:lexer",
            allow_single_file = True,
            executable = True,
            # cfg = "exec",
            cfg = dev_tc_compiler_out_transition
        ),

        "yaccer": attr.label(
            default = "//yacc:ocamlyacc",
            allow_single_file = True,
            executable = True,
            # cfg = "exec",
            cfg = dev_tc_compiler_out_transition
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
    # cfg = tc_compiler_out_transition, # toolchain_in_transition,
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
