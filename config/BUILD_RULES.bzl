load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

load(":BUILD_CC_LINK.bzl", "link_config")

## exports rules: config_cc_toolchain, config_mkexe

DISABLED_FEATURES = [
    "module_maps",
]

OCamlCcToolchainInfo = provider()

################################################################
def cc_tc_config_map(ctx):
    config_map = {}

    config_map["target_host_platform"] = str(ctx.fragments.platform.host_platform)
    config_map["target_platform"] = str(ctx.fragments.platform.platform)

    config_map["host_host_platform"] = str(ctx.host_fragments.platform.host_platform)
    config_map["host_platform"] = str(ctx.host_fragments.platform.platform)

    tc = find_cpp_toolchain(ctx)
    # tc is a CcToolchainInfo

    # print("VAR: %s" % ctx.var)
    for k,v in ctx.var.items():
        # print("VAR: {k} : {v}".format(k=k, v=v))
        config_map[k] = v

    # config_map["AR"] = ctx.var["AR"]
    # config_map["ABI"] = ctx.var["ABI"]
    # config_map["ABI_GLIBC_VERSION"] = ctx.var["ABI_GLIBC_VERSION"]
    # config_map["GLIBC_VERSION"] = ctx.var["GLIBC_VERSION"]
    # config_map["CC"] = ctx.var["CC"]
    # config_map["C_COMPILER"] = ctx.var["C_COMPILER"]
    # config_map["LD"] = ctx.var["LD"]
    # config_map["NM"] = ctx.var["NM"]
    # if ctx.var.get("OBJCOPY"):
    #     config_map["OBJCOPY"] = ctx.var["OBJCOPY"]
    # else:
    #     config_map["OBJCOPY"] = None
    # config_map["STRIP"] = ctx.var["STRIP"]
    # config_map["TARGET_CPU"] = ctx.var["TARGET_CPU"]

    # print("VERSION FILE: %s" % ctx.version_file)

    feature_config = cc_common.configure_features(
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
    elif  tc.cpu == "k8":
        config_map["arch"] = "amd64"
    else:
        config_map["arch"] = "unknown"
    if tc.cpu.startswith("darwin"):
        config_map["model"] = "default"
        config_map["system"] = "macosx"
    else:
        config_map["model"] = "default"
        config_map["system"] = "linux" ## FIXME
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
    config_map["dynamic_runtime_lib"] = tc.dynamic_runtime_lib(feature_configuration = feature_config).to_list()
    config_map["static_runtime_lib"] = tc.static_runtime_lib(feature_configuration = feature_config).to_list()
    config_map["for_dynamic_libs_needs_pic"] = tc.needs_pic_for_dynamic_libraries(feature_configuration = feature_config)


    c_compiler_path = cc_common.get_tool_for_action(
        feature_configuration = feature_config,
        action_name = ACTION_NAMES.c_compile
    )

    root = ctx.var["BINDIR"]
    config_map["c_compiler_path"] = c_compiler_path

    # source_file = ctx.file._src
    # ofile = source_file.basename
    # ext   = source_file.extension
    # ofile = source_file.basename[:-(len(ext)+1)]
    # output_file = ctx.actions.declare_file(ofile + ".o")

    c_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_config,
        cc_toolchain = tc,
        # source_file = source_file.path,
        # output_file = output_file.path,
        # preprocessor_defines = depset(defines)
    )

    # print("c_compile_variables: %s" % c_compile_variables)
    # config_map["c_compile_variables"] = str(c_compile_variables)

    link_map = link_config(ctx, tc, feature_config)
    # print("LINK MAP: %s" % link_map)
    config_map |= link_map

    compile_cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_config,
        action_name = ACTION_NAMES.c_compile,
        variables = c_compile_variables,
    )
    # print("c_compile_cmd_line: %s" % cmd_line)
    config_map["c_compile_cmd_line"] = compile_cmd_line

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_config,
        action_name = ACTION_NAMES.cc_flags_make_variable,
        variables = c_compile_variables,
    )
    config_map["cc_flags_make_variable"] = cmd_line

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_config,
        action_name = ACTION_NAMES.assemble,
        variables = c_compile_variables,
    )

    config_map["assemble_cmd_line"] = cmd_line + [
        "-Wno-trigraphs"
    ] if tc.cpu.startswith("darwin") else []

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_config,
        action_name = ACTION_NAMES.preprocess_assemble,
        variables = c_compile_variables,
    )
    config_map["preprocess_assemble_cmd_line"] = cmd_line

    compile_env = cc_common.get_environment_variables(
        feature_configuration = feature_config,
        action_name = ACTION_NAMES.c_compile,
        variables = c_compile_variables,
    )
    # print("ENV: %s"% compile_env)
    config_map |= compile_env
    # print("config_map: %s" % config_map)

    # cc_ccontexts =  []
    # for dep in ctx.attr.deps:
    #     cc_ccontexts.append(dep[CcInfo].compilation_context)

    # merged_contexts = cc_common.merge_compilation_contexts(
    #     compilation_contexts = cc_ccontexts)

    config_map["copts"]    = ctx.fragments.cpp.copts
    copts = []
    # for opt in ctx.attr.copts:
    #     copts.append(ctx.expand_make_variables("copts",opt, {}))
    # config_map["user_copts"] = ctx.attr.copts

    defines = []
    # for defn in ctx.attr.defines:
    #     defines.append(ctx.expand_make_variables("defines", defn, {}))
    # config_map["user_defines"] = defines

    # linkopts = []
    # for lopt in ctx.attr.linkopts:
    #     linkopts.append(ctx.expand_make_variables("linkopts", lopt, {}))
    # config_map["user_linkopts"] = linkopts
    config_map["linkopts"] = ctx.fragments.cpp.linkopts

    ## -fdebug-prefix-map: gcc, clang: yes
    if tc.compiler in ["clang", "gcc"]:
        config_map["cc_has_debug_prefix_map"] = True
    else:
        config_map["cc_has_debug_prefix_map"] = False

    return config_map

