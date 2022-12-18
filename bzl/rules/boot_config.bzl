load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//config:CONFIG.bzl", "OCAML_BINDIR")

########################
def _boot_config(ctx):

    o = ctx.outputs.out

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    # (executor, emitter, workdir) = get_workdir(ctx, tc)

    # if executor in ["boot", "vm"]:
    if tc.build_executor == "vm":
        ext = ".cmo"
    else:
        ext = ".cmx"

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
            "{STDLIB}" : ctx.file.stdlib.dirname
        }
    )

    ctx.actions.run_shell(
        outputs = [ctx.outputs.out],
        inputs  = [config_hdr, ctx.file.footer] + ctx.files.deps,
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
    attrs = dict(
        out = attr.output(
            mandatory = True,
        ),
        header = attr.label(
            allow_single_file = True,
        ),
        deps = attr.label_list(

        ),
        stdlib = attr.label(
            allow_single_file = True
        ),
        footer = attr.label(
            allow_single_file = True
        ),
        # _stage = attr.label(
        #     default = "//config/stage"
        # ),
        ocaml_bindir = attr.label(
            # allow_single_file = True,
            # default = "//boot/baseline"
        ),
        ocaml_stdlib_dir = attr.label(
            allow_single_file = True,
            default = "//stdlib:Std_exit"
        )
    ),
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
