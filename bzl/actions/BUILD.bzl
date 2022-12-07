def progress_msg(workdir, ctx):
    rule = ctx.attr._rule
    if rule in ["ocaml_compiler", "build_tool", "ocaml_lex", "ocaml_tool"]:
        action = "Linking"
    elif rule in ["compiler_module", "build_module", "stdlib_module", "stdlib_internal_module", "kernel_module"]:
        action = "Compiling"
    elif rule in ["compiler_signature", "stdlib_signature", "stdlib_internal_signature", "kernel_signature"]:
        action = "Compiling"
    elif rule == "boot_archive":
        action = "Archiving"
    else:
        fail(rule)

    msg = "{m} [{wd}]: {ws}//{pkg}:{tgt} {action} {rule}".format(
        m   = ctx.var["COMPILATION_MODE"],
        wd  = workdir,
        # m  = ctx.attr._compilation_mode,
        rule= rule,
        ws  = ctx.label.workspace_name if ctx.label.workspace_name else "", ## ctx.workspace_name,
        pkg = ctx.label.package,
        tgt=ctx.label.name,
        action = action
    )
    return msg
