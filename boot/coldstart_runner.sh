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

# echo "camlheader: $(rlocation ocaml_tools/config/camlheaders/camlheader)"

# set -x

echo "PWD: $(PWD)"
echo "BUILD_WORKSPACE_DIRECTORY: $BUILD_WORKSPACE_DIRECTORY"
echo "BUILD_WORKING_DIRECTORY: $BUILD_WORKING_DIRECTORY"

BOOTDIR=$BUILD_WORKSPACE_DIRECTORY/.baseline

rm -vrf $BOOTDIR

mkdir -p $BOOTDIR/bin
mkdir -p $BOOTDIR/lib

echo "workspace(name = \"baseline\")" > $BOOTDIR/WORKSPACE.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/BUILD.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/bin/BUILD.bazel
echo "exports_files(glob([\"**\"]))"  > $BOOTDIR/lib/BUILD.bazel

EXECUTOR=`cat $(rlocation ocaml_tools/boot/executor)`
EMITTER=`cat $(rlocation ocaml_tools/boot/emitter)`

echo "Executor: ${EXECUTOR}"
echo "Emitter: ${EMITTER}"

cp -f $(rlocation ocaml_tools/runtime/ocamlrun) $BOOTDIR/bin
cp -f $(rlocation ocaml_tools/runtime/libasmrun.a) $BOOTDIR/lib
cp -f $(rlocation ocaml_tools/runtime/libcamlrun.a) $BOOTDIR/lib

if [ ${EXECUTOR} == "vm" ]; then

    if [ ${EMITTER} == "vm" ]; then

        cp -f $(rlocation ocaml_tools/lex/_ocamlc.byte/ocamllex.byte) \
           $BOOTDIR/bin/
        cp -f $(rlocation ocaml_tools/bin/_ocamlc.byte/ocamlc.byte) \
           $BOOTDIR/bin/

    elif [ ${EMITTER} == "sys" ]; then

        cp -f $(rlocation ocaml_tools/lex/_ocamlopt.byte/ocamllex.byte) \
           $BOOTDIR/bin/
        cp -f $(rlocation ocaml_tools/bin/_ocamlopt.byte/ocamlopt.byte) \
           $BOOTDIR/bin/

    else
        echo >&2 "ERROR: unknown emitter: ${EMITTER}"
        exit 1
    fi

elif [ ${EXECUTOR} == "sys" ]; then

    ## include entire stack of compilers:
    cp -f $(rlocation ocaml_tools/bin/_ocamlc.byte/ocamlc.byte) \
       $BOOTDIR/bin/
    cp -f $(rlocation ocaml_tools/bin/_ocamlopt.byte/ocamlopt.byte) \
       $BOOTDIR/bin/

    cp -f $(rlocation ocaml_tools/lex/_ocamlc.opt/ocamllex.opt) \
       $BOOTDIR/bin/

    cp -f $(rlocation ocaml_tools/bin/_ocamlopt.opt/ocamlopt.opt) \
       $BOOTDIR/bin/

    if [ ${EMITTER} == "vm" ]; then

        cp -f $(rlocation ocaml_tools/bin/_ocamlc.opt/ocamlc.opt) \
           $BOOTDIR/bin/

    elif [ ${EMITTER} == "sys" ]; then
        echo
        # cp -f $(rlocation ocaml_tools/bin/_ocamlopt.opt/ocamlopt.opt) \
        #    $BOOTDIR/bin/

    else
        echo >&2 "ERROR: unknown emitter: ${EMITTER}"
        exit 1
    fi
else
    echo >&2 "ERROR: unknown executor: ${EXECUTOR}"
    exit 1
fi

cp -f $(rlocation ocaml_tools/yacc/ocamlyacc) $BOOTDIR/bin


chmod -f ug=+rx-w,o=-rwx $BOOTDIR/bin/*
chmod -f ug=+r-xw,o=-rwx $BOOTDIR/bin/*.byte
chmod -f ugo=+r-xw $BOOTDIR/lib/*.a

# chmod -f ug=+r-xw,o=-rwx $BOOTDIR/bin/*.byte
# chmod ug=+r-wx,o=-rwx $BOOTDIR/lib/*
