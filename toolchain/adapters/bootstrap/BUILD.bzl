load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "C_COMPILE_ACTION_NAME")

load("//toolchain:transitions.bzl", "tool_out_transition")

## exports: bootstrap_toolchain_adapter (rule). includes stuff only
## used during bootstrapping, e.g. primitives.

## obtaining CC toolchain:  https://github.com/bazelbuild/bazel/issues/7260

##################################################
def _toolchain_in_transition_impl(settings, attr):
    # print("toolchain_in_transition_impl")

    ## trying to make sure ocamlrun is only built once

    return {
        "//bzl/toolchain:ocamlrun" : "//boot/bin:ocamlrun"
    }

#######################
toolchain_in_transition = transition(
    implementation = _toolchain_in_transition_impl,
    inputs = [
        "//bzl/toolchain:ocamlrun"
    ],
    outputs = [
        "//bzl/toolchain:ocamlrun"
    ]
)

######################################################
def _tool_runner_out_transition_impl(settings, attr):
    # print("tool_runner_out_transition")
    # print("  stage: %s" % settings["//bzl:stage"])
    # print("//bzl/toolchain:ocamlc: %s" %
    #       settings["//bzl/toolchain:ocamlc"])

    boot_host = "//platforms/build:boot"

    return {
        "//command_line_option:host_platform" : boot_host,
        "//command_line_option:platforms"     : boot_host
    }

tool_runner_out_transition = transition(
    implementation = _tool_runner_out_transition_impl,
    inputs = [
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ],
    outputs = [
        "//command_line_option:host_platform",
        "//command_line_option:platforms"
    ]
)

################################################################
#### rule, with in-transition ####
def _bootstrap_toolchain_adapter_impl(ctx):

    copts = []
    # if ctx.file.primitives:
    #     copts.extend(["-use-prims", ctx.file.primitives.path])
    # copts.extend(ctx.attr.copts)

    return [platform_common.ToolchainInfo(
        # Public fields
        name                   = ctx.label.name,
        build_host             = ctx.attr.build_host,
        target_host            = ctx.attr.target_host,
        xtarget_host            = ctx.attr.xtarget_host,
        ## vm
        tool_runner            = ctx.file.tool_runner,
        vmargs                 = ctx.attr.vmargs,
        repl                   = ctx.file.repl,
        vmlibs                 = ctx.files.vmlibs,
        linkmode               = ctx.attr.linkmode,
        ## runtime
        stdlib                 = ctx.attr.stdlib,
        # std_exit               = ctx.attr.std_exit,
        camlheaders            = ctx.files.camlheaders,
        ## core tools
        compiler               = ctx.attr.compiler,
        copts                  = ctx.attr.copts,
        linkopts               = ctx.attr.linkopts,
        primitives             = ctx.file.primitives,
        lexer                  = ctx.attr.lexer,
        yacc                   = ctx.file.yacc,
    )]

