load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:functions.bzl", "stage_name")

load("//bzl/rules/common:impl_common.bzl", "tmpdir")

# incoming transition to ensure this is only built once.
# use ctx.actions.expand_template, six times

########################
def _boot_camlheaders(ctx):

    # NOTE: we only need to emit one file, since we do not build *d,
    # *i named variants.

    # print("PFX: %s" % ctx.attr.prefix)

    # for f in ctx.attr.runtimes:
    #     print("RF: %s" % f[DefaultInfo].default_runfiles.symlinks.to_list())
    pfx = ""
    tc = ctx.exec_groups["boot"].toolchains[
            "//boot/toolchain/type:boot"]

    workdir = "_{}/".format(stage_name(tc._stage))

    # workdir = "_{}/".format(ctx.attr._stage[BuildSettingInfo].value)

    outputs = []
    for f in ctx.files.runtimes:

        # write a template file with abs path to ws root
        # o = ctx.actions.declare_file("_build/camlheader")
        # ctx.actions.run_shell(
        #     outputs = [o],
        #     command = """
        #     full_path="$(readlink -f -- "{wsfile}")"
        #     echo $full_path;
        #     echo "#!$full_path/{runtime}" > {ofile}
        #     """.format(
        #         wsfile = ctx.file._wsfile.dirname,
        #         runtime = f.path,
        #         ofile = o.path),
        #     execution_requirements = {
        #         # "no-sandbox": "1",
        #         "no-remote": "1",
        #         "local": "1",
        #     }
        # )

        camlheader = ctx.actions.declare_file(workdir + "camlheader")
        # print("Emitting camlheader: %s" % camlheader.path)
        # print("  camlheader path: %s" % pfx + f.path)
        ctx.actions.expand_template(
            output   = camlheader,
            template = ctx.file.template,
            substitutions = {"PATH": pfx + f.path})
        outputs.append(camlheader)

        camlheaderd = ctx.actions.declare_file(workdir + "camlheaderd")
        # print("Emitting camlheaderd: %s" % camlheaderd.path)
        ctx.actions.expand_template(
            output   = camlheaderd,
            template = ctx.file.template,
            substitutions = {"PATH": pfx + f.path + "d"})
        outputs.append(camlheaderd)

        camlheaderi = ctx.actions.declare_file(workdir + "camlheaderi")
        # print("Emitting camlheaderi: %s" % camlheaderi.path)
        ctx.actions.expand_template(
            output   = camlheaderi,
            template = ctx.file.template,
            substitutions = {"PATH": pfx + f.path + "i"})
        outputs.append(camlheaderi)

    ctx.actions.do_nothing(
        mnemonic = "CamlHeaders"
    )

    runfiles = ctx.runfiles(
        files = ctx.files.runtimes
    )

    defaultInfo = DefaultInfo(
        files=depset(direct = outputs),
        runfiles = runfiles
    )
    return defaultInfo

#####################
boot_camlheaders = rule(
    implementation = _boot_camlheaders,
    doc = "Generates camlheader files",
    exec_groups = {
        "boot": exec_group(
            exec_compatible_with = [
                "//platform/constraints/ocaml/executor:vm?",
                "//platform/constraints/ocaml/emitter:vm"
            ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm?",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },

    attrs = {
        # "_stage"   : attr.label( default = "//bzl:stage" ),
        "template" : attr.label(mandatory = True,allow_single_file=True),
        "runtimes" : attr.label_list(
            mandatory = True,
            allow_files=True
        ),
        "prefix"   : attr.string(mandatory = False),
        "suffix"   : attr.string(mandatory = False),
        "_wsfile": attr.label(
            allow_single_file = True,
            default = "@//:BUILD.bazel")
    }
)
