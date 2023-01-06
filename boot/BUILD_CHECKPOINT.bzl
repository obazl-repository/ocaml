load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

## FIXME: depends on bash; won't work on windows. Task: rewrite in C.

################################################################
################################################################
def _checkpoint_in_transition_impl(settings, attr):
    debug = False

    if debug:
        print("TRANSITION: checkpoint_in_transition")
        print("protocol: %s" % settings["//config/build/protocol"])
        print("compiler: %s" % settings["//toolchain:compiler"])
        print("config_executor: %s" % settings["//config/target/executor"])
        print("config_emitter: %s" % settings["//config/target/emitter"])
        print("setting protocol to: boot")

        # if settings["//config/target/executor"] == "boot":
    #     executor = "sys"
    #     emitter  = "vm"
    # else:
    #     executor = settings["//config/target/executor"]
    #     emitter  = settings["//config/target/emitter"]

    return {
        "//config/build/protocol": "boot",
        # "//config/target/executor": executor,
        # "//config/target/emitter" : emitter
    }

###################################
_checkpoint_in_transition = transition(
    implementation = _checkpoint_in_transition_impl,
    inputs = [
        "//config/build/protocol",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler"
    ],
    outputs = [
        "//config/build/protocol",
        # "//config/target/executor",
        # "//config/target/emitter"
    ]
)

########################
def _boot_checkpoint_impl(ctx):

    # runner = ctx.file.runner
    # ERROR: 'executable' provided by an executable rule
    # 'boot_checkpoint' should be created by the same rule.
    # So:
    runner = ctx.actions.declare_file("checkpoint.sh")
    ctx.actions.symlink(output = runner,
                        target_file = ctx.file.runner)

    rfs = []

    # for var in ctx.var:
    #     print("CTX var: {k}: {v}".format(
    #         k = var, v = ctx.var[var]))

    ## we need to pass //config/target/executor, //config/target/emitter
    ## as args to checkpoint.sh. We cannot set the 'args' attr here,
    ## so we write them to files and pass them in runfiles.
    ## the shell script reads them to discover what is being built
    ## and needs to be copied to .baseline/bin.

    # executor = ctx.actions.declare_file("executor")
    # ctx.actions.write(
    #     output  = executor,
    #     content = ctx.attr._target_executor[BuildSettingInfo].value
    # )
    # emitter = ctx.actions.declare_file("emitter")
    # ctx.actions.write(
    #     output  = emitter,
    #     content = ctx.attr._target_emitter[BuildSettingInfo].value
    # )
    # rfs.append(depset(direct = [executor, emitter]))

    for d in ctx.attr.data:
        # print("DATUM: %s" % d)
        rfs.append(d.files)
        rfs.append(d[DefaultInfo].default_runfiles.files)

    # rfs.append(ctx.attr.lexer[DefaultInfo].files)
    # rfs.append(ctx.attr.lexer[DefaultInfo].default_runfiles.files)
    # for f in ctx.files.runtimes:
    #     # print("RUNTIME: %s" % d)
    #     rfs.append(f)

    runfiles = ctx.runfiles(
        files = ctx.files.runtimes,
        transitive_files = depset(transitive=rfs)
        # files = ctx.files.data + ctx.files.deps
    )

    defaultInfo = DefaultInfo(
        executable = runner,
        runfiles   = runfiles
    )

    return defaultInfo

#####################
boot_checkpoint = rule(
    implementation = _boot_checkpoint_impl,

    doc = "Builds boot toolchain and installs in .bootstrap/",

    attrs = dict(
        runner = attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = "//boot:checkpoint.sh",
        ),
        compilers = attr.label_list(
            allow_files = True
        ),
        data = attr.label_list(
            allow_files = True
        ),
        # lexer = attr.label(
        #     allow_single_file = True,
        #     default = "//lex:ocamllex",
        # ),
        deps = attr.label_list(
            allow_files = True
        ),

        runtimes = attr.label_list(
            allow_files = True,
            doc = "libcamlrun.a, libsmrun.a"
        ),

        _verbose = attr.label(default = "//boot:verbose"),

        _target_executor = attr.label(default = "//config/target/executor"),

        _target_emitter = attr.label(default = "//config/target/emitter"),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

    ),
    cfg = _checkpoint_in_transition,
    executable = True,
    # toolchains = ["//toolchain/type:ocaml"],
)

###############################
# def boot_checkpoint(**kwargs):
#   if "args" not in kwargs:
#       kwargs["args"] = ["a", "b", "c"]
#   _boot_checkpoint(**kwargs)

################################################################

# def _boot_setup_impl(ctx):

#     runner = ctx.actions.declare_file("setup.sh")
#     ctx.actions.symlink(output = runner,
#                         target_file = ctx.file.runner)

#     rfs = []

#     for d in ctx.attr.data:
#         # print("DATUM: %s" % d)
#         rfs.append(d.files)
#         rfs.append(d[DefaultInfo].default_runfiles.files)

#     # for f in ctx.files.runtimes:
#     #     # print("RUNTIME: %s" % d)
#     #     rfs.append(f)

#     runfiles = ctx.runfiles(
#         # files = ctx.files.runtimes,
#         transitive_files = depset(transitive=rfs)
#     )

#     defaultInfo = DefaultInfo(
#         executable = runner,
#         runfiles   = runfiles
#     )

#     return defaultInfo

# #####################
# boot_setup = rule(
#     implementation = _boot_setup_impl,

#     doc = "Prebuilds CC tools",

#     attrs = dict(
#         runner = attr.label(
#             allow_single_file = True,
#             executable = True,
#             cfg = "exec",
#             default = "//boot:checkpoint.sh",
#         ),
#         data = attr.label_list(
#             allow_files = True
#         ),
#     ),
#     executable = True,
# )
