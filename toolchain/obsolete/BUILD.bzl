def _linker(ctx, cctc):
    # print(CCRED + "link experiment")
    static_libs   = []
    dynamic_libs  = []

    linker_inputs = []
    linking_ctx = cc_common.create_linking_context(
        linker_inputs = depset(linker_inputs, order = "topological"),
    )
    print("linking_context: %s" % linking_ctx)
    linker_inputs = linking_ctx.linker_inputs.to_list()
    for linput in linker_inputs:
        libs = linput.libraries
        if len(libs) > 0:
            for lib in libs:
                if lib.pic_static_library:
                    static_libs.append(lib.pic_static_library)
                    # action_inputs_list.append(lib.pic_static_library)
                    # args.add(lib.pic_static_library.path)
                if lib.static_library:
                    static_libs.append(lib.pic_static_library)
                    # action_inputs_list.append(lib.static_library)
                    # args.add(lib.static_library.path)
                if lib.dynamic_library:
                    dynamic_libs.append(lib.dynamic_library)
                    # action_inputs_list.append(lib.dynamic_library)
                    # args.add("-ccopt", "-L" + lib.dynamic_library.dirname)
                    # args.add("-cclib", lib.dynamic_library.path)

    print("static_libs: %s" % static_libs)
    print("dynamic_libs: %s" % dynamic_libs)

    # linking_outputs = cc_common.link(
    #     actions = ctx.actions,
    #     feature_configuration = feature_configuration,
    #     cc_toolchain = cctc,
    #     linking_contexts = [linking_context],
    #     # user_link_flags = user_link_flags,
    #     # additional_inputs = ctx.files.additional_linker_inputs,
    #     name = ctx.label.name,
    #     output_type = "dynamic_library",
    # )
    # print("linking_outputs: %s" % linking_outputs)

