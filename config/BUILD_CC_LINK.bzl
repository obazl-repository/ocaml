load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")

def link_config(ctx, tc, feature_config):

    # adict = apple_common.apple_host_system_env(xcode_config)

    config_map = {}

    c_link_variables = cc_common.create_link_variables(
        feature_configuration = feature_config,
        cc_toolchain = tc,
        # source_file = source_file.path,
        # output_file = output_file.path,
        # preprocessor_defines = depset(defines)
    )

    cmd_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_config,
        action_name = ACTION_NAMES.cpp_link_executable,
        variables = c_link_variables,
    )
    config_map["cpp_link_exe_cmd_line"] = cmd_line

    link_env = cc_common.get_environment_variables(
        feature_configuration = feature_config,
        action_name = ACTION_NAMES.cpp_link_executable,
        variables = c_link_variables,
    )
    print("link env: %s"% link_env)
    config_map |= link_env
    print("config_map: %s" % config_map)

    return config_map

    # cmd_line = cc_common.get_memory_inefficient_command_line(
    #     feature_configuration = feature_config,
    #     action_name = ACTION_NAMES.cpp_link_dynamic_library,
    #     variables = c_link_variables,
    # )
    # config_map["cpp_link_dso_cmd_line"] = cmd_line

    # cmd_line = cc_common.get_memory_inefficient_command_line(
    #     feature_configuration = feature_config,
    #     action_name = ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    #     variables = c_link_variables,
    # )
    # config_map["cpp_link_nodeps_dso_cmd_line"] = cmd_line

    # cmd_line = cc_common.get_memory_inefficient_command_line(
    #     feature_configuration = feature_config,
    #     action_name = ACTION_NAMES.cpp_link_static_library,
    #     variables = c_link_variables,
    # )
    # config_map["cpp_link_static_cmd_line"] = cmd_line

