load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "BootInfo")

load("//toolchain:transitions.bzl", "tool_out_transition")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

load("//bzl/transitions:tc_transitions.bzl",
     "tc_compiler_out_transition",
     "tc_lexer_out_transition",
     "tc_runtime_out_transition")

#################
def tc_build_executor(ctx):
    debug = True
    if debug:
        print("tc.build_executor")

    if ctx.attr.dev:
        build_executor = "opt"
    else:
        # we can always infer build_emitter from target_executor
        # in general we cannot so infer build_executor.
        # however in this controlled environment we always know
        # how target executor/emitter combinations are built,
        # so we can infer build executor from that pair.

        ## NB: "config" means target (//config/target/[executor|emitter])
        t_executor = ctx.attr.config_executor[BuildSettingInfo].value
        t_emitter  = ctx.attr.config_emitter[BuildSettingInfo].value

        if debug:
            print("t_executor: %s" % t_executor)
            print("t_emitter: %s" % t_emitter)

        stack = "boot"  ## FIXME: use //config/stack:fixed-point?
        baseline = False

        if (t_executor == "boot" and t_emitter == "boot"):
            build_executor = "vm"
        elif (t_executor == "baseline" and t_emitter == "baseline"):
            build_executor = "vm"

        elif (t_executor == "vm" and t_emitter == "vm"):
            # target: ocamlc.byte
            build_executor = "vm"

        elif (t_executor == "vm" and t_emitter == "sys"):
            # target: ocamlopt.byte
            build_executor = "vm"

        elif (t_executor == "sys" and t_emitter == "sys"):
            # target: ocamlopt.opt
            if stack == "fixed-point":
                if baseline:
                    # _baseline/ocamlopt.opt built by _fp/ocamlopt.byte
                    build_executor = "vm"
                else:
                    # _fp/ocamlopt.opt built by _baseline/ocamlopt.opt
                    build_executor = "sys"
            else:
                # built by ocamlopt.byte
                build_executor = "vm"

        elif (t_executor == "sys" and t_emitter == "vm"):
            # target: ocamlc.opt
            if stack == "fixed-point":
                # _fp/ocamlc.opt built by _fp/ocamlopt.opt
                build_executor = "sys"
            else:
                # ocamlc.opt built by ocamlopt.byte
                # FIXME: implement boot, fixed-point protocols
                build_executor = "sys"  # legacy, should be vm

        else:
            build_executor = "ERROR"

    print("TC.BUILD_EXECUTOR: %s" % build_executor)
    return build_executor

#################
def _tool_arg(ctx):
    debug = False

    if debug:
        print("TC.TOOL_ARG")
        print("tc.config_executor: %s" % ctx.attr.config_executor[BuildSettingInfo].value)
    if type(ctx.attr.compiler) == "list":
        tcc = ctx.attr.compiler[0][DefaultInfo].files_to_run.executable
    else:
        tcc = ctx.attr.compiler[DefaultInfo].files_to_run.executable
    if debug:
        print("tc.compiler: %s" % tcc)

    if ctx.attr.dev:
        return None
    else:
        # if ctx.attr.config_executor[BuildSettingInfo].value in ["boot", "baseline", "vm"]:
        if tc_build_executor(ctx) in ["boot", "baseline", "vm"]:
            # most recently built compiler
            return tcc
        else:
            # return tc.compiler[DefaultInfo].files_to_run.executable
            return None

###################
def _executable(ctx):
    debug = False
    if debug:
        print("_executable")
        print("tc.name: %s" % ctx.attr.name)

    if ctx.attr.dev:
        # native only
        return ctx.attr.compiler # ctx.file.compiler?
    else:
        ## tc.compiler runfiles: bottom element is always ocamlrun
        if tc_build_executor(ctx) == "vm":
            if type(ctx.attr.compiler) == "list":
                ## built compiler, transitioned

                xocamlrun =  ctx.attr.compiler[0][DefaultInfo].default_runfiles.files.to_list()[0]
                if debug:
                    print("XOCAMLRUN: %s" % xocamlrun)
                return xocamlrun

            else:
                ## boot compiler
                if debug:
                    print("TX: %s" % ctx.attr.compiler[DefaultInfo])
                ocamlrun = ctx.attr.compiler[DefaultInfo].default_runfiles.files.to_list()[0]
                if debug:
                    print("OCAMLRUN: %s" % ocamlrun)
                return ocamlrun
        else:
            if debug:
                print("returning ctx.attr.ex: %s" % ctx.attr.compiler[0][DefaultInfo].files_to_run.executable)
            return ctx.attr.compiler[0][DefaultInfo].files_to_run.executable

