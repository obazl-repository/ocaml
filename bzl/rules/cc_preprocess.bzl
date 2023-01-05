# from https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_compile/my_c_compile.bzl

# also https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_archive/my_c_archive.bzl

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")

DISABLED_FEATURES = [
    "module_maps",
]

#############################
def _cc_preprocess_impl(ctx):

    cc_toolchain = find_cpp_toolchain(ctx)

    # source_file = ctx.file.src
    # ext   = source_file.extension
    # ofile = source_file.basename
    # ofile = source_file.basename[:-(len(ext)+1)]
    # output_file = ctx.actions.declare_file(ofile + ".o")

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = DISABLED_FEATURES + ctx.disabled_features,
    )

    c_compiler_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.c_compile,
    )

    copts = []
    for opt in ctx.attr.copts:
        copts.append(ctx.expand_make_variables("copts",opt, {}))

    defines = []
    for defn in ctx.attr.defines:
        defines.append(ctx.expand_make_variables("defines", defn, {}))

    c_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        # user_compile_flags = ["-E"] + ctx.fragments.cpp.copts + ctx.fragments.cpp.conlyopts + copts,
        user_compile_flags = ["-E"],
        source_file = ctx.file.src.path,
        output_file = ctx.outputs.out.path,
        # preprocessor_defines = depset(defines)
    )

    command_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.c_compile,
        variables = c_compile_variables,
    )

    ## Required on mac, sets DEVELOPER_DIR, SDKROOT
    env = cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.c_compile,
        variables = c_compile_variables,
    )
    # print("CC ENV: %s" % env)

    cc_ccontexts =  []
    for dep in ctx.attr.deps:
        cc_ccontexts.append(dep[CcInfo].compilation_context)

    merged_contexts = cc_common.merge_compilation_contexts(
        compilation_contexts = cc_ccontexts)

    ctx.actions.run(
        executable = c_compiler_path,
        arguments = command_line,
        env = env,
        inputs = depset(
            [ctx.file.src],
            transitive = [cc_toolchain.all_files, merged_contexts.headers]
        ),
        outputs = [ctx.outputs.out],
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.out])),
    ]

#####################
cc_preprocess = rule(
    implementation = _cc_preprocess_impl,
    attrs = {
        "src": attr.label(mandatory = True, allow_single_file = True),
        "out": attr.output(mandatory = True),

        "copts": attr.string_list(),
        "defines": attr.string_list(),
        "deps": attr.label_list(),

        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),
    },
    toolchains = use_cpp_toolchain(),
    fragments = ["cpp"],
)