###################################
def _config_cc_toolchain_impl(ctx):

    config_map = cc_tc_config_map(ctx)
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

    ocamlCcToolchainInfo = OCamlCcToolchainInfo(
        ABI = config_map["ABI"],
        ABI_GLIBC_VERSION = config_map["ABI_GLIBC_VERSION"],
        AR = config_map["AR"],
        CC = config_map["CC"],
        C_COMPILER = config_map["C_COMPILER"],
        GLIBC_VERSION = config_map["GLIBC_VERSION"],
        LD = config_map["LD"],
        NM = config_map["NM"],
        OBJCOPY = config_map["OBJCOPY"],
        STRIP = config_map["STRIP"],
        TARGET_CPU = config_map["TARGET_CPU"],
        all_files = config_map["all_files"],
        ar_executable = config_map["ar_executable"],
        arch = config_map["arch"],
        assemble_cmd_line = config_map["assemble_cmd_line"],
        built_in_include_directories = config_map["built_in_include_directories"],
        c_compile_cmd_line = config_map["c_compile_cmd_line"],
        c_compiler_path = config_map["c_compiler_path"],
        cc_flags_make_variable = config_map["cc_flags_make_variable"],
        cc_has_debug_prefix_map = config_map["cc_has_debug_prefix_map"],
        cc_warnings = config_map["cc_warnings"],
        ccomptype = config_map["ccomptype"],
        compiler = config_map["compiler"],
        compiler_executable = config_map["compiler_executable"],
        copts = config_map["copts"],

        # cpp_link_dso_cmd_line = config_map["cpp_link_dso_cmd_line"],
        cpp_link_exe_cmd_line = config_map["cpp_link_exe_cmd_line"],
        # cpp_link_nodeps_dso_cmd_line = config_map["cpp_link_nodeps_dso_cmd_line"],
        # cpp_link_static_cmd_line = config_map["cpp_link_static_cmd_line"],


        cpu = config_map["cpu"],
        dynamic_runtime_lib = config_map["dynamic_runtime_lib"],
        for_dynamic_libs_needs_pic = config_map["for_dynamic_libs_needs_pic"],
        gcov_executable = config_map["gcov_executable"],
        host_host_platform = config_map["host_host_platform"],
        host_platform = config_map["host_platform"],
        ld_executable = config_map["ld_executable"],
        libc = config_map["libc"],
        linkopts = config_map["linkopts"],
        model = config_map["model"],
        nm_executable = config_map["nm_executable"],
        objcopy_executable = config_map["objcopy_executable"],
        objdump_executable = config_map["objdump_executable"],
        outputobj = config_map["outputobj"],
        preprocess_assemble_cmd_line = config_map["preprocess_assemble_cmd_line"],
        preprocessor_executable = config_map["preprocessor_executable"],
        static_runtime_lib = config_map["static_runtime_lib"],
        strip_executable = config_map["strip_executable"],
        sysroot = config_map["sysroot"],
        system = config_map["system"],
        target_gnu_system_name = config_map["target_gnu_system_name"],
        target_host_platform = config_map["target_host_platform"],
        target_platform = config_map["target_platform"],
        # user_copts = config_map["user_copts"],
        # user_defines = config_map["user_defines"],
        # user_linkopts = config_map["user_linkopts"],
        warn_error_flag = config_map["warn_error_flag"],
    )

    ########
    return [
        DefaultInfo(files = depset([ctx.outputs.out])),
        ocamlCcToolchainInfo
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
    fragments = ["apple", "cpp", "platform"],
)

