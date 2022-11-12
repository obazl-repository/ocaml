load("//config:CONFIG.bzl", "OCAML_BINDIR", "OCAML_LIBDIR")

########################
def _boot_config(ctx):

    o = ctx.outputs.out

    tc = None
    if ctx.attr._stage == "boot":
        tc = ctx.exec_groups["boot"].toolchains[
            "//boot/toolchain/type:boot"]
    elif ctx.attr._stage == "boot":
        tc = ctx.exec_groups["boot"].toolchains[
            "//boot/toolchain/type:boot"]
    else:
        # print("MISSING STAGE")
        tc = ctx.exec_groups["boot"].toolchains[
            "//boot/toolchain/type:boot"]

    stdlib_dir = ""
    for rf in tc.compiler[DefaultInfo].default_runfiles.files.to_list():
        # print("RF: %s" % rf.path)
        if rf.short_path.startswith("stdlib"):
            stdlib_dir = rf.dirname
    # fail("x")
# bazel-out/darwin-opt-exec-2B5CBBC6/bin/stdlib
    config_hdr = ctx.actions.declare_file("config.hdr")

    ctx.actions.expand_template(
        template = ctx.file.header,
        output   = config_hdr,
        substitutions = {
            "{BINDIR}" : OCAML_BINDIR,
            "{STDLIB}" : "bazel-bin/stdlib/_build"
        }
    )

    ctx.actions.run_shell(
        outputs = [ctx.outputs.out],
        inputs  = [config_hdr, ctx.file.footer],
        command = " ".join([
            "cat {} > {o};".format(config_hdr.path, o=ctx.outputs.out.path),
            "cat {} >> {o};".format(ctx.file.footer.path, o=ctx.outputs.out.path),
        ])
    )


    return [DefaultInfo(files=depset([ctx.outputs.out]))]

#####################
boot_config = rule(
    implementation = _boot_config,

    doc = "Builds boot toolchain and installs in .bootstrap/",
    exec_groups = {
        "boot": exec_group(
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        "baseline": exec_group(
            exec_compatible_with = [
                "//platforms/ocaml/executor:vm?",
                "//platforms/ocaml/emitter:vm?"
            ],
            toolchains = ["//boot/toolchain/type:baseline"],
        ),
    },

    attrs = dict(
        out = attr.output(
            mandatory = True,
        ),
        header = attr.label(
            allow_single_file = True,
        ),
        footer = attr.label(
            allow_single_file = True
        ),
        _stage = attr.label(
            default = "//config/stage"
        ),
        ocaml_bindir = attr.label(
            # allow_single_file = True,
            # default = "//boot/bin"
        ),
        ocaml_stdlib_dir = attr.label(
            allow_single_file = True,
            default = "//stdlib:Std_exit"
        )
    )
)
