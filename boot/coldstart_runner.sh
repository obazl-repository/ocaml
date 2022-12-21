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

# if [ ${EXECUTOR} == "vm" ]; then

#     if [ ${EMITTER} == "vm" ]; then

#         cp -vf $(rlocation ocamlcc/lex/_ocamlc.byte/ocamllex.byte) \
#            $BOOTDIR/bin/
#         cp -vf $(rlocation ocamlcc/bin/_ocamlc.byte/ocamlc.byte) \
#            $BOOTDIR/bin/

#     elif [ ${EMITTER} == "sys" ]; then

#         cp -vf $(rlocation ocamlcc/lex/_ocamlopt.byte/ocamllex.byte) \
#            $BOOTDIR/bin/
#         cp -vf $(rlocation ocamlcc/bin/_ocamlopt.byte/ocamlopt.byte) \
#            $BOOTDIR/bin/

#     else
#         echo >&2 "ERROR: unknown emitter: ${EMITTER}"
#         exit 1
#     fi

# elif [ ${EXECUTOR} == "sys" ]; then

#     ## include entire stack of compilers:
#     cp -vf $(rlocation ocamlcc/bin/_ocamlc.byte/ocamlc.byte) \
#        $BOOTDIR/bin/
#     cp -vf $(rlocation ocamlcc/bin/_ocamlopt.byte/ocamlopt.byte) \
#        $BOOTDIR/bin/

#     cp -vf $(rlocation ocamlcc/lex/_ocamlc.opt/ocamllex.opt) \
#        $BOOTDIR/bin/

#     cp -vf $(rlocation ocamlcc/bin/_ocamlopt.opt/ocamlopt.opt) \
#        $BOOTDIR/bin/

#     if [ ${EMITTER} == "vm" ]; then

#         cp -vf $(rlocation ocamlcc/bin/_ocamlc.opt/ocamlc.opt) \
#            $BOOTDIR/bin/

#     elif [ ${EMITTER} == "sys" ]; then
#         echo
#         # cp -vf $(rlocation ocamlcc/bin/_ocamlopt.opt/ocamlopt.opt) \
#         #    $BOOTDIR/bin/

#     else
#         echo >&2 "ERROR: unknown emitter: ${EMITTER}"
#         exit 1
#     fi
# else
#     echo >&2 "ERROR: unknown executor: ${EXECUTOR}"
#     exit 1
# fi

cp -f $(rlocation ocamlcc/bin/_ocamlc.byte/ocamlc.byte) $BOOTDIR/bin/
cp -f $(rlocation ocamlcc/bin/_ocamlc.opt/ocamlc.opt) $BOOTDIR/bin/
cp -f $(rlocation ocamlcc/bin/_ocamlopt.byte/ocamlopt.byte) $BOOTDIR/bin/
cp -f $(rlocation ocamlcc/bin/_ocamlopt.opt/ocamlopt.opt) $BOOTDIR/bin/

cp -f $(rlocation ocamlcc/lex/_sys/ocamllex.opt) $BOOTDIR/bin/
cp -f $(rlocation ocamlcc/lex/_vm/ocamllex.byte) $BOOTDIR/bin/

cp -f $(rlocation ocamlcc/yacc/ocamlyacc) $BOOTDIR/bin

cp -f $(rlocation ocamlcc/asmcomp/_ocamlc.byte/cvt_emit.byte) $BOOTDIR/bin
cp -f $(rlocation ocamlcc/asmcomp/_ocamlopt.opt/cvt_emit.opt) $BOOTDIR/bin

echo "Installing libs"

cp -f $(rlocation ocamlcc/runtime/libasmrun.a) $BOOTDIR/lib
cp -f $(rlocation ocamlcc/runtime/libcamlrun.a) $BOOTDIR/lib
cp -f $(rlocation ocamlcc/runtime/ocamlrun) $BOOTDIR/bin

echo "Setting permissions"

# chmod -vf ug=+rx-w,o=-rwx $BOOTDIR/bin/*
# chmod -vf ug=+r-xw,o=-rwx $BOOTDIR/bin/*.bazel
chmod -vf ug=+rx-w,o=-rwx $BOOTDIR/bin/ocamlrun
chmod -vf ug=+rx-w,o=-rwx $BOOTDIR/bin/*.opt
chmod -vf ug=+r-xw,o=-rwx $BOOTDIR/bin/*.byte
chmod -vf ugo=+r-xw $BOOTDIR/lib/*.a

echo "Coldstart completed."

# chmod -f ug=+r-xw,o=-rwx $BOOTDIR/bin/*.byte
# chmod ug=+r-wx,o=-rwx $BOOTDIR/lib/*