####################
def _compiler(ctx):

    if type(ctx.attr.compiler) == "list":
        # because of transitions
        return ctx.attr.compiler[0]
    else:
        return ctx.attr.compiler

###################
## FIXME: merge tc_build_executor and tc_workdir
def tc_workdir(ctx):

    config_executor = ctx.attr.config_executor[BuildSettingInfo].value
    config_emitter  = ctx.attr.config_emitter[BuildSettingInfo].value

    if (config_executor == "boot"):
        workdir = "_boot/"

    elif (config_executor == "baseline"):
        workdir = "_baseline/"

    # elif (config_executor == "vm" and config_emitter == "boot"):
    #     if tc.dev:
    #         # dev mode, passing only --//config/target/executor=vm
    #         workdir = "_ocamlc.opt/"
    #     else:
    #         workdir = "_ocamlc.byte/"

    elif (config_executor == "vm" and config_emitter == "vm"):
        workdir = "_ocamlc.byte/"

    elif (config_executor == "vm" and config_emitter == "sys"):
        workdir = "_ocamlopt.byte/"

    # elif (config_executor == "sys" and config_emitter == "boot"):
    #     if tc.dev:
    #         # dev mode, passing only --//config/target/executor=sys
    #         workdir = "_ocamlopt.opt/"
    #     else:
    #         workdir = "_ocamlc.opt/"

    elif (config_executor == "sys" and config_emitter == "vm"):
        workdir = "_ocamlc.opt/"

    elif (config_executor == "sys" and config_emitter == "sys"):
        workdir = "_ocamlopt.opt/"

    else:
        print("config_executor: %s" % config_executor)
        print("config_emitter: %s" % config_emitter)
        fail("BAD CONFIG")

    return workdir

##########################################
def _toolchain_adapter_impl(ctx):

    config_executor = ctx.attr.config_executor[BuildSettingInfo].value
    config_emitter  = ctx.attr.config_emitter[BuildSettingInfo].value

    return [platform_common.ToolchainInfo(
        name                   = ctx.label.name,
        dev                    = ctx.attr.dev,

        build_executor         = tc_build_executor(ctx),

        config_executor        = config_executor,
        config_emitter         = config_emitter,

        # target_executor        = ctx.attr.target_executor, # [TargetInfo],
        # target_emitter         = ctx.attr.target_emitter,

        workdir                = tc_workdir(ctx),

        ## vm
        ocamlrun               = ctx.file.ocamlrun,
        vmargs                 = ctx.attr.vmargs,
        repl                   = ctx.file.repl,
        vmlibs                 = ctx.files.vmlibs,
        linkmode               = ctx.attr.linkmode,
        ## runtime
        # stdlib                 = ctx.attr.stdlib,
        # std_exit               = ctx.attr.std_exit,

        ##FIXME: camlheaders only for vm executor
        ## should we have separate tcs for vm and sys executors?
        # camlheaders            = ctx.files.camlheaders,

        ## core tools
        executable             = _executable(ctx),
        tool_arg               = _tool_arg(ctx),

        compiler               = _compiler(ctx),
        runtime                = ctx.attr.runtime,
        copts                  = ctx.attr.copts,
        sigopts                = ctx.attr.sigopts,
        structopts             = ctx.attr.structopts,
        linkopts               = ctx.attr.linkopts,
        warnings               = ctx.attr.warnings,
        # lexer                  = ctx.attr.lexer,
        # yaccer                 = ctx.file.yaccer,
    )]

###################################
## the rule interface
toolchain_adapter = rule(
    _toolchain_adapter_impl,
    doc = "Defines a toolchain for bootstrapping the OCaml toolchain",
    attrs = {
        "dev": attr.bool(default = False),
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
            cfg = tc_runtime_out_transition
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
        #     default   = "//toolchain:stdlib",
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

        ##FIXME: only for VM executor
        # "camlheaders": attr.label_list(
        #     allow_files = True,
        #     default = ["//config/camlheaders"]
        # ),

        ################################
        ## Core Tools
        "compiler": attr.label(
            default = "//toolchain:compiler",
            allow_files = True,
            executable = True,
            # cfg = "exec"
            cfg = tc_compiler_out_transition
        ),

        # "lexer": attr.label(
        #     default = "//toolchain:lexer",
        #     executable = True,
        #     # cfg = "exec",
        #     cfg = tc_lexer_out_transition
        # ),

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
