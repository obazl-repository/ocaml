# from https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_compile/my_c_compile.bzl

# also https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_archive/my_c_archive.bzl

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")

DISABLED_FEATURES = [
    "module_maps",
]

def _config_cc_toolchain_impl(ctx):

    tc = find_cpp_toolchain(ctx)

    config_map = {}
    config_map["AR"] = ctx.var["AR"]
    config_map["ABI"] = ctx.var["ABI"]
    config_map["ABI_GLIBC_VERSION"] = ctx.var["ABI_GLIBC_VERSION"]
    config_map["GLIBC_VERSION"] = ctx.var["GLIBC_VERSION"]
    config_map["CC"] = ctx.var["CC"]
    config_map["C_COMPILER"] = ctx.var["C_COMPILER"]
    config_map["LD"] = ctx.var["LD"]
    config_map["NM"] = ctx.var["NM"]
    config_map["OBJCOPY"] = ctx.var["OBJCOPY"]
    config_map["STRIP"] = ctx.var["STRIP"]
    config_map["TARGET_CPU"] = ctx.var["TARGET_CPU"]

    # print("VERSION FILE: %s" % ctx.version_file)

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = tc,
        requested_features = ctx.features,
        unsupported_features = DISABLED_FEATURES + ctx.disabled_features,
    )

