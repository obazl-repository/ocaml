load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "BootInfo")

load("//toolchain:transitions.bzl", "tool_out_transition")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

load("//bzl/transitions:tc_transitions.bzl",
     "tc_compiler_out_transition",
     "tc_runtime_out_transition")

load(":tc_utils.bzl",
     "tc_build_executor",
     "tc_tool_arg",
     "tc_executable",
     "tc_compiler",
     "tc_workdir")

#################################
def _toolchain_adapter_impl(ctx):

    _config_executor = ctx.attr.config_executor[BuildSettingInfo].value
    _config_emitter  = ctx.attr.config_emitter[BuildSettingInfo].value

    return [platform_common.ToolchainInfo(
        name                   = ctx.label.name,
        protocol               = ctx.attr.protocol,

        build_executor         = tc_build_executor(ctx),

        config_executor        = _config_executor,
        config_emitter         = _config_emitter,

        workdir                = tc_workdir(ctx),

        ## vm
        ocamlrun               = ctx.file.ocamlrun,
        vmargs                 = ctx.attr.vmargs,
        repl                   = ctx.file.repl,
        vmlibs                 = ctx.files.vmlibs,
        linkmode               = ctx.attr.linkmode,

        ##FIXME: camlheaders only for vm executor
        ## should we have separate tcs for vm and sys executors?
        # camlheaders            = ctx.files.camlheaders,

        ## core tools
        executable             = tc_executable(ctx, "compiler"),
        tool_arg               = tc_tool_arg(ctx),

        compiler               = tc_compiler(ctx),
        # lexer                  = ctx.attr.lexer,
        cvt_emit               = ctx.file.cvt_emit,

        runtime                = ctx.file.runtime,
        copts                  = ctx.attr.copts,
        sigopts                = ctx.attr.sigopts,
        structopts             = ctx.attr.structopts,
        linkopts               = ctx.attr.linkopts,
        warnings               = ctx.attr.warnings,

        # yaccer                 = ctx.file.yaccer,
    )]

###################################
## the rule interface
toolchain_adapter = rule(
    _toolchain_adapter_impl,
    doc = "Defines a toolchain for bootstrapping the OCaml toolchain",
    attrs = {
        "protocol": attr.label(default = "//config/build/protocol"),
        # "build_host": attr.string(
        #     doc     = "OCaml host platform: vm (bytecode) or an arch.",
        #     default = "vm"
        # ),
        # "target_host": attr.label( # string
        #     doc     = "OCaml target platform: vm (bytecode) or an arch.",
        #     default = "//config:target_host"
        # ),
        # "_build_executor" : attr.label(
        #     default = "//config/build/executor",
        # ),

        # "build_emitter" : attr.label(
        #     default = "//config/build/emitter",
        #     # cfg = emitter_out_transition,
        # ),

        "config_executor": attr.label(default = "//config/target/executor"),
        "config_emitter" : attr.label(default = "//config/target/emitter"),

        "ocamlrun": attr.label(
            doc = "ocaml",
            allow_single_file = True,
            default = "//toolchain:ocamlrun",
            executable = True,
            # cfg = "exec"
            cfg = reset_cc_config_transition
        ),

        ## Virtual Machine
        "runtime": attr.label( # the lib, not ocamlrun
            doc = "Batch interpreter. ocamlrun, usually",
            default = "//toolchain:runtime",
            allow_single_file = True,
            executable = False,
            # cfg = "exec"
            cfg = reset_cc_config_transition
            # cfg = tc_runtime_out_transition
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
        # "camlheaders": attr.label_list(
        #     allow_files = True,
        #     default = ["//config/camlheaders"]
        # ),

        ################################
        ## Core Tools
        "compiler": attr.label(
            default = "//toolchain:compiler",
            allow_single_file = True,
            executable = True,
            # cfg = "exec"
            cfg = tc_compiler_out_transition
        ),

        # "lexer": attr.label(
        #     # default = "//boot:ocamllex.boot",
        #     default = "//toolchain:lexer",
        #     allow_single_file = True,
        #     executable = True,
        #     # cfg = tc_compiler_out_transition
        #     cfg = tc_lexer_out_transition
        # ),

        "cvt_emit": attr.label(
            default = "//boot:ocamllex.boot", # fake, will be transitioned
            # default = "//toolchain:cvt_emit",
            allow_single_file = True,
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
    provides = [platform_common.ToolchainInfo],

    ## NB: config frags evidently expose CLI opts like `--cxxopt`;
    ## see https://docs.bazel.build/versions/main/skylark/lib/cpp.html

    ## fragments: linux, apple?
    fragments = ["cpp", "platform"], ## "apple"],
    host_fragments = ["cpp", "platform"], ##, "apple"],

    ## executables need this to link cc stuff:
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"]
)
