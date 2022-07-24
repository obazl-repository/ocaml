load("//bzl/transitions:toolchain.bzl",
     "toolchain_in_transition",
     "ocamlrun_out_transition")

def _bootstrap_toolchain_adapter_impl(ctx):

    # if ctx.host_fragments.apple:
    #     _cc_opts = ["-Wl,-no_compact_unwind"]
    # else:
    #     _cc_opts = []

    # the_cc_toolchain = find_cpp_toolchain(ctx)
    # feature_configuration = cc_common.configure_features(
    #     ctx = ctx,
    #     cc_toolchain = the_cc_toolchain,
    #     requested_features = ctx.features,
    #     unsupported_features = ctx.disabled_features,
    # )
    # _c_exe = cc_common.get_tool_for_action(
    #     feature_configuration = feature_configuration,
    #     action_name = C_COMPILE_ACTION_NAME,
    # )

    return [
        platform_common.ToolchainInfo(
        name = ctx.label.name,
        path       = ctx.attr.path,
        linkmode       = ctx.attr.linkmode,
        target_vm  = ctx.attr.target_vm,
        ocamlrun   = ctx.file.ocamlrun,
        ocamlc     = ctx.file.ocamlc,
        # ocamlc     = ctx.file.ocamlc, #.files.to_list()[0],
        boot_ocamllex   = ctx.attr.boot_ocamllex.files.to_list()[0],
        ocamlyacc  = ctx.attr.ocamlyacc.files.to_list()[0],

        # cc_toolchain = the_cc_toolchain,
        #     cc_exe = _c_exe, ## to be passed via `-cc` (will be a sh script on mac)

        # cc_opts = _cc_opts,

        # std_exit = ctx.attr._std_exit.files.to_list()[0],
        # camlheader = ctx.attr._camlheader.files.to_list()[0],

        ),
    ]

bootstrap_toolchain_adapter = rule(
    _bootstrap_toolchain_adapter_impl,
    attrs = {
        "path": attr.string(),
        "linkmode": attr.string(
            doc = "Default link mode: 'static' or 'dynamic'"
        ),

        "target_vm": attr.bool(
            default = True
        ),

        "ocamlrun": attr.label(
            default    = "//runtime:ocamlrun",
            # default    = "//bzl/toolchain:ocamlrun",
            executable = True,
            allow_single_file = True,
            # cfg = ocamlrun_out_transition,
            cfg = "exec",
        ),
        "_allowlist_function_transition" : attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

        "ocamlc": attr.label(
            default    = "//boot:ocamlc",
            # default    = "//bzl/toolchain:ocamlc",
            executable = True,
            allow_single_file = True,
            # cfg = ocamlrun_out_transition,
            cfg = "exec",
        ),

        "boot_ocamllex": attr.label(
            default    = "//boot:ocamllex",
            executable = True,
            allow_single_file = True,
            cfg = "exec",
        ),

        "ocamlyacc": attr.label(
            default    = "//yacc:ocamlyacc",
            executable = True,
            allow_single_file = True,
            cfg = "exec",
        ),

        ## hidden attr required to make find_cpp_toolchain work:
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),

        # rebuilt bc compiler emits bytecode
        # "ocamlc": attr.label(
        #     default   = "//boot:ocamlc",
        #     executable = False,
        #     allow_single_file = True,
        #     # cfg = "exec",
        # ),

        ## native compiler, built by byte-compiler
        # "ocamlopt": attr.label(
        #     default   = "//:ocamlopt",
        #     executable = False,
        #     allow_single_file = True,
        #     # cfg = "exec",
        # ),

        # "stdlib": attr.label(
        #     default   = "//stdlib",
        #     executable = False,
        #     # allow_single_file = True,
        #     # cfg = "exec",
        # ),

    # needed to build executables: std_exit, camlheader
        # "_camlheader": attr.label(
        #     default    = "//stdlib:camlheader",
        #     executable = False,
        #     allow_single_file = True,
        # ),

        # "_bootstrap_stdlib": attr.label(
        #     default = Label("//stdlib"),
        #     executable = False,
        #     allow_single_file = True,
        #     cfg = "exec",
        # ),
        # "_bootstrap_std_exit": attr.label(
        #     default = Label("@//stdlib:Std_exit"),
        #     executable = False,
        #     allow_single_file = True,
        #     cfg = "exec",
        # ),

        ################
    },

    doc = "Defines a toolchain for bootstrapping the OCaml toolchain",
    provides = [platform_common.ToolchainInfo], # platform_common.TemplateVariableInfo],

    ## NB: config frags evidently expose CLI opts like `--cxxopt`;
    ## see https://docs.bazel.build/versions/main/skylark/lib/cpp.html
    # fragments = ["cpp", "apple", "platform"],
    # host_fragments = ["apple", "platform"],
    # toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    cfg = toolchain_in_transition,
)
