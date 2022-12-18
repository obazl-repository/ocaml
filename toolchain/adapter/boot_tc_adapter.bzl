load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

# load("//toolchain:tc_transitions.bzl", "tool_out_transition")

load("//bzl/transitions:tc_transitions.bzl",
     "tc_boot_in_transition",
     "tc_lexer_out_transition",
     "tc_runtime_out_transition")

load(":BUILD.bzl", "tc_workdir", "tc_build_executor")

###################
# returns file, no runfiles
def _executable(ctx, tool):
    debug = False
    if debug:
        print("boot tc.executable")
        print("tc.name: %s" % ctx.attr.name)

    if ctx.attr.dev:
        # native only
        if tool == "compiler":
            return ctx.file.compiler
        else:
            return ctx.file.lexer
    else:
        if debug:
            print("lx tc.build_executor: %s" % tc_build_executor(ctx))
        ## tc.compiler runfiles: bottom element is always ocamlrun
        if tc_build_executor(ctx) == "vm":
            if type(ctx.attr.lexer) == "list":
                ## built tool, transitioned
                if tool == "compiler":
                    xocamlrun =  ctx.attr.compiler[DefaultInfo].default_runfiles.files.to_list()[0]
                else:
                    xocamlrun =  ctx.attr.lexer[DefaultInfo].default_runfiles.files.to_list()[0]
                if debug:
                    print("lx XOCAMLRUN: %s" % xocamlrun)
                return xocamlrun

            else:
                ## boot exer
                if debug:
                    print("lx TX: %s" % ctx.attr.lexer[DefaultInfo])
                if tool == "compiler":
                    ocamlrun = ctx.attr.compiler[DefaultInfo].default_runfiles.files.to_list()[0]
                else:
                    ocamlrun = ctx.attr.lexer[DefaultInfo].default_runfiles.files.to_list()[0]

                if debug:
                    print("lx OCAMLRUN: %s" % ocamlrun)
                return ocamlrun
        else:
            if debug:
                print("lx returning tc lex: %s" % ctx.attr.lexer[0][DefaultInfo].files_to_run.executable)

            if tool == "compiler":
                return ctx.attr.compiler[DefaultInfo].files_to_run.executable
            else:
                return ctx.attr.lexer[DefaultInfo].files_to_run.executable

###################
# returns attr with runfiles
def _lexer(ctx):
    debug = False
    if debug:
        print("tc_lexer")
        print("tc.name: %s" % ctx.attr.name)

    if ctx.attr.dev:
        # native only
        return ctx.attr.lexer
    else:
        return ctx.attr.lexer

#################
def _tool_arg(ctx, tool):
    print("_TOOL_ARG")
    print("tc.config_executor: %s" % ctx.attr.config_executor[BuildSettingInfo].value)
    if type(ctx.attr.lexer) == "list":
        if tool == "lexer":
            tcc = ctx.attr.lexer[0][DefaultInfo].files_to_run.executable
        else:
            tcc = ctx.attr.compiler[0][DefaultInfo].files_to_run.executable
    else:
        if tool == "lexer":
            tcc = ctx.attr.lexer[DefaultInfo].files_to_run.executable
        else:
            tcc = ctx.attr.compiler[DefaultInfo].files_to_run.executable
    print("tcc: %s" % tcc)

    if ctx.attr.dev:
        return None
    else:
        if ctx.attr.config_executor[BuildSettingInfo].value in ["boot", "vm"]:
            # most recently built compiler
            return tcc
        else:
            # return tc.lexer[DefaultInfo].files_to_run.executable
            return tcc

##########################################
def _boot_toolchain_adapter_impl(ctx):

    config_executor = ctx.attr.config_executor[BuildSettingInfo].value

    return [platform_common.ToolchainInfo(
        name                   = ctx.label.name,
        dev                    = ctx.attr.dev,

        build_executor         = tc_build_executor(ctx),

        config_executor        = config_executor,
        config_emitter         = ctx.attr.config_emitter,

        workdir                = tc_workdir(ctx),

        ## vm
        ocamlrun               = ctx.file.ocamlrun,
        vmargs                 = ctx.attr.vmargs,

        ## core tools
        compiler               = ctx.attr.compiler,
        cexecutable            = _executable(ctx, "compiler"),
        compiler_arg           = _tool_arg(ctx, "compiler"),

        lexer                  = ctx.attr.lexer,
        lexecutable            = _executable(ctx, "lexer"),
        lexer_arg              = _tool_arg(ctx, "lexer"),

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
boot_toolchain_adapter = rule(
    _boot_toolchain_adapter_impl,
    doc = "Toolchain for building build_tool preprocessors",
    attrs = {
        "dev": attr.bool(default = False),

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
