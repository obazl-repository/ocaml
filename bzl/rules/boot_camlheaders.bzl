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
    pfx = "/private/var/tmp/_bazel_gar/09f4473853c1f6ac5f0e30e04907354e/execroot/ocaml_tools/"

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

        camlheader = ctx.actions.declare_file(tmpdir + "camlheader")
        ctx.actions.expand_template(
            output   = camlheader,
            template = ctx.file.template,
            substitutions = {"PATH": pfx + f.path})
        outputs.append(camlheader)

        camlheaderd = ctx.actions.declare_file(tmpdir + "camlheaderd")
        ctx.actions.expand_template(
            output   = camlheaderd,
            template = ctx.file.template,
            substitutions = {"PATH": pfx + f.path + "d"})
        outputs.append(camlheaderd)

        camlheaderi = ctx.actions.declare_file(tmpdir + "camlheaderi")
        ctx.actions.expand_template(
            output   = camlheaderi,
            template = ctx.file.template,
            substitutions = {"PATH": pfx + f.path + "i"})
        outputs.append(camlheaderi)

    runfiles = ctx.runfiles(
        files = outputs
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
    attrs = {
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
