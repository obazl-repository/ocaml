#!/bin/bash

# echo "HELLO"

# echo "args: $@"

# --- begin runfiles.bash initialization ---
# Copy-pasted from Bazel's Bash runfiles library (tools/bash/runfiles/runfiles.bash).
# set -euo pipefail
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
    if [[ -f "$0.runfiles_manifest" ]]; then
        export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"
    elif [[ -f "$0.runfiles/MANIFEST" ]]; then
        export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
    elif [[ -f "$0.runfiles/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
        export RUNFILES_DIR="$0.runfiles"
    fi
fi

echo "RUNFILES_DIR: ${RUNFILES_DIR}"
echo "RUNFILES_MANIFEST_FILE: ${RUNFILES_MANIFEST_FILE}"
echo
for x in `cat ${RUNFILES_MANIFEST_FILE}`; do
    echo $x
done
# echo `cat  ${RUNFILES_MANIFEST_FILE}`
echo

if [[ -f "${RUNFILES_DIR:-/dev/null}/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
    source "${RUNFILES_DIR}/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
    source "$(grep -m1 "^bazel_tools/tools/bash/runfiles/runfiles.bash" "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
else
    echo >&2 "ERROR: cannot find @bazel_tools//tools/bash/runfiles:runfiles.bash"
    exit 1
fi
#       # --- end runfiles.bash initialization ---

# echo "camlheader: $(rlocation ocaml-dev/stdlib/camlheader)"

# set -x

echo "PWD: $(PWD)"
echo "BUILD_WORKSPACE_DIRECTORY: $BUILD_WORKSPACE_DIRECTORY"
echo "BUILD_WORKING_DIRECTORY: $BUILD_WORKING_DIRECTORY"

BOOTDIR=$BUILD_WORKSPACE_DIRECTORY/.bootstrap

mkdir -p $BOOTDIR/bin
mkdir -p $BOOTDIR/lib

echo "workspace(name = \"boot\")" > $BOOTDIR/WORKSPACE.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/BUILD.bazel

cp -f $(rlocation ocaml-dev/runtime/ocamlrun) $BOOTDIR/bin
cp -f $(rlocation ocaml-dev/boot/ocamlc) $BOOTDIR/bin/ocamlc.byte
cp -f $(rlocation ocaml-dev/boot/ocamllex) $BOOTDIR/bin/ocamllex.byte
cp -f $(rlocation ocaml-dev/yacc/ocamlyacc) $BOOTDIR/bin

cp -f $(rlocation ocaml-dev/stdlib/_build/stdlib.cma) $BOOTDIR/lib
cp -f `dirname $(rlocation ocaml-dev/stdlib/_build/stdlib.cma)`/*.cmi $BOOTDIR/lib
cp -f $(rlocation ocaml-dev/stdlib/_build/std_exit.cmo) $BOOTDIR/lib
cp -f $(rlocation ocaml-dev/stdlib/_build/std_exit.cmi) $BOOTDIR/lib

HDRS=`dirname $(rlocation ocaml-dev/stdlib/camlheader)`/camlhead*
cp -f $HDRS $BOOTDIR/lib
HDRS=`dirname $(rlocation ocaml-dev/stdlib/camlheader)`/target_camlhead*
cp -f $HDRS $BOOTDIR/lib

chmod ug=+rx-w,o=-rwx $BOOTDIR/bin/*
chmod ug=+r-xw,o=-rwx $BOOTDIR/bin/ocamlc.byte
chmod ug=+r-xw,o=-rwx $BOOTDIR/bin/ocamllex.byte
chmod ug=+r-wx,o=-rwx $BOOTDIR/lib/*
