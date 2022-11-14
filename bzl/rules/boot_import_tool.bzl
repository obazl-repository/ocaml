# simple rule whose purpose is to add runfiles to a precompiled
# executable - in this case, adding the runtime to boot/ocamlc and
# boot/ocamllex.

########################
def _boot_import_tool(ctx):

    tool = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.symlink(output = tool,
                        target_file = ctx.file.tool)

    runfiles = ctx.runfiles(
        files = ctx.files.data + ctx.files.deps
    )

    defaultInfo = DefaultInfo(
        executable = tool,
        runfiles   = runfiles
    )
    return defaultInfo

#####################
boot_import_tool = rule(
    implementation = _boot_import_tool,

    doc = "Imports a precompiled binary",

    attrs = dict(
        tool = attr.label(
            allow_single_file = True,
        ),
        deps = attr.label_list(
            allow_files = True
        ),
        data = attr.label_list(
            allow_files = True
        ),
    ),
    executable = True,
    # cfg = exec
)
