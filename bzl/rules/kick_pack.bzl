################
def build_packed_module(
    ctx, ordered_manifest, inputs_depset,
    linkargs_depset, paths_depset, cmi_depset, ccInfo_list):

    print("BUILDING PACKED MODULE: %s" % ctx.attr.pack_ns)

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    module_name = ctx.attr.pack_ns[:1].capitalize() + ctx.attr.pack_ns[1:]
    out_cm_ = ctx.actions.declare_file(tmpdir + module_name + ".cmo")
    out_cmi = ctx.actions.declare_file(tmpdir + module_name + ".cmi")

    args = ctx.actions.args()

    _options = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

    args.add("-pack")

    for dep in ordered_manifest:
        if dep.extension != "cmi":
            args.add(dep)

    if ctx.attr.stdlib:
        inputs = depset(
            transitive = [ctx.attr.stdlib[0][BootInfo].inputs,
                          inputs_depset]
        )
        args.add("-I", ctx.file.stdlib.dirname)
    else:
        inputs = inputs_depset

    args.add("-o", out_cm_)

    ctx.actions.run(
        # env = env,
        executable = tc.compiler[DefaultInfo].files_to_run,
        arguments = [args],
        inputs    = inputs,
        outputs   = [out_cm_, out_cmi],
        tools = [tc.compiler[DefaultInfo].files_to_run],
        mnemonic = "CompilePackedModule",
        progress_message = "{mode} packing {rule}: {ws}//{pkg}:{tgt}".format(
            mode = "TEST", # mode,
            rule=ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name,
        )
    )

    providers = []

    default_depset = depset(
        order = dsorder,
        # direct = default_outputs,
        transitive = [depset(direct=[out_cm_, out_cmi])]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )
    providers.append(defaultInfo)

    ocamlProvider = BootInfo(
        # files = ocamlProvider_files_depset,
        cmi      = cmi_depset,
        fileset  = defaultInfo, # fileset_depset,
        inputs   = depset(direct = [out_cm_, out_cmi],
                          transitive = [inputs_depset]),
        linkargs = linkargs_depset,
        paths    = paths_depset,
        # archive_manifests = archiveManifestDepset
    )
    providers.append(ocamlProvider)

    if ccInfo_list:
        ccInfo_merged = cc_common.merge_cc_infos(cc_infos = ccInfo_list)
        providers.append(ccInfo_merged)

    return providers

