load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load(":BUILD.bzl", "progress_msg", "get_build_executor")

load("//bzl:providers.bzl",
     "BootInfo", "dump_bootinfo",
     "DumpInfo",
     "ModuleInfo",
     "NsResolverInfo",
     "DepsAggregator",
     "StdStructMarker",
     "StdlibStructMarker",
     "new_deps_aggregator", "OcamlSignatureProvider")

load("//bzl:functions.bzl", "get_module_name") #, "get_workdir")
load("//bzl/rules/common:DEPS.bzl", "aggregate_deps", "merge_depsets")
load("//bzl/rules/common:impl_common.bzl", "dsorder")
load("//bzl/rules/common:impl_ccdeps.bzl", "dump_CcInfo", "ccinfo_to_string")
load("//bzl/rules/common:options.bzl", "get_options")

load(":module_compile_config.bzl", "construct_module_compile_config")

##################################
def module_compile_plus(ctx, module_name):

    debug = True
    debug_ccdeps = False

    if debug:
        print("module_compile_plus: %s" % ctx.label)

    (inputs,
     outputs, # dictionary of files
     executor,
     executor_arg,  ## ignore - only used for compile_module_test
     workdir,
     args) = construct_module_compile_config(ctx, module_name)

    if debug:
        print("compiling module: %s" % ctx.label)
        print("INPUT BOOTINFO:")
        dump_bootinfo(inputs.bootinfo)
        print("OUTPUTS: %s" % outputs)
        print("INPUT FILES: %s" % inputs.files)
        print("INPUT.structfile: %s" % inputs.structfile)
        print("INPUT.cmi: %s" % inputs.cmi)
        # fail()

    outs = []
    for v in outputs.values():
        if v: outs.append(v)

    # print("OUTS: %s" % outs)
    # if ctx.attr._rule == "test_infer_signature":
    #     fail()

    cc_toolchain = find_cpp_toolchain(ctx)

    ##FIXME: use rule-specific mnemonic, e.g CompileStdlibModule
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
    if ctx.outputs.logfile_actual:
        logfile_output.append(ctx.outputs.logfile_actual)

        #NB: ln -s won't work since dumpfile will be removed
        #(since it is not an output), giving us a dangling symlink
        logfile_cp = "cp {dumpfile} {logfile} ;".format(
            dumpfile = outputs["cmstruct"].path + ".dump",
            logfile = ctx.outputs.logfile_actual.path
        )

    ################
    # run_shell: runs compiler with stdout/stderr redirection
    ctx.actions.run_shell(
        tools = [executor],
        # executable = executor.path,
        command = " ".join([
            # "set -uo pipefail;",
            "set +e;",
            "set -x;",
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
        # inputs: from deps we get a list of depsets, so:
        # inputs = depset(direct=[action inputfiles...],
        #                 transitive=[deps dsets...])
        inputs    = depset(
            direct = inputs.files + [executor],
            transitive = []
            + inputs.bootinfo.sigs
            + inputs.bootinfo.structs
            + inputs.bootinfo.cli_link_deps
            # etc.
            + [cc_toolchain.all_files] ##FIXME: only for sys outputs
        ),
        outputs   = outs + std_fds + logfile_output,
        mnemonic = "CompileModulePlus",
        progress_message = progress_msg(workdir, ctx)
    )

    #############################################
    ################  PROVIDERS  ################

    if not ctx.attr.rc_expected == 0:
        ## no compilation outputs, only stdout/stderr actuals
        default_depset = depset(
            order = dsorder,
            direct = outs + std_fds + logfile_output
        )
        defaultInfo = DefaultInfo(
            files = default_depset
        )

        outputGroupInfo = OutputGroupInfo(
            all    = depset(
                direct = outs + std_fds + logfile_output
            )
        )
        bootInfo   = BootInfo()
        moduleInfo = ModuleInfo()

        return [defaultInfo, bootInfo, moduleInfo, outputGroupInfo]

    ## compile succeeded with side-effects

    default_depset = depset(
        order = dsorder,
        # only output one file; for cmx, get .o from ModuleInfo
        direct = [
            outputs["cmstruct"],
        ]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )
    providers = [defaultInfo]

    cmi_depset = depset(
        direct=[
            outputs["cmi"] if outputs["cmi"] else inputs.cmi
        ])

    if outputs["cmt"]:
        cmt_depset = depset(direct=[outputs["cmt"]]) #[out_cmt]) if out_cmt else depset(),
    else:
        cmt_depset = depset()

    moduleInfo_depset = depset(
        ## FIXME: add ofile?
        direct= [inputs.structfile], # [in_structfile]

        ## FIXME: no need transitive, creating new depset is wasteful
        ## instead:
        # direct = inputs.values()

        transitive = [depset(
            [outputs["cmi"] if outputs["cmi"] else inputs.cmi,
             outputs["cmstruct"]]
            # [out_cm_, provider_output_cmi]

            + ([outputs["ofile"]] if outputs["ofile"] else [])
            # + ([out_o] if out_o else []) # outputs["ofile"]

            + ([outputs["cmt"]] if outputs["cmt"] else [])
            # + ([out_cmt] if out_cmt else [])
        )]
    )

    moduleInfo = ModuleInfo(
        name   = module_name,
        sig    = outputs["cmi"] if outputs["cmi"] else inputs.cmi,
        sig_src = outputs["sigfile"],
        cmti =  outputs["cmti"],

        struct = outputs["cmstruct"],  ## out_cm_
        # struct_src: compilation input in workdir, symlink
        # call it wstruct_src or wd_struct_src?
        struct_src = outputs["structfile"], # in_structfile
        structfile = ctx.file.struct.path,
        cmt = outputs["cmt"], ## out_cmt

        ofile  = outputs["ofile"], ## out_o
        # files = moduleInfo_depset ## FIXME: wasteful???
    )

    if ctx.attr._rule in [
        "kernel_module", # "kernel_signature",
        "stdlib_module", # "stdlib_signature",
        "stdlib_internal_module", # "stdlib_internal_signature"
    ]:
        providers.append(StdlibStructMarker())

    if ctx.attr._rule in [
        "compiler_module", # "compiler_signature",
        "ns_module",
        "test_module"
    ]:
        providers.append(StdStructMarker())

    providers.append(moduleInfo)

    if hasattr(ctx.attr, "ns"):
        if ctx.attr.ns:
            resolver = ctx.attr.ns[ModuleInfo]
            nsResolverInfo = NsResolverInfo(
                sigs   = depset(
                    direct = [resolver.sig],
                    # transitive = ... depsets.deps.resolvers
                ),
                structs = depset(
                    direct = [resolver.struct],
                    # transitive = ... depsets.deps.resolvers
                )
            )
            providers.append(nsResolverInfo)

    this_path = outputs["cmstruct"].dirname
    bootProvider = BootInfo(
        # sigs     = sigs_depset,
        sigs     = depset(order=dsorder,
                          direct = [outputs["cmi"]] if outputs["cmi"] else [inputs.cmi],
                          transitive = inputs.bootinfo.sigs),

        cli_link_deps = depset(order=dsorder,
                               direct = [outputs["cmstruct"]],
                               transitive = inputs.bootinfo.cli_link_deps),
        # cli_link_deps_depset,

        afiles   = depset(order=dsorder,
                          transitive = inputs.bootinfo.afiles),
        # afiles_depset,

        # ofiles   = ofiles_depset,
        ofiles   = depset(order=dsorder,
                          direct = [outputs["ofile"]] if outputs["ofile"] else [],
                          transitive = inputs.bootinfo.ofiles),

        # archived_cmx  = depset(transitive(depsets.deps.archived_cmx)), #_depset,

        paths    = depset(
            order = dsorder,
            direct = [this_path],
            transitive = inputs.bootinfo.paths
        )
    )
    providers.append(bootProvider)

    # if ccInfo_provider:
        # providers.append(ccInfo_provider)
    if len(inputs.ccinfo) > 1:
        ccInfo_provider = cc_common.merge_cc_infos(cc_infos = inputs.ccinfo)
        providers.append(ccInfo_provider)
        if ctx.attr._cc_debug[BuildSettingInfo].value:
            print("ccInfo_provider for %s" % ctx.label)
            print("%s" % ccinfo_to_string(ctx, ccInfo_provider))
        if debug_ccdeps:
            dump_CcInfo(ctx, ccInfo_provider)

    all_group = []
    if ctx.outputs.stdout_actual:
        all_group.append(ctx.outputs.stdout_actual)
    if ctx.outputs.stderr_actual:
        all_group.append(ctx.outputs.stderr_actual)
    if ctx.outputs.logfile_actual:
        all_group.append(ctx.outputs.logfile_actual)

    if ((hasattr(ctx.attr, "dump") and len(ctx.attr.dump) > 0)
        or hasattr(ctx.attr, "_lambda_expect_test")):
        # if len(ctx.attr.dump) > 0:
        d = DumpInfo(dump = ctx.outputs.logfile_actual, # outputs["logfile"],
                     src = inputs.structfile)
        providers.append(d)
    #     outputGroupInfo = OutputGroupInfo(
    #         cmi        = cmi_depset,
    #         module     = moduleInfo_depset,
    #         log = depset([outputs["logfile"]]),
    #         all    = depset(direct=[ctx.outputs.logfile_actual],
    #                         transitive= [moduleInfo_depset]),
    #     )
    # else:
    outputGroupInfo = OutputGroupInfo(
        cmi    = cmi_depset,
        cmt    = cmt_depset,
        ## FIXME: include cmti from sig?
        module = moduleInfo_depset,
        all    = depset(
            direct = all_group,
            transitive = [moduleInfo_depset],
        )
    )
    providers.append(outputGroupInfo)

    return providers
