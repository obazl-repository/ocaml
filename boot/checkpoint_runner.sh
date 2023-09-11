#!/bin/bash

# echo "ARGS: $@"

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

# echo "MANIFEST: ${RUNFILES_MANIFEST_FILE}"
# echo "`cat ${RUNFILES_MANIFEST_FILE}`"

# exit 0

# echo "camlheader: $(rlocation ocamlcc/config/camlheaders/camlheader)"

# set -x

# echo "PWD: $(PWD)"
# echo "BUILD_WORKSPACE_DIRECTORY: $BUILD_WORKSPACE_DIRECTORY"
# echo "BUILD_WORKING_DIRECTORY: $BUILD_WORKING_DIRECTORY"

BASELINEDIR=$BUILD_WORKSPACE_DIRECTORY/.baseline

# rm -vrf $BASELINEDIR

echo "Making .baseline directories"

mkdir -p $BASELINEDIR/bin
mkdir -p $BASELINEDIR/lib

#echo "Installing WORKSPACE and BUILD files"

#echo "workspace(name = \"baseline\")" > $BASELINEDIR/WORKSPACE.bazel
# echo "exports_files(glob([\"**\"]))"  > $BASELINEDIR/BUILD.bazel
# echo "exports_files(glob([\"**\"]))"  > $BASELINEDIR/bin/BUILD.bazel
# echo "exports_files(glob([\"**\"]))"  > $BASELINEDIR/lib/BUILD.bazel

echo "Installing programs"

if [ -z ${VERBOSE+x} ]
then
    VERBOSE=
else
    VERBOSE="-v"
fi

for arg in "$@"
do
    if [ $(basename $arg) == "runfiles.bash" ]
    then
        : # nop
    elif [ $(basename $arg) == "camlheader" ]
    then
        cp -f ${VERBOSE} $(rlocation $arg) $BASELINEDIR/lib/
    elif  [ $(basename $arg) == "camlheader_ur" ]
    then
        cp -f ${VERBOSE} $(rlocation $arg) $BASELINEDIR/lib/
    elif  [ $(basename $arg) == "libasmrun.a" ]
    then
        cp -f ${VERBOSE} $(rlocation $arg) $BASELINEDIR/lib/
    elif  [ $(basename $arg) == "libcamlrun.a" ]
    then
        cp -f ${VERBOSE} $(rlocation $arg) $BASELINEDIR/lib/
    else
        cp -f ${VERBOSE} $(rlocation $arg) $BASELINEDIR/bin/
    fi
    # echo "rloc: $(rlocation $arg)"
done

# echo "Installing stdib"

# cp -vf $(rlocation ocamlcc/bin/_ocamlc.byte/ocamlc.byte) $BASELINEDIR/bin/
# STDLIBDIR=`dirname $(rlocation ocamlcc/bin/_ocamlc.byte/ocamlc.byte)`
# STDLIBDIR="`dirname $STDLIBDIR`"
# STDLIBDIR="`dirname $STDLIBDIR`"

# cp -vf $STDLIBDIR/stdlib/_ocamlc.byte/* $BASELINEDIR/lib
# cp -vf $(rlocation ocamlcc/bin/_ocamlc.opt/ocamlc.opt) $BASELINEDIR/bin/
# cp -vf $(rlocation ocamlcc/boot/_ocamlopt.byte/ocamlopt.byte) $BASELINEDIR/bin/
# # ocamlcc/boot/_ocamlopt.byte/ocamlopt.byte
# cp -vf $(rlocation ocamlcc/boot/_ocamlopt.opt/ocamlopt.opt) $BASELINEDIR/bin/

# STDLIBDIR=`dirname $(rlocation $4)`
# STDLIBDIR="`dirname $STDLIBDIR`"
# STDLIBDIR="`dirname $STDLIBDIR`"

# cp -vf $STDLIBDIR/stdlib/_ocamlopt.opt/* $BASELINEDIR/lib

# cp -vf $(rlocation ocamlcc/lex/_ocamlopt.opt/ocamllex.opt) $BASELINEDIR/bin/
# ## ocamlcc/lex/_ocamlopt.opt/ocamllex.opt
# cp -vf $(rlocation ocamlcc/lex/_vm/ocamllex.byte) $BASELINEDIR/bin/

# cp -vf $(rlocation ocamlcc/yacc/ocamlyacc) $BASELINEDIR/bin

# cp -vf $(rlocation ocamlcc/asmcomp/_ocamlc.byte/cvt_emit.byte) $BASELINEDIR/bin
# cp -vf $(rlocation ocamlcc/asmcomp/_ocamlopt.opt/cvt_emit.byte) $BASELINEDIR/bin

# echo "Installing libs"

# cp -vf $(rlocation ocamlcc/runtime/libasmrun.a) $BASELINEDIR/lib
# cp -vf $(rlocation ocamlcc/runtime/libcamlrun.a) $BASELINEDIR/lib
# cp -vf $(rlocation ocamlcc/runtime/ocamlrun) $BASELINEDIR/bin

# cp -vf $(rlocation ocamlcc/vendor/mustach/mustach) $BASELINEDIR/bin

echo "Setting Permissions"

cd $BASELINEDIR/lib && chmod -f ${VERBOSE} ugo=+r-xw *

chmod -f ${VERBOSE} u=+rwx,go=+rx-w $BASELINEDIR/bin/*
chmod -f ${VERBOSE} u=+rw-x,go=+r-wx $BASELINEDIR/bin/*.byte
chmod -f ${VERBOSE} u=+rw,go=+r-xw $BASELINEDIR/bin/*.bazel 2>/dev/null


echo "Checkpoint completed."
