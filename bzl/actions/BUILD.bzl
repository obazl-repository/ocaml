def progress_msg(stage, workdir, ctx):
    progress_message = "{wd}: {ws}//{pkg}:{tgt} compiling {rule}, stage {s}".format(
        s = stage,
        wd = workdir,
        rule=ctx.attr._rule,
        ws  = ctx.label.workspace_name if ctx.label.workspace_name else "", ## ctx.workspace_name,
        pkg = ctx.label.package,
        tgt=ctx.label.name,
    )