# AS_CASE([$host],
#   [*-pc-windows],
#     [CC=cl
#     ccomptype=msvc
#     S=asm
#     SO=dll
#     outputexe=-Fe
#     syslib='$(1).lib'],
#   [ccomptype=cc
#   S=s
#   SO=so
#   outputexe='-o '
#   syslib='-l$(1)'])

    config_map["all_files"] = [f.path for f in tc.all_files.to_list()]
    config_map["cpu"] = tc.cpu
    #TODO: parse tc.target_gnu_system_name to get arch, system
    # or use cpu ( == darwin_x86_64)
    if tc.cpu.endswith("x86_64"):
        config_map["arch"] = "amd64"
    if tc.cpu.startswith("darwin"):
        config_map["model"] = "default"
        config_map["system"] = "macosx"
    config_map["ccomptype"] = "msvc" if tc.compiler == "msvc" else "cc"
    config_map["compiler"] = tc.compiler
    if tc.compiler == "msvc":
        config_map["outputobj"] = "-Fo"
        config_map["warn_error_flag"] = "-WX"
        config_map["cc_warnings"] = ""
    else:
        config_map["outputobj"] = "-o"
        config_map["warn_error_flag"] = "-Werror"
        config_map["cc_warnings"] = "-Wall"
    config_map["compiler_executable"] = tc.compiler_executable
    config_map["preprocessor_executable"] = tc.preprocessor_executable
    config_map["ar_executable"] = tc.ar_executable
    config_map["gcov_executable"] = tc.gcov_executable
    config_map["ld_executable"] = tc.ld_executable
    config_map["nm_executable"] = tc.nm_executable
    config_map["objcopy_executable"] = tc.objcopy_executable
    config_map["objdump_executable"] = tc.objdump_executable
    config_map["strip_executable"] = tc.strip_executable

    config_map["libc"] = tc.libc
    config_map["sysroot"] = tc.sysroot
    config_map["target_gnu_system_name"] = tc.target_gnu_system_name
    config_map["built_in_include_directories"] = tc.built_in_include_directories
    config_map["dynamic_runtime_lib"] = tc.dynamic_runtime_lib(feature_configuration = feature_configuration).to_list()
    config_map["static_runtime_lib"] = tc.static_runtime_lib(feature_configuration = feature_configuration).to_list()
    config_map["for_dynamic_libs_needs_pic"] = tc.needs_pic_for_dynamic_libraries(feature_configuration = feature_configuration)


    c_compiler_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.c_compile
    )

    config_map["c_compiler_path"] = c_compiler_path

    # source_file = ctx.file._src
    # ofile = source_file.basename
    # ext   = source_file.extension
    # ofile = source_file.basename[:-(len(ext)+1)]
    # output_file = ctx.actions.declare_file(ofile + ".o")

    c_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = tc,
        # source_file = source_file.path,
        # output_file = output_file.path,
        # preprocessor_defines = depset(defines)
    )

    # print("c_compile_variables: %s" % c_compile_variables)
    # config_map["c_compile_variables"] = str(c_compile_variables)

    compile_cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.c_compile,
        variables = c_compile_variables,
    )
    # print("c_compile_cmd_line: %s" % cmd_line)
    config_map["c_compile_cmd_line"] = compile_cmd_line

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.cpp_link_executable,
        variables = c_compile_variables,
    )
    config_map["cpp_link_exe_cmd_line"] = cmd_line

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.cpp_link_dynamic_library,
        variables = c_compile_variables,
    )
    config_map["cpp_link_dso_cmd_line"] = cmd_line

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.cpp_link_nodeps_dynamic_library,
        variables = c_compile_variables,
    )
    config_map["cpp_link_nodeps_dso_cmd_line"] = cmd_line

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.cpp_link_static_library,
        variables = c_compile_variables,
    )
    config_map["cpp_link_static_cmd_line"] = cmd_line

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.cc_flags_make_variable,
        variables = c_compile_variables,
    )
    config_map["cc_flags_make_variable"] = cmd_line

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.assemble,
        variables = c_compile_variables,
    )

    config_map["assemble_cmd_line"] = cmd_line + [
        "-Wno-trigraphs"
    ] if tc.cpu.startswith("darwin") else []

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.preprocess_assemble,
        variables = c_compile_variables,
    )
    config_map["preprocess_assemble_cmd_line"] = cmd_line

    env = cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.c_compile,
        variables = c_compile_variables,
    )

    cc_ccontexts =  []
    for dep in ctx.attr.deps:
        cc_ccontexts.append(dep[CcInfo].compilation_context)

    merged_contexts = cc_common.merge_compilation_contexts(
        compilation_contexts = cc_ccontexts)

    config_map["copts"]    = ctx.fragments.cpp.copts
    copts = []
    for opt in ctx.attr.copts:
        copts.append(ctx.expand_make_variables("copts",opt, {}))
    config_map["user_copts"] = ctx.attr.copts

    defines = []
    for defn in ctx.attr.defines:
        defines.append(ctx.expand_make_variables("defines", defn, {}))
    config_map["user_defines"] = defines

    linkopts = []
    for lopt in ctx.attr.linkopts:
        linkopts.append(ctx.expand_make_variables("linkopts", lopt, {}))
    config_map["linkopts"] = ctx.fragments.cpp.linkopts
    config_map["user_linkopts"] = linkopts

    ## -fdebug-prefix-map: gcc, clang: yes
    if tc.compiler in ["clang", "gcc"]:
        config_map["cc_has_debug_prefix_map"] = True
    else:
        config_map["cc_has_debug_prefix_map"] = False

    # print("config_map: %s" % config_map)

    # ctx.actions.run(
    #     executable = c_compiler_path,
    #     arguments = compile_cmd_line,
    #     env = env,
    #     inputs = depset(
    #         [source_file],
    #         transitive = [tc.all_files, merged_contexts.headers]
    #     ),
    #     outputs = [output_file],
    # )

    config_map_json = json.encode_indent(config_map)
    ctx.actions.write(
        output = ctx.outputs.out,
        content = config_map_json
    )

    ########
    return [
        DefaultInfo(files = depset([ctx.outputs.out]))
    ]

####################
config_cc_toolchain = rule(
    implementation = _config_cc_toolchain_impl,
    attrs = {
        "out": attr.output(mandatory=True),
        "copts": attr.string_list(),
        "defines": attr.string_list(),
        "linkopts": attr.string_list(),
        "deps": attr.label_list(),

        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),
    },
    toolchains = use_cpp_toolchain(),
    fragments = ["cpp", "platform"],
)
