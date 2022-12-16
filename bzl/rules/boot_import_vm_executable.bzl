## WARNING: single-use rule
# simple rule whose purpose is to add runfiles to a precompiled
# executable - in this case, adding the runtime to boot/ocamlc and
# boot/ocamllex.

# load("//bzl/transitions:tc_transitions.bzl", "reset_config_transition")

########################
def _boot_import_vm_executable(ctx):

    tool = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.symlink(output = tool,
                        target_file = ctx.file.tool)

    runfiles = ctx.runfiles(
        files = [ctx.file._runtime]
    )

    defaultInfo = DefaultInfo(
        executable = tool,
        runfiles   = runfiles
    )
    return defaultInfo

#####################
boot_import_vm_executable = rule(
    implementation = _boot_import_vm_executable,

    doc = "Imports a precompiled vm executble and the executor (ocamlrun) needed to run it.",

    attrs = dict(
        tool = attr.label(
            allow_single_file = True,
        ),
        _runtime = attr.label(
            allow_single_file = True,
            default = "//runtime:ocamlrun",
            executable = True,
            cfg = "exec"
            # cfg = reset_config_transition
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
    ),
    # executable = True,
    # cfg = exec
)
