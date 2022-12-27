load(":inline_expect_impl.bzl", "inline_expect_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

##############################
def _inline_expect_test_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    # (target_executor, target_emitter,
    #  config_executor, config_emitter,
    #  workdir) = get_workdir(ctx, tc)
    # if target_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

    if tc.config_executor in ["boot", "baseline", "vm"]:
        ext = ".byte"
    else:
        ext = ".opt"

    exe_name = ctx.label.name + ext

    return inline_expect_impl(ctx, tc, exe_name, workdir)

#######################
inline_expect_test = rule(
    implementation = _inline_expect_test_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        # executable_attrs(),
        _tool    = attr.label(
            allow_single_file = True,
            default = "//testsuite/tools:inline_expect",
            executable = True,
            cfg = "exec"
            # cfg = reset_cc_config_transition ## only build once
        ),
        _runfiles_tool = attr.label(
            default = "@bazel_tools//tools/bash/runfiles"
        ),

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
        opts             = attr.string_list( ),
        _verbose = attr.label(default = "//config/ocaml/link:verbose"),
        warnings         = attr.string_list(
            doc          = "List of OCaml warning options. Will override configurable default options."
        ),

        _runtime = attr.label(
            allow_single_file = True,
            default = "//toolchain:runtime",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        _libs_archived = attr.label( # boolean
            default = "//config/ocaml/compiler/libs:archived"
        ),

        # _stdlib = attr.label(
        #     doc = "Stdlib",
        #     default = "//stdlib", # archive, not resolver
        #     # allow_single_file = True, # won't work with boot_library
        #     # cfg = exe_deps_out_transition,
        # ),

        _rule = attr.string( default = "inline_expect_test" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    test = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
