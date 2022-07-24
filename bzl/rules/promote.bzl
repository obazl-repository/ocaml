def _promote_impl(ctx):
    print("PROMOTING %s" % ctx.attr.srcs)
    for s in ctx.files.srcs:
        print("S: %s" % s)

    promote = ctx.actions.declare_file("promote.sh")

    cmds = [
        "echo 'cp -v {src} {dst}' >> {out};".format(
            src = s.path, dst = ctx.attr.dst,
            out = promote.path)
        for s in ctx.files.srcs
    ]
    print("cmds: %s" % cmds)

    ## we need to use run_shell to force the src to build
    ## just using ctx.actions.write will not do it
    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = [promote],
        command = "\n".join([
            ## create the shell script that will be run by 'bazel run'
            "echo '#!/bin/sh' > {out};".format(out = promote.path),
            # when this is run using 'bazel run <target>',
            # Bazel sets BUILD_WORKSPACE_DIRECTORY to proj root
            "echo cd  \\$BUILD_WORKSPACE_DIRECTORY > {out};".format(out = promote.path),
            "echo 'mkdir -p {dst}' >> {out};".format(
                dst = ctx.attr.dst, out = promote.path),
        ] + cmds + [
            # "echo 'cp -v {src} {dst}' >> {out};".format(
            #     src = ctx.file.src.path, dst = ctx.attr.dst,
            #     out = promote.path),
            "echo `cat {out}`;".format(out = promote.path)
        ]),
    )

    return [DefaultInfo(executable = promote)]

#################
promote = rule(
    implementation = _promote_impl,
    doc = "Copies file into workspace/tmp.",
    attrs = dict(
        srcs = attr.label_list(
            doc = "files to promote",
            mandatory = True
        ),
        dst = attr.string(
            doc = "relative directory which to copy src",
            mandatory = True
        ),
        # _tool = attr.label(
        #     default = ":promote.sh",
        #     executable = True,
        #     cfg = "exec",
        #     allow_single_file = True,
        # )
    ),
    executable = True,
    # toolchains = ["//toolchain/type:bootstrap"]
)
