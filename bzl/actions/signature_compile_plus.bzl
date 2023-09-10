load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load(":BUILD.bzl", "progress_msg")
#, "get_build_executor", "configure_action")

load(":signature_compile_config.bzl", "construct_signature_compile_config")

load("//bzl:providers.bzl",
     "BootInfo", "dump_bootinfo",
     "ModuleInfo",
     "SigInfo",
     "StdlibSigMarker",
     "StdSigMarker",
     "new_deps_aggregator",
     "OcamlSignatureProvider")

load("//bzl:functions.bzl", "get_module_name")

load("//bzl/rules/common:options.bzl", "get_options")

load("//bzl/rules/common:impl_common.bzl", "dsorder")

load("//bzl/rules/common:DEPS.bzl", "aggregate_deps", "merge_depsets")

########################
def signature_compile_plus(ctx, module_name):

    debug = False
    debug_bootstrap = False

    if debug:
        print("signature_compile_plus: %s" % ctx.label)

    (inputs,
     outputs, # dictionary of files
     executor,
     executor_arg,  ## ignore - only used for compile_module_test
     workdir,
     args) = construct_signature_compile_config(ctx, module_name)

    if debug:
        print("compiling signature: %s" % ctx.label)
        print("INPUT BOOTINFO:")
        dump_bootinfo(inputs.bootinfo)
        print("OUTPUTS: %s" % outputs)
        print("INPUTS: %s" % inputs)

    cc_toolchain = find_cpp_toolchain(ctx)

    std_fds = []
    if ctx.outputs.stdout_actual:
        stdout = "1> {}".format(ctx.outputs.stdout_actual.path)
        std_fds.append(ctx.outputs.stdout_actual)
    else:
        stdout = ""

    if ctx.outputs.stderr_actual:
        stderr = "2> {}".format(ctx.outputs.stderr_actual.path)
        std_fds.append(ctx.outputs.stderr_actual)
    else:
        stderr = ""

    logfile_output = []
    logfile_cp = ""
    if ctx.outputs.stdlog_actual:
        logfile_output.append(ctx.outputs.stdlog_actual)

        #NB: ln -s won't work since dumpfile will be removed
        #(since it is not an output), giving us a dangling symlink
        logfile_cp = "cp {dumpfile} {logfile} ;".format(
            dumpfile = outputs["cmstruct"].path + ".dump",
            logfile = ctx.outputs.stdlog_actual.path
        )

    ################
    # run_shell: runs compiler with stdout/stderr redirection
    ctx.actions.run_shell(
        tools = [executor],
        command = " ".join([
            # "set -uo pipefail;",
            "set +e;",
            "set -x;" if ctx.attr.debug else "",
            "RC=0;", # need this for compiles that succeed
            "{exe} $@".format(exe=executor.path),
            stdout,
            stderr,
            "|| RC=$? || true ; ", # for compiles that fail
            # "echo RC: $? ;",
            "if [ $RC != \"{rc}\" ];".format(rc=ctx.attr.rc_expected),
            "then",
            "    echo \"Expected rc: {rc}; actual rc: $RC\";".format(rc=ctx.attr.rc_expected),
            "    exit $RC;",
            # "    exit 0",
            "fi ;",
            logfile_cp
        ]),
        arguments = [args],
        inputs    = depset(
            direct = inputs.files + [executor],
            transitive = []
            + inputs.bootinfo.sigs
            + inputs.bootinfo.structs
            + inputs.bootinfo.cli_link_deps
            # etc.
            + [cc_toolchain.all_files] ##FIXME: only for sys outputs
        ),
        outputs   = [outputs["cmi"]] + std_fds + logfile_output,
        mnemonic = "CompileSignaturePlus",
        progress_message = progress_msg(workdir, ctx)
    )

    #############################################
    ################  PROVIDERS  ################
    if not ctx.attr.rc_expected == 0:
        ## no compilation outputs, only stdout/stderr actuals
        default_depset = depset(
            order = dsorder,
            direct = outputs["cmi"] + std_fds + logfile_output
        )
        defaultInfo = DefaultInfo(
            files = default_depset
        )

        outputGroupInfo = OutputGroupInfo(
            all    = depset(
                direct = outputs["cmi"] + std_fds + logfile_output
            )
        )
        bootInfo   = BootInfo()
        moduleInfo = ModuleInfo()

        return [defaultInfo, bootInfo, moduleInfo, outputGroupInfo]

    ## compile succeeded with side-effects
    default_depset = depset(
        order = dsorder,
        direct = [
            outputs["cmi"],
        ]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )
    providers = [defaultInfo]

    ## FIXME: switch to SigInfo provider
    sigProvider = OcamlSignatureProvider(
        mli  = inputs.mli,
        cmi  = outputs["cmi"],
        cmti = outputs["cmti"]
    )
    providers.append(sigProvider)

    sigInfo = SigInfo(
        mli  = inputs.mli,
        cmi  = outputs["cmi"],
        cmti = outputs["cmti"]
    )
    providers.append(sigInfo)

    this_path = outputs["cmi"].dirname
    bootProvider = BootInfo(
        sigs     = depset(order=dsorder,
                          direct = [outputs["cmi"]],
                          transitive = inputs.bootinfo.sigs),
        cli_link_deps = depset(order=dsorder,
                               transitive = inputs.bootinfo.cli_link_deps),
        afiles   = depset(order=dsorder,
                          transitive = inputs.bootinfo.afiles),
        ofiles   = depset(order=dsorder,
                          transitive = inputs.bootinfo.ofiles),
        archived_cmx  = depset(order=dsorder,
                               transitive = inputs.bootinfo.archived_cmx),
        paths    = depset(
            order = dsorder,
            direct = [this_path],
            transitive = inputs.bootinfo.paths
        )
    )
    providers.append(bootProvider)

    if outputs["cmti"]:
        cmti_depset = depset(direct=[outputs["cmti"]])
    else:
        cmti_depset = depset()

    all_group = [outputs["cmi"]]
    if ctx.outputs.stdout_actual:
        all_group.append(ctx.outputs.stdout_actual)
    if ctx.outputs.stderr_actual:
        all_group.append(ctx.outputs.stderr_actual)
    if ctx.outputs.stdlog_actual:
        all_group.append(ctx.outputs.stdlog_actual)
    if outputs["cmti"]:
        all_group.append(outputs["cmti"])

    outputGroupInfo = OutputGroupInfo(
        cmi    = depset(direct=[outputs["cmi"]]),
        cmit   = cmti_depset,
        all    = depset(
            direct = all_group,
        )
    )
    providers.append(outputGroupInfo)

    return providers


    # default_depset = depset(
    #     order = dsorder, direct = [out_cmi]
    # )

    # defaultInfo = DefaultInfo(
    #     files = default_depset
    # )

    # ## FIXME: switch to SigInfo provider
    # sigProvider = OcamlSignatureProvider(
    #     mli  = mlifile,
    #     cmi  = out_cmi,
    #     cmti = out_cmti
    # )

    # sigInfo = SigInfo(
    #     mli  = mlifile,
    #     cmi  = out_cmi,
    #     cmti = out_cmti
    # )

    # bootInfo = BootInfo(
    #     sigs     = sigs_depset,
    #     cli_link_deps = cli_link_deps_depset,
    #     afiles   = afiles_depset,
    #     ofiles   = ofiles_depset,
    #     archived_cmx  = archived_cmx_depset,
    #     paths    = paths_depset,
    # )

    # providers = [
    #     defaultInfo,
    #     bootInfo,
    #     sigProvider,
    #     sigInfo,
    # ]

    # if ctx.attr._rule in [
    #     "kernel_signature",
    #     "stdlib_signature",
    #     "stdlib_internal_signature"
    # ]:
    #     providers.append(StdlibSigMarker())

    # if ctx.attr._rule in [
    #     "compiler_signature",
    #     "ns_signature",
    #     "test_signature"
    # ]:
    #     providers.append(StdSigMarker())

    # if ccInfo_list:
    #     providers.append(
    #         cc_common.merge_cc_infos(cc_infos = ccInfo_list)
    #     )

    # outputGroupInfo = OutputGroupInfo(
    #     sigfile = depset(direct=[mlifile]),
    #     cmi     = depset(direct=[out_cmi]),
    #     cmti    = depset(direct=[out_cmti]) if out_cmti else depset(),
    #     all     = depset(direct=[mlifile, out_cmi]
    #                      + ([out_cmti] if out_cmti else []))
    # )
    # providers.append(outputGroupInfo)

    # return [] # providers
