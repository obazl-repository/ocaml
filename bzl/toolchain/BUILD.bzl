load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "C_COMPILE_ACTION_NAME")


# load("//bzl:providers.bzl",
#      "CompilationModeSettingProvider",
#      "OcamlSDK")

## obtaining CC toolchain:  https://github.com/bazelbuild/bazel/issues/7260

# ###################################################################
# def ocaml_register_toolchains(installation = None, noocaml = None):
#     # print("ocaml_register_toolchains");
#     native.register_toolchains("@ocaml//toolchain:ocaml_macos")
#     native.register_toolchains("@ocaml//toolchain:ocaml_linux")

def bootstrap_register_toolchains(installation = None, noocaml = None):
    # print("ocaml_register_toolchains");
    native.register_toolchains("//bzl/toolchain:bootstrap_macos")
    # native.register_toolchains("@ocaml//toolchain:bootstrap_linux")

################################################################
_bootstrap_tools_attrs = {
    "path": attr.string(),
    # "sdk_home": attr.string(),
    # "opam_root": attr.string(),
    "linkmode": attr.string(
        doc = "Default link mode: 'static' or 'dynamic'"
        # default = "static"
    ),

    ## hidden attr required to make find_cpp_toolchain work:
    "_cc_toolchain": attr.label(
        default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
    ),
    # "_cc_opts": attr.string_list(
    #     default = ["-Wl,-no_compact_unwind"]
    # ),

    "ocamlrun": attr.label(
        default    = "//runtime:ocamlrun",
        executable = True,
        allow_single_file = True,
        cfg = "exec",
    ),

    "ocamlc": attr.label(
        default   = "//boot:ocamlc",
        executable = False,
        allow_single_file = True,
        # cfg = "exec",
    ),

    "ocamllex": attr.label(
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

    # needed to build executables: std_exit, camlheader

    "_camlheader": attr.label(
        default    = "//stdlib:camlheader",
        executable = False,
        allow_single_file = True,
    ),

    ## but std_exit won't work here, induces circular dep
    # "_std_exit": attr.label(
    #     default    = "//stdlib:Std_exit",
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
    # "_ocamlc_opt": attr.label(
    #     default = Label("@ocaml//bin:ocamlc.opt"),
    #     executable = True,
    #     allow_single_file = True,
    #     cfg = "exec",
    # ),
    # "_ocamlopt": attr.label(
    #     default = Label("@ocaml//bin:ocamlopt"),
    #     executable = True,
    #     allow_single_file = True,
    #     cfg = "exec",
    # ),
    # "_ocamlopt_opt": attr.label(
    #     default = Label("@ocaml//bin:ocamlopt.opt"),
    #     executable = True,
    #     allow_single_file = True,
    #     cfg = "exec",
    # ),
    # "_copts": attr.string_list(
    #     default = [
    #         # "-g", # Record debugging information for exception backtrace
    #         # "-strict-formats", # Reject invalid formats accepted by legacy implementationsg
    #         # "-short-paths", # use shortest path printing type names in inferred interfaces, error, warning msgs
    #         # "-strict-sequence", # Left-hand part of a sequence must have type unit
    #         # "-keep-locs",  #  Keep locations in .cmi files (default)
    #         # "-no-alias-deps",  #  Do not record dependencies for module aliases
    #         # "-opaque" # Does not generate cross-module optimization information (reduces necessary recompilation on module change)
    # ]
    # ),
    # # "_ocamlfind": attr.label(
    # #     default = Label("@ocaml//:bin/ocamlfind"),
    # #     executable = True,
    # #     allow_single_file = True,
    # #     cfg = "exec",
    # # ),
    # # "_ocamlbuild": attr.label(
    # #     default = Label("@ocaml//:ocamlbuild"),
    # #     executable = True,
    # #     allow_single_file = True,
    # #     cfg = "exec",
    # # ),
    # # "_ocamldep": attr.label(
    # #     default = Label("@ocaml//:bin/ocamldep"),
    # #     executable = True,
    # #     allow_single_file = True,
    # #     cfg = "exec",
    # # ),
    # "_dllpath": attr.label(
    #     ## FIXME default = Label("@opam//pkg:stublibs"),
    # )
    # # "_opam": attr.label(
    # #   default = Label("@opam//:opam"),
    # #   executable = True,
    # #   allow_single_file = True,
    # #   # allow_files = True,
    # #       cfg = "exec",
    # # ),

    # # "_coqc": attr.label(
    # #     default = Label("//tools:coqc"),
    # #     executable = True,
    # #     allow_single_file = True,
    # #     cfg = "exec",
    # # ),
}

def _bootstrap_toolchain_impl(ctx):
    # print("\n\t_ocaml_toolchain_impl")

    # print("platform frag: %s" % ctx.host_fragments.platform)
    # ds = dir(ctx.host_fragments.platform)
    # for d in ds:
    #     print("\n\t{d}: {dval}".format(
    #         d = d, dval = getattr(ctx.host_fragments.platform, d)))
    # _platform = ctx.host_fragments.platform.platform

    if ctx.host_fragments.apple:
        _cc_opts = ["-Wl,-no_compact_unwind"]
    else:
        _cc_opts = []

    # print("apple frag: %s" % ctx.host_fragments.apple)
    # ds = dir(ctx.host_fragments.apple)
    # for d in ds:
    #     print("\n\t{d}: {dval}".format(
    #         d = d, dval = getattr(ctx.host_fragments.apple, d)))

    # print("cpp frag: %s" % ctx.fragments.cpp)
    # ds = dir(ctx.fragments.cpp)
    # for d in ds:
    #     print("\n\t{d}: {dval}".format(
    #         d = d,
    #         dval = getattr(ctx.fragments.cpp, d) if d != "custom_malloc" else ""))

    the_cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = the_cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    _c_exe = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = C_COMPILE_ACTION_NAME,
    )
    # print("c_exe: %s" % _c_exe)
    if not ctx.attr.linkmode in ["static", "dynamic"]:
        fail("Bad value '{actual}' for attrib 'link'. Allowed values: 'static', 'dynamic' (in rule: ocaml_toolchain(name=\"{n}\"), build file: \"{bf}\", workspace: \"{ws}\"".format(
            ws = ctx.workspace_name,
            bf = ctx.build_file_path,
            n = ctx.label.name,
            actual = ctx.attr.linkmode
        )
             )
    # if not ctx.attr.mode in ["native", "bytecode"]:
    #     fail("Bad value '{actual}' for attrib 'mode'. Allowed values: 'native', 'bytecode' (in rule: ocaml_toolchain(name=\"{n}\"), build file: \"{bf}\", workspace: \"{ws}\"".format(
    #         ws = ctx.workspace_name,
    #         bf = ctx.build_file_path,
    #         n = ctx.label.name,
    #         actual = ctx.attr.mode
    #     )
    #          )
    # mode = ctx.attr.mode[CompilationModeSettingProvider].value

    return [platform_common.ToolchainInfo(
        # Public fields
        name = ctx.label.name,
        # platform   = _platform,
        path       = ctx.attr.path,
        # sdk_home   = ctx.attr.sdk_home,
        # opam_root  = ctx.attr.opam_root,
        linkmode       = ctx.attr.linkmode,

        ocamlrun   = ctx.attr.ocamlrun.files.to_list()[0],
        ocamlc     = ctx.file.ocamlc, #.files.to_list()[0],
        # ocamlc_opt = ctx.attr._ocamlc_opt.files.to_list()[0],
        # ocamlopt   = ctx.attr._ocamlopt.files.to_list()[0],
        # ocamlopt_opt = ctx.attr._ocamlopt_opt.files.to_list()[0],

        ocamllex   = ctx.attr.ocamllex.files.to_list()[0],
        ocamlyacc  = ctx.attr.ocamlyacc.files.to_list()[0],

        # bootstrap_std_exit = ctx.attr._bootstrap_std_exit,

        # cc_toolchain = ctx.attr.cc_toolchain,
        ## rules add [cc_toolchain.all_files] to action inputs
        ## at least, rules linking to cc libs must do this;
        ## pure ocaml code need not?
        cc_toolchain = the_cc_toolchain,
        cc_exe = _c_exe, ## to be passed via `-cc` (will be a sh script on mac)

        cc_opts = _cc_opts,

        ## config frag.cpp fld `linkopts` contains whatever was passed
        ## by CLI using `--linkopt`
        linkopts  = None,

        # std_exit = ctx.attr._std_exit.files.to_list()[0],
        camlheader = ctx.attr._camlheader.files.to_list()[0],

        # ocamlbuild = ctx.attr._ocamlbuild.files.to_list()[0],
        # ocamlfind  = ctx.attr._ocamlfind.files.to_list()[0],
        # ocamldep   = ctx.attr._ocamldep.files.to_list()[0],
        # objext     = ".cmx" if mode == "native" else ".cmo",
        # archext    = ".cmxa" if mode == "native" else ".cma",
        # dllpath    = ctx.path(Label("@opam//pkg:stublibs"))
    )]

bootstrap_toolchain_impl = rule(
    _bootstrap_toolchain_impl,
    attrs = _bootstrap_tools_attrs,
    doc = "Defines a Ocaml toolchain based on an SDK",
    provides = [platform_common.ToolchainInfo],

    ## NB: config frags evidently expose CLI opts like `--cxxopt`;
    ## see https://docs.bazel.build/versions/main/skylark/lib/cpp.html
    fragments = ["cpp", "apple", "platform"],
    host_fragments = ["apple", "platform"],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"]
)