################################################################
def _config_mkexe_impl(ctx):

    linker    = ctx.attr.tc[OCamlCcToolchainInfo].c_compiler_path
    arglist = ctx.attr.tc[OCamlCcToolchainInfo].cpp_link_exe_cmd_line + ctx.attr.linkopts
    linkargs = " ".join(arglist)

    ctx.actions.expand_template(
        template = ctx.file.template,
        output   = ctx.outputs.out,
        substitutions = {
            "BAZEL_LINK_CMD": linker + " " + linkargs
        }
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.out])),
    ]

####################
config_mkexe = rule(
    implementation = _config_mkexe_impl,
    attrs = {
        "out": attr.output(mandatory = True),
        "template": attr.label(
            allow_single_file = True,
            mandatory  = True
        ),
        "tc" : attr.label(
            allow_single_file = True,
            mandatory = True
        ),
        "linkopts": attr.string_list(
        )
    },
)

################################################################
def _ocaml_cc_config_impl(ctx):

    cc_config_map = cc_tc_config_map(ctx)
    # print("cc_config_map: %s" % cc_config_map)

    user_json = ctx.actions.declare_file("user_config.json")

    json_map = {}

    json_map["c_compiler"] = cc_config_map["C_COMPILER"]
    json_map["ocamlc_cflags"] = " " + " ".join(cc_config_map["c_compile_cmd_line"])

    # json_map["ar"] = cc_config_map["AR"]

    assembler  = cc_config_map["c_compiler_path"]
    # assembler  = cc_config_map["C_COMPILER"]
    arglist = cc_config_map["assemble_cmd_line"]
    # arglist = cc_config_map["preprocess_assemble_cmd_line"]
    arglist.extend(ctx.attr.asmopts)
    if ctx.attr._asm_verbose[BuildSettingInfo].value: ## //config/ocaml/cc/asm:verbose
        arglist.append("-v")
    asmargs = " ".join(arglist)

    ## this is ugly but required if we want to use the xcode tc on
    ## mac. NB we could set these env vars in the build rules, but
    ## then builds would fail when run outside of Bazel, unless the
    ## user sets them in the shell.

    ## ocaml uses system(3) to run assemble/link actions
    ## so do we need to use 'exec env -' ???
    ## envsetup = "exec env - "
    # envsetup = ""
    ## what about a fresh env? safer?
    envsetup = "exec env -i - "
    if ctx.attr._xcode_developer_dir[BuildSettingInfo].value:
        envsetup = envsetup + "DEVELOPER_DIR={}".format(
            ctx.attr._xcode_developer_dir[BuildSettingInfo].value)
    if ctx.attr._xcode_sdkroot[BuildSettingInfo].value:
        envsetup = envsetup + " SDKROOT={} ".format(
            ctx.attr._xcode_sdkroot[BuildSettingInfo].value)

    json_map["asm"] = envsetup + assembler + " -c " + asmargs

    linker  = cc_config_map["c_compiler_path"]
    arglist = []
    arglist.extend(cc_config_map["cpp_link_exe_cmd_line"])
    arglist.extend(ctx.attr.linkopts)
    if ctx.attr._link_verbose[BuildSettingInfo].value: ## //config/ocaml/cc/link:verbose
        arglist.append("-v")
    linkargs = " ".join(arglist)
    # maczig:
    # linkargs = " rc"

    json_map["mkexe_cmd"] = envsetup + linker + " " + linkargs

    if ctx.attr._flambda[BuildSettingInfo].value:
        json_map["flambda"] =  True
    if ctx.attr._with_flambda_invariants[BuildSettingInfo].value:
        json_map["with_flambda_invariants"] =  True
    if ctx.attr._with_cmm_invariants[BuildSettingInfo].value:
        json_map["with_cmm_invariants"] =  True

    ctx.actions.write(
        output  = user_json,
        content = json.encode(json_map)
    )

    ################################################################
    args = ctx.actions.args()
    args.add_all(["-a", ctx.file.json.path])
    args.add_all(["-b", user_json.path])
    args.add_all(["-o", ctx.outputs.out])

    clang_tc = ctx.attr._clang

    ctx.actions.run(
        executable = ctx.file._tool.path,
        arguments = [args],
        inputs    = [ctx.file.json, user_json] + clang_tc.files.to_list(),
        outputs   = [ctx.outputs.out],
        tools = [ctx.file._tool],
        mnemonic = "OCamlConfig",
        progress_message = "Generating config.json"
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.out])),
    ]

