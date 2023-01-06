## import precompiled executables

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

################################################################
## boot_ocamlc_import_in_transition: transition to const config, so
## the dependent ocamlrun is only built once.
def _boot_ocamlc_import_in_transition_impl(settings, attr):
    debug = False

    if debug:
        print("TRANSITION: boot_ocamlc_import_in_transition")
        print("protocol: %s" % settings["//config/build/protocol"])
        print("compiler: %s" % settings["//toolchain:compiler"])

    ## compiler should always be boot:ocamlc.boot

    return {
        "//config/build/protocol": "preboot", # FIXME
        "//toolchain:compiler"   : "//boot:ocamlc"
    }

###################################
boot_ocamlc_import_in_transition = transition(
    implementation = _boot_ocamlc_import_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//toolchain:compiler"
    ],
    outputs = [
        "//config/build/protocol",
        "//toolchain:compiler"
    ]
)

##################################
def _boot_ocamlc_import_impl(ctx):
    ocamlc = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.symlink(output = ocamlc,
                        target_file = ctx.file._ocamlc)
    runfiles = ctx.runfiles(
        files = [ctx.file._ocamlrun]
    )
    defaultInfo = DefaultInfo(
        executable = ocamlc,
        runfiles   = runfiles
    )
    return defaultInfo

#####################
boot_ocamlc_import = rule(
    implementation = _boot_ocamlc_import_impl,
    doc = "Imports the precompiled ocamlc, uses it to build stdlib and adds to runfiles",
    attrs = dict(
        _ocamlc = attr.label(
            allow_single_file = True,
            default = ":ocamlc"
        ),
        _ocamlrun = attr.label(
            allow_single_file = True,
            default = "//runtime:ocamlrun",
            executable = True,
            # cfg = "exec"
            cfg = reset_cc_config_transition
        ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
    ),
    # executable = True,
    cfg = boot_ocamlc_import_in_transition
)

################################################################
## generic import
################################################################
def _boot_import_vm_executable(ctx):

    tool = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.symlink(output = tool,
                        target_file = ctx.file.tool)

    runfiles = ctx.runfiles(
        files = ctx.files._stdlib
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
            mandatory = True,
            allow_single_file = True,
        ),
        # stdlib is a runtime dep of the linker, so we need to build
        # it and add it runfiles.
        _stdlib = attr.label(
            doc = "Stdlib archive", ## (not stdlib.cmx?a")
            default = "//stdlib", # archive, not resolver
            # allow_single_file = True, # won't work with boot_library
            executable = False,
            cfg = "exec"
            # cfg = exe_deps_out_transition,
        ),

        # _ocamlrun = attr.label(
        #     allow_single_file = True,
        #     default = "//runtime:ocamlrun",
        #     executable = True,
        #     # cfg = "exec"
        #     cfg = reset_cc_config_transition
        # ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
    ),
    # executable = True,
    # cfg = exec
)
