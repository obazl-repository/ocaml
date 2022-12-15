#!/bin/bash

# echo "HELLO"

# echo "args: $@"

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
# https://github.com/bazelbuild/bazel/blob/master/tools/bash/runfiles/runfiles.bash
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
    source "$0.runfiles/$f" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
    { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# set -x

echo "PWD: $(PWD)"
echo "BUILD_WORKSPACE_DIRECTORY: $BUILD_WORKSPACE_DIRECTORY"
echo "BUILD_WORKING_DIRECTORY: $BUILD_WORKING_DIRECTORY"

BOOTDIR=$BUILD_WORKSPACE_DIRECTORY/.baseline

echo "Making .baseline directories"

mkdir -p $BOOTDIR/bin
mkdir -p $BOOTDIR/include
mkdir -p $BOOTDIR/lib
mkdir -p $BOOTDIR/src

echo "Installing WORKSPACE and BUILD files"

rm -vrf $BOOTDIR/*.bazel
echo "workspace(name = \"baseline\")" > $BOOTDIR/WORKSPACE.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/BUILD.bazel

rm -vrf $BOOTDIR/bin/*.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/bin/BUILD.bazel

rm -vrf $BOOTDIR/include/*.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/include/BUILD.bazel

rm -vrf $BOOTDIR/lib/*.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/lib/BUILD.bazel

rm -vrf $BOOTDIR/src/*.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/src/BUILD.bazel

echo "Installing programs"

cp -vf $(rlocation ocamlcc/vendor/mustach/mustach) $BOOTDIR/bin

cp -vf $(rlocation ocamlcc/runtime/ints.c) $BOOTDIR/src
cp -vf $(rlocation ocamlcc/runtime/prims.c) $BOOTDIR/src
cp -vf $(rlocation ocamlcc/runtime/primitives.dat) $BOOTDIR/include
cp -vf $(rlocation ocamlcc/runtime/primitives.h) $BOOTDIR/include

cp -vf $(rlocation ocamlcc/runtime/caml/domain_state.h) $BOOTDIR/include
cp -vf $(rlocation ocamlcc/runtime/caml/instruct.h) $BOOTDIR/include
cp -vf $(rlocation ocamlcc/runtime/caml/fail.h) $BOOTDIR/include
cp -vf $(rlocation ocamlcc/runtime/caml/jumptbl.h) $BOOTDIR/include
cp -vf $(rlocation ocamlcc/runtime/caml/opnames.h) $BOOTDIR/include
cp -vf $(rlocation ocamlcc/runtime/caml/s.h) $BOOTDIR/include

cp -vf $(rlocation ocamlcc/stdlib/stdlib.ml) $BOOTDIR/src
cp -vf $(rlocation ocamlcc/stdlib/stdlib.mli) $BOOTDIR/src

echo "Setting permissions"

chmod -vf ug=+rx-w,o=-rwx $BOOTDIR/bin/*

echo "Setup completed."

# chmod -f ug=+r-xw,o=-rwx $BOOTDIR/bin/*.byte
# chmod ug=+r-wx,o=-rwx $BOOTDIR/lib/*