###################################
## the rule interface
bootstrap_toolchain_adapter = rule(
    _bootstrap_toolchain_adapter_impl,
    attrs = {

        "build_host": attr.string(
            doc     = "OCaml host platform: vm (bytecode) or an arch.",
            default = "vm"
        ),
        "target_host": attr.string(
            doc     = "OCaml target platform: vm (bytecode) or an arch.",
            default = "vm"
        ),
        "xtarget_host": attr.string(
            doc     = "Cross-cross target platform: vm (bytecode) or an arch.",
            default = ""
        ),

        ## Virtual Machine
        "tool_runner": attr.label(
            doc = "Batch interpreter. ocamlrun, usually",
            allow_single_file = True,
            executable = True,
            cfg = tool_runner_out_transition
        ),

        "vmargs": attr.label( ## string list
            doc = "Args to pass to all invocations of ocamlrun",
            default = "//platforms/vm:args"
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

        #### runtime
        "stdlib": attr.label(
            # default   = "//stdlib",
            executable = False,
            # allow_single_file = True,
            # cfg = "exec",
        ),

        # "std_exit": attr.label(
        #     # default = Label("//stdlib:Std_exit"),
        #     executable = False,
        #     allow_single_file = True,
        #     # cfg = "exec",
        # ),

        "camlheaders": attr.label_list(
            allow_files = True,
            # default = [
            #     # "//stdlib:camlheaders"
            #     "//stdlib:camlheader", "//stdlib:target_camlheader",
            #     "//stdlib:camlheaderd", "//stdlib:target_camlheaderd",
            #     "//stdlib:camlheaderi", "//stdlib:target_camlheaderi"
            # ],
        ),

        ################################
        ## Core Tools
        "compiler": attr.label(
            ## providers constraints seem to be ignored
            # providers = [["OcamlArchiveMarker"]],
            # allow_single_file = True,
            ## vm>* not executable
            ## sys>* executable
            # executable = True,
            # cfg = "exec",
        ),
        "copts" : attr.string_list(
        ),
        "primitives" : attr.label(
            allow_single_file = True
        ),
        "linkopts" : attr.string_list(
        ),
        "lexer": attr.label(
            # allow_single_file = True,
            # executable = True,
            # cfg = "exec",
        ),

        "yacc": attr.label(
            allow_single_file = True,
            # executable = True,
            # cfg = "exec",
        ),

        #### other tools - just those needed for builds ####
        # ocamldep ocamlprof ocamlcp ocamloptp
        # ocamlmklib ocamlmktop
        # ocamlcmt
        # dumpobj ocamlobjinfo
        # primreq stripdebug cmpbyt

        ## https://bazel.build/docs/integrating-with-rules-cc
        ## hidden attr required to make find_cpp_toolchain work:
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),
        # "_cc_opts": attr.string_list(
        #     default = ["-Wl,-no_compact_unwind"]
        # ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    },
    cfg = toolchain_in_transition,
    doc = "Defines a toolchain for bootstrapping the OCaml toolchain",
    provides = [platform_common.ToolchainInfo],

    ## NB: config frags evidently expose CLI opts like `--cxxopt`;
    ## see https://docs.bazel.build/versions/main/skylark/lib/cpp.html

    ## fragments: linux, apple?
    fragments = ["cpp", "platform"], ## "apple"],
    host_fragments = ["cpp", "platform"], ##, "apple"],

    ## ocaml toolchain adapter depends on cc toolchain
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"]
)

################
def _dump_cc_toolchain(ctx):
    print("**** CcToolchainInfo ****")

    cctc = find_cpp_toolchain(ctx)
    print("cctc type: %s" % type(cctc))
    items = dir(cctc)
    for item in items:
        print("{item}".format(item=item))
        val = getattr(cctc, item)
        print("  t: %s" % type(val))
        # if item == "dynamic_runtime_lib":
        #     print(":: %s" % cctc.dynamic_runtime_lib(
        #         feature_configuration = cc_common.configure_features(
        #             ctx = ctx,
        #             cc_toolchain = cctc,
        #             requested_features = ctx.features,
        #             unsupported_features = ctx.disabled_features,
        #         )
        #     ))
        # if item == "linker_files":
        #     print(":: %s" % cctc.linker_files)

################
def _dump_tc_frags(ctx):
    print("**** host platform frags: %s" % ctx.host_fragments.platform)
    ds = dir(ctx.host_fragments.platform)
    for d in ds:
        print("\t{d}:\n\t{dval}".format(
            d = d, dval = getattr(ctx.host_fragments.platform, d)))
        _platform = ctx.host_fragments.platform.platform

    print("**** target platform frags: %s" % ctx.fragments.platform)
    ds = dir(ctx.fragments.platform)
    for d in ds:
        print("\t{d}:\n\t{dval}".format(
            d = d, dval = getattr(ctx.host_fragments.platform, d)))
    _platform = ctx.host_fragments.platform.platform

    if ctx.host_fragments.apple:
        _cc_opts = ["-Wl,-no_compact_unwind"]
        print("**** host apple frags: %s" % ctx.host_fragments.apple)
        ds = dir(ctx.host_fragments.apple)
        for d in ds:
            print("\t{d}:\n\t{dval}".format(
                d = d, dval = getattr(ctx.host_fragments.apple, d)))
    else:
        _cc_opts = []

    print("**** host cpp frags: %s" % ctx.host_fragments.cpp)
    ds = dir(ctx.fragments.cpp)
    for d in ds:
        print("\t{d}:\n\t{dval}".format(
            d = d,
            dval = getattr(ctx.fragments.cpp, d) if d != "custom_malloc" else ""))

    print("**** target cpp frags: %s" % ctx.fragments.cpp)
    ds = dir(ctx.fragments.cpp)
    for d in ds:
        print("\t{d}:\n\t{dval}".format(
            d = d,
            dval = getattr(ctx.fragments.cpp, d) if d != "custom_malloc" else ""))

