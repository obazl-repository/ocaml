load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//config:CONFIG.bzl", "OCAML_BINDIR")
load("//bzl:functions.bzl", "tc_compiler")

########################
def _boot_config(ctx):

    o = ctx.outputs.out

    # tc = ctx.exec_groups["boot"].toolchains["//toolchain/type:boot"]
    tc = ctx.toolchains["//toolchain/type:boot"]

    # build_emitter = tc.build_emitter[BuildSettingInfo].value
    # print("BEMITTER: %s" % build_emitter)

    target_executor = tc.target_executor[BuildSettingInfo].value
    target_emitter  = tc.target_emitter[BuildSettingInfo].value

    stage = int(tc._stage[BuildSettingInfo].value)
    workdir = "_{b}{t}{s}/".format(
        b = target_executor, t = target_emitter, s = (stage))

    print("module _stage: %s" % stage)

    if stage == 2:
        ext = ".cmx"
    else:
        if target_executor == "vm":
            ext = ".cmo"
        elif target_executor == "sys":
            ext = ".cmx"
        else:
            fail("Bad target_executor: %s" % target_executor)

    # tc = None
    # if ctx.attr._stage == "boot":
    #     tc = ctx.exec_groups["boot"].toolchains[
    #         "//toolchain/type:boot"]
    # elif ctx.attr._stage == "boot":
    #     tc = ctx.exec_groups["boot"].toolchains[
    #         "//toolchain/type:boot"]
    # else:
    #     # print("MISSING STAGE")
    #     tc = ctx.exec_groups["boot"].toolchains[
    #         "//toolchain/type:boot"]

    stdlib_dir = ""
    for rf in tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list():
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
    # exec_groups = {
    #     "boot": exec_group(
    #         toolchains = ["//toolchain/type:boot"],
    #     ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm_executor?",
        #         "//platform/constraints/ocaml/emitter:vm_emitter"
        #     ],
        #     toolchains = ["//toolchain/type:baseline"],
        # ),
    # },

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
        _stage = attr.label(
            default = "//config/stage"
        ),
        ocaml_bindir = attr.label(
            # allow_single_file = True,
            # default = "//boot/baseline"
        ),
        ocaml_stdlib_dir = attr.label(
            allow_single_file = True,
            default = "//stdlib:Std_exit"
        )
    ),
    toolchains = ["//toolchain/type:boot",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
