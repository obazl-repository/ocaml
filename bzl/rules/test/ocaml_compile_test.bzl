load(":compile_test_impl.bzl", "compile_test_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")
load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")
load("//bzl/transitions:dev_transitions.bzl",
     "dev_tc_compiler_out_transition")
load("//bzl:functions.bzl", "get_workdir")

####
## Compiles a file for testing purposes.
## Implements the compilation part of `ocamltest`, which
## a. compiles a file with -dlambda, -dno-unique-ids etc.
## b. compares the resulting lambda log file with expected

##############################
def _ocaml_compile_test_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc_workdir(tc)

    # (target_executor, target_emitter,
    #  config_executor, config_emitter,
    #  workdir) = get_workdir(ctx, tc)
    # if target_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

    if tc.config_executor[BuildSettingInfo].value in ["boot", "baseline", "vm"]:
        ext = ".byte"
    else:
        ext = ".opt"

    exe_name = ctx.label.name + ext

    return compile_impl(ctx, tc, exe_name, workdir)

#######################
ocaml_compile_test = rule(
    implementation = _ocaml_compile_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        # executable_attrs(),
        src = attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            # providers = [[OcamlArchiveProvider],
            #              [OcamlLibraryMarker],
            #              [ModuleInfo],
            #              [CcInfo]],
            # cfg = exe_deps_out_transition,
        ),
        expected = attr.label(
            allow_single_file = True,
        ),

        # ocamltest uses these options for running both
        # ocamlc.byte and ocamlopt.byte
        # -nostdlib -nopervasives -dlambda -dno-unique-ids
        opts             = attr.string_list( ),
        _verbose = attr.label(default = "//config/ocaml/link:verbose"),
        warnings         = attr.string_list(
            doc          = "List of OCaml warning options. Will override configurable default options."
        ),

        _tool    = attr.label(
            allow_single_file = True,
            default = "//testsuite/tools:compile",
            executable = True,
            cfg = "exec"
            # cfg = reset_cc_config_transition ## only build once
        ),
        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain/dev:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _stdlib = attr.label(
            doc = "Stdlib",
            default = "//stdlib", # archive, not resolver
            allow_single_file = True, # won't work with boot_library
            # cfg = exe_deps_out_transition,
        ),

        _rule = attr.string( default = "ocaml_compile_test" ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    ),
    # cfg = reset_config_transition,
    # cfg = "exec",
    cfg = dev_tc_compiler_out_transition,
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
