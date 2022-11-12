
########################
def _boot_coldstart(ctx):

    runner = ctx.actions.declare_file("coldstart.sh")
    ctx.actions.symlink(output = runner,
                        target_file = ctx.file.runner)

    runfiles = ctx.runfiles(
        files = ctx.files.data + ctx.files.deps
    )

    defaultInfo = DefaultInfo(
        executable = runner,
        runfiles   = runfiles
    )
    return defaultInfo

#####################
boot_coldstart = rule(
    implementation = _boot_coldstart,

    doc = "Builds boot toolchain and installs in .bootstrap/",

    attrs = dict(
        runner = attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "//boot:coldstart.sh",
        ),
        data = attr.label_list(
            allow_files = True
        ),
        deps = attr.label_list(
            allow_files = True
        ),
    ),
    executable = True,
    # toolchains = ["//toolchain/type:boot"],
)
