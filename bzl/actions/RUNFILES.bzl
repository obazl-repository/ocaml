####################
def runfiles_bash(ctx):
# https://github.com/bazelbuild/bazel/blob/master/tools/bash/runfiles/runfiles.bash
    args = []
# --- begin runfiles.bash initialization v2 ---
    args.extend([
        # "set -x",
        # "echo PWD: $(PWD);",
        # "ls -la;",
        # "echo RUNFILES_DIR: $RUNFILES_DIR;",
        "set -uo pipefail; set +e;",
        "f=bazel_tools/tools/bash/runfiles/runfiles.bash ",
        "source \"${RUNFILES_DIR:-/dev/null}/$f\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"${RUNFILES_MANIFEST_FILE:-/dev/null}\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    source \"$0.runfiles/$f\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"$0.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    source \"$(grep -sm1 \"^$f \" \"$0.exe.runfiles_manifest\" | cut -f2- -d' ')\" 2>/dev/null || \\",
        "    { echo \"ERROR: cannot find $f\"; exit 1; };", ##  f=; set -e; ",
    ])
    # --- end runfiles.bash initialization v2 ---

    if (ctx.attr.verbose):
        args.append("if [ -x ${RUNFILES_DIR+x} ]")
        args.append("then")
        args.append("    echo \"MANIFEST: ${RUNFILES_MANIFEST_FILE}\"")
        args.append("    cat ${RUNFILES_MANIFEST_FILE}")
        args.append("else")
        args.append("    echo \"RUNFILES_DIR: ${RUNFILES_DIR}\"")
        # args.append("    echo \"MANIFEST: ${RUNFILES_MANIFEST_FILE}\"")
        args.append("fi")
        args.append("")

    return "\n".join(args)