####################
ocaml_cc_config = rule(
    implementation = _ocaml_cc_config_impl,
    attrs = {
        "out": attr.output(mandatory = True),
        "json": attr.label(
            allow_single_file = True,
            mandatory  = True
        ),
        "asmopts"  : attr.string_list(),
        "_asm_verbose": attr.label(
            default = "//config/ocaml/cc/asm:verbose"
        ),
        "copts"    : attr.string_list(),
        "_compile_verbose": attr.label(
            default = "//config/ocaml/cc/compile:verbose"
        ),
        "linkopts" : attr.string_list(),
        "_link_verbose": attr.label(
            default = "//config/ocaml/cc/link:verbose"
        ),
        "_tool" : attr.label(
            allow_single_file = True,
            default = "//vendor/merge_json",
            executable = True,
            cfg = reset_cc_config_transition
            # cfg = "exec"
        ),
        "_flambda": attr.label(
            default = "//config/ocaml:flambda"
        ),
        "_with_flambda_invariants": attr.label(
            default = "//config/ocaml:with_flambda_invariants"
        ),
        "_with_cmm_invariants": attr.label(
            default = "//config/ocaml:with_cmm_invariants"
        ),

        "_clang": attr.label(
            default = "@local_config_cc//:wrapped_clang",
            allow_single_file = True,
            executable = True,
            cfg = "exec"
        ),

        "_xcode_sdkroot": attr.label(
            default = "@ocaml_xcode//env:sdkroot"
        ),
        "_xcode_developer_dir": attr.label(
            default = "@ocaml_xcode//env:developer_dir"
        ),

        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    # toolchains = use_cpp_toolchain(),
    fragments = ["apple", "cpp", "platform"],
)

# ################################################################
# def _config_cc_toolchain_impl(ctx):

#     tc = find_cpp_toolchain(ctx)

#     config_map = {}
#     config_map["AR"] = ctx.var["AR"]
#     config_map["ABI"] = ctx.var["ABI"]
#     config_map["ABI_GLIBC_VERSION"] = ctx.var["ABI_GLIBC_VERSION"]
#     config_map["GLIBC_VERSION"] = ctx.var["GLIBC_VERSION"]
#     config_map["CC"] = ctx.var["CC"]
#     config_map["C_COMPILER"] = ctx.var["C_COMPILER"]
#     config_map["LD"] = ctx.var["LD"]
#     config_map["NM"] = ctx.var["NM"]
#     config_map["OBJCOPY"] = ctx.var["OBJCOPY"]
#     config_map["STRIP"] = ctx.var["STRIP"]
#     config_map["TARGET_CPU"] = ctx.var["TARGET_CPU"]

#     # print("VERSION FILE: %s" % ctx.version_file)

#     feature_configuration = cc_common.configure_features(
#         ctx = ctx,
#         cc_toolchain = tc,
#         requested_features = ctx.features,
#         unsupported_features = DISABLED_FEATURES + ctx.disabled_features,
#     )

# # AS_CASE([$host],
# #   [*-pc-windows],
# #     [CC=cl
# #     ccomptype=msvc
# #     S=asm
# #     SO=dll
# #     outputexe=-Fe
# #     syslib='$(1).lib'],
# #   [ccomptype=cc
# #   S=s
# #   SO=so
# #   outputexe='-o '
# #   syslib='-l$(1)'])

#     config_map["all_files"] = [f.path for f in tc.all_files.to_list()]
#     config_map["cpu"] = tc.cpu
#     #TODO: parse tc.target_gnu_system_name to get arch, system
#     # or use cpu ( == darwin_x86_64)
#     if tc.cpu.endswith("x86_64"):
#         config_map["arch"] = "amd64"
#     if tc.cpu.startswith("darwin"):
#         config_map["model"] = "default"
#         config_map["system"] = "macosx"
#     config_map["ccomptype"] = "msvc" if tc.compiler == "msvc" else "cc"
#     config_map["compiler"] = tc.compiler
#     if tc.compiler == "msvc":
#         config_map["outputobj"] = "-Fo"
#         config_map["warn_error_flag"] = "-WX"
#         config_map["cc_warnings"] = ""
#     else:
#         config_map["outputobj"] = "-o"
#         config_map["warn_error_flag"] = "-Werror"
#         config_map["cc_warnings"] = "-Wall"
#     config_map["compiler_executable"] = tc.compiler_executable
#     config_map["preprocessor_executable"] = tc.preprocessor_executable
#     config_map["ar_executable"] = tc.ar_executable
#     config_map["gcov_executable"] = tc.gcov_executable
#     config_map["ld_executable"] = tc.ld_executable
#     config_map["nm_executable"] = tc.nm_executable
#     config_map["objcopy_executable"] = tc.objcopy_executable
#     config_map["objdump_executable"] = tc.objdump_executable
#     config_map["strip_executable"] = tc.strip_executable

#     config_map["libc"] = tc.libc
#     config_map["sysroot"] = tc.sysroot
#     config_map["target_gnu_system_name"] = tc.target_gnu_system_name
#     config_map["built_in_include_directories"] = tc.built_in_include_directories
#     config_map["dynamic_runtime_lib"] = tc.dynamic_runtime_lib(feature_configuration = feature_config).to_list()
#     config_map["static_runtime_lib"] = tc.static_runtime_lib(feature_configuration = feature_config).to_list()
#     config_map["for_dynamic_libs_needs_pic"] = tc.needs_pic_for_dynamic_libraries(feature_configuration = feature_config)


#     c_compiler_path = cc_common.get_tool_for_action(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.c_compile
#     )

#     config_map["c_compiler_path"] = c_compiler_path

#     # source_file = ctx.file._src
#     # ofile = source_file.basename
#     # ext   = source_file.extension
#     # ofile = source_file.basename[:-(len(ext)+1)]
#     # output_file = ctx.actions.declare_file(ofile + ".o")

#     c_compile_variables = cc_common.create_compile_variables(
#         feature_configuration = feature_config,
#         cc_toolchain = tc,
#         # source_file = source_file.path,
#         # output_file = output_file.path,
#         # preprocessor_defines = depset(defines)
#     )

#     # print("c_compile_variables: %s" % c_compile_variables)
#     # config_map["c_compile_variables"] = str(c_compile_variables)

#     compile_cmd_line = cc_common.get_memory_inefficient_command_line(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.c_compile,
#         variables = c_compile_variables,
#     )
#     # print("c_compile_cmd_line: %s" % cmd_line)
#     config_map["c_compile_cmd_line"] = compile_cmd_line

#     cmd_line = cc_common.get_memory_inefficient_command_line(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.cpp_link_executable,
#         variables = c_compile_variables,
#     )
#     config_map["cpp_link_exe_cmd_line"] = cmd_line

#     cmd_line = cc_common.get_memory_inefficient_command_line(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.cpp_link_dynamic_library,
#         variables = c_compile_variables,
#     )
#     config_map["cpp_link_dso_cmd_line"] = cmd_line

#     cmd_line = cc_common.get_memory_inefficient_command_line(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.cpp_link_nodeps_dynamic_library,
#         variables = c_compile_variables,
#     )
#     config_map["cpp_link_nodeps_dso_cmd_line"] = cmd_line

#     cmd_line = cc_common.get_memory_inefficient_command_line(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.cpp_link_static_library,
#         variables = c_compile_variables,
#     )
#     config_map["cpp_link_static_cmd_line"] = cmd_line

#     cmd_line = cc_common.get_memory_inefficient_command_line(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.cc_flags_make_variable,
#         variables = c_compile_variables,
#     )
#     config_map["cc_flags_make_variable"] = cmd_line

#     cmd_line = cc_common.get_memory_inefficient_command_line(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.assemble,
#         variables = c_compile_variables,
#     )

#     config_map["assemble_cmd_line"] = cmd_line + [
#         "-Wno-trigraphs"
#     ] if tc.cpu.startswith("darwin") else []

#     cmd_line = cc_common.get_memory_inefficient_command_line(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.preprocess_assemble,
#         variables = c_compile_variables,
#     )
#     config_map["preprocess_assemble_cmd_line"] = cmd_line

#     env = cc_common.get_environment_variables(
#         feature_configuration = feature_config,
#         action_name = ACTION_NAMES.c_compile,
#         variables = c_compile_variables,
#     )

#     cc_ccontexts =  []
#     for dep in ctx.attr.deps:
#         cc_ccontexts.append(dep[CcInfo].compilation_context)

#     merged_contexts = cc_common.merge_compilation_contexts(
#         compilation_contexts = cc_ccontexts)

#     config_map["copts"]    = ctx.fragments.cpp.copts
#     copts = []
#     for opt in ctx.attr.copts:
#         copts.append(ctx.expand_make_variables("copts",opt, {}))
#     config_map["user_copts"] = ctx.attr.copts

#     defines = []
#     for defn in ctx.attr.defines:
#         defines.append(ctx.expand_make_variables("defines", defn, {}))
#     config_map["user_defines"] = defines

#     linkopts = []
#     for lopt in ctx.attr.linkopts:
#         linkopts.append(ctx.expand_make_variables("linkopts", lopt, {}))
#     config_map["linkopts"] = ctx.fragments.cpp.linkopts
#     config_map["user_linkopts"] = linkopts

#     ## -fdebug-prefix-map: gcc, clang: yes
#     if tc.compiler in ["clang", "gcc"]:
#         config_map["cc_has_debug_prefix_map"] = True
#     else:
#         config_map["cc_has_debug_prefix_map"] = False

#     # print("config_map: %s" % config_map)

#     # ctx.actions.run(
#     #     executable = c_compiler_path,
#     #     arguments = compile_cmd_line,
#     #     env = env,
#     #     inputs = depset(
#     #         [source_file],
#     #         transitive = [tc.all_files, merged_contexts.headers]
#     #     ),
#     #     outputs = [output_file],
#     # )

#     config_map_json = json.encode_indent(config_map)
#     ctx.actions.write(
#         output = ctx.outputs.out,
#         content = config_map_json
#     )

#     ########
#     return [
#         DefaultInfo(files = depset([ctx.outputs.out]))
#     ]

# ####################
# config_cc_toolchain = rule(
#     implementation = _config_cc_toolchain_impl,
#     attrs = {
#         "out": attr.output(mandatory=True),
#         "copts": attr.string_list(),
#         "defines": attr.string_list(),
#         "linkopts": attr.string_list(),
#         "deps": attr.label_list(),

#         "_cc_toolchain": attr.label(
#             default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
#         ),
#     },
#     toolchains = use_cpp_toolchain(),
#     fragments = ["cpp", "platform"],
# )
