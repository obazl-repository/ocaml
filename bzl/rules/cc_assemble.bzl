# from https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_compile/my_c_compile.bzl

# also https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_archive/my_c_archive.bzl

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "PREPROCESS_ASSEMBLE_ACTION_NAME")

ACTION = PREPROCESS_ASSEMBLE_ACTION_NAME

DISABLED_FEATURES = [
    "module_maps",
]

def _cc_assemble_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    source_file = ctx.file.src
    ofile = source_file.basename
    ext   = source_file.extension
    ofile = source_file.basename[:-(len(ext)+1)]
    output_file = ctx.actions.declare_file(ofile + ".o")
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = DISABLED_FEATURES + ctx.disabled_features,
    )
    c_compiler_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = ACTION,
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
        user_compile_flags = ctx.fragments.cpp.copts + ctx.fragments.cpp.conlyopts + copts,
        source_file = source_file.path,
        output_file = output_file.path,
        preprocessor_defines = depset(defines)
    )

    # c_link_variables = cc_common.create_link_variables(
    #     feature_configuration = feature_configuration,
    #     cc_toolchain = cc_toolchain,
    #     library_search_directories=None,
    #     runtime_library_search_directories=None,
    #     user_link_flags=None,
    #     output_file=None,
    #     param_file=None,
    #     def_file=None,
    #     is_using_linker=True,
    #     is_linking_dynamic_library=False,
    #     must_keep_debug=True,
    #     use_test_only_flags=False,
    #     is_static_linking_mode=True
    # )

    command_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION,
        variables = c_compile_variables,
    )
    env = cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = ACTION,
        variables = c_compile_variables,
    )

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
            [source_file],
            transitive = [cc_toolchain.all_files, merged_contexts.headers]
        ),
        outputs = [output_file],
    )

    ################################################################
    compilation_ctx = cc_common.create_compilation_context(
        # headers=unbound,
        # system_includes=unbound,
        # includes=unbound,
        # quote_includes=unbound,
        # framework_includes=unbound,
        # defines=unbound,
        # local_defines=unbound
    )

    compilation_outputs = cc_common.create_compilation_outputs(
        objects=depset([output_file]),
        pic_objects=None)

    (linking_ctx, linking_outputs) = cc_common.create_linking_context_from_compilation_outputs(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = compilation_outputs,
        user_link_flags=[],
        linking_contexts=[],
        name = "cc_assemble_outputs",
        language='c++',
        alwayslink=False,
        additional_inputs=[],
        disallow_static_libraries=False,
        disallow_dynamic_library=False,
        grep_includes=None)

    ccinfo = cc_common.merge_cc_infos(
        cc_infos = [
            CcInfo(compilation_context = compilation_ctx,
                   linking_context = linking_ctx)
        ] +[dep[CcInfo] for dep in ctx.attr.deps])

    return [
        DefaultInfo(files = depset([output_file])),
        ccinfo
    ]

cc_assemble = rule(
    implementation = _cc_assemble_impl,
    attrs = {
        "src": attr.label(mandatory = True, allow_single_file = True),
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
