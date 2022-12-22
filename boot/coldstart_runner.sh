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

echo "MANIFEST: ${RUNFILES_MANIFEST_FILE}"
echo "`cat ${RUNFILES_MANIFEST_FILE}`"

# echo "camlheader: $(rlocation ocamlcc/config/camlheaders/camlheader)"

# set -x

# echo "PWD: $(PWD)"
# echo "BUILD_WORKSPACE_DIRECTORY: $BUILD_WORKSPACE_DIRECTORY"
# echo "BUILD_WORKING_DIRECTORY: $BUILD_WORKING_DIRECTORY"

BOOTDIR=$BUILD_WORKSPACE_DIRECTORY/.baseline

# rm -vrf $BOOTDIR

echo "Making .baseline directories"

mkdir -p $BOOTDIR/bin
mkdir -p $BOOTDIR/lib

echo "Installing WORKSPACE and BUILD files"

# echo "workspace(name = \"baseline\")" > $BOOTDIR/WORKSPACE.bazel
# echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/BUILD.bazel
# echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/bin/BUILD.bazel
# echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/lib/BUILD.bazel

# echo "Getting executor and emitter"

# EXECUTOR=`cat $(rlocation ocamlcc/boot/executor)`
# EMITTER=`cat $(rlocation ocamlcc/boot/emitter)`

# echo "Executor: ${EXECUTOR}"
# echo "Emitter: ${EMITTER}"

echo "Installing programs"

cp -vf $(rlocation ocamlcc/bin/_ocamlc.byte/ocamlc.byte) $BOOTDIR/bin/
STDLIBDIR=`dirname $(rlocation ocamlcc/bin/_ocamlc.byte/ocamlc.byte)`
STDLIBDIR="`dirname $STDLIBDIR`"
STDLIBDIR="`dirname $STDLIBDIR`"

cp -vf $STDLIBDIR/stdlib/_ocamlc.byte/* $BOOTDIR/lib

cp -vf $(rlocation ocamlcc/bin/_ocamlc.opt/ocamlc.opt) $BOOTDIR/bin/
cp -vf $(rlocation ocamlcc/boot/_ocamlopt.byte/ocamlopt.byte) $BOOTDIR/bin/
# ocamlcc/boot/_ocamlopt.byte/ocamlopt.byte
cp -vf $(rlocation ocamlcc/boot/_ocamlopt.opt/ocamlopt.opt) $BOOTDIR/bin/

STDLIBDIR=`dirname $(rlocation ocamlcc/boot/_ocamlopt.opt/ocamlopt.opt)`
STDLIBDIR="`dirname $STDLIBDIR`"
STDLIBDIR="`dirname $STDLIBDIR`"

cp -vf $STDLIBDIR/stdlib/_ocamlopt.opt/* $BOOTDIR/lib

cp -vf $(rlocation ocamlcc/lex/_ocamlopt.opt/ocamllex.opt) $BOOTDIR/bin/
## ocamlcc/lex/_ocamlopt.opt/ocamllex.opt
cp -vf $(rlocation ocamlcc/lex/_vm/ocamllex.byte) $BOOTDIR/bin/

cp -vf $(rlocation ocamlcc/yacc/ocamlyacc) $BOOTDIR/bin

cp -vf $(rlocation ocamlcc/asmcomp/_ocamlc.byte/cvt_emit.byte) $BOOTDIR/bin
cp -vf $(rlocation ocamlcc/asmcomp/_ocamlopt.opt/cvt_emit.opt) $BOOTDIR/bin

echo "Installing libs"

cp -vf $(rlocation ocamlcc/runtime/libasmrun.a) $BOOTDIR/lib
cp -vf $(rlocation ocamlcc/runtime/libcamlrun.a) $BOOTDIR/lib
cp -vf $(rlocation ocamlcc/runtime/ocamlrun) $BOOTDIR/bin

cp -vf $(rlocation ocamlcc/vendor/mustach/mustach) $BOOTDIR/bin

echo "Setting permissions"

# chmod -vf ug=+rx-w,o=-rwx $BOOTDIR/bin/*
# chmod -vf ug=+r-xw,o=-rwx $BOOTDIR/bin/*.bazel
chmod -vf ug=+rx-w,o=-rwx $BOOTDIR/bin/ocamlrun
chmod -vf ug=+rx-w,o=-rwx $BOOTDIR/bin/mustach
chmod -vf ug=+rx-w,o=-rwx $BOOTDIR/bin/*.opt
chmod -vf ug=+r-xw,o=-rwx $BOOTDIR/bin/*.byte
chmod -vf ugo=+r-xw $BOOTDIR/lib/*.a

echo "Coldstart completed."

# chmod -f ug=+r-xw,o=-rwx $BOOTDIR/bin/*.byte
# chmod ug=+r-wx,o=-rwx $BOOTDIR/lib/*
