#!/bin/bash

# set -x

# Function to echo commands
exe() { echo "\$ ${@/eval/}" ; "$@" ; }

# echo "VERBOSE: $VERBOSE"
# echo "args: $@"

OCAMLRUN=$1
shift
COMPILER_PATH=$1
shift
STDLIB_RLOC=$1
shift

COMPILER=$(basename $COMPILER_PATH)

# ROOTPATH=$1
# shift

# echo "COMPILER_PATH: $COMPILER_PATH"
# echo "ROOTPATH: $ROOTPATH"

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
echo "`cat ${RUNFILES_MANIFEST_FILE}`"

# OCAMLRUN=""
RUNTIMEDIR=""
CAMLHEADERS=""

WD=_boot

echo "STDLIB_RLOC: $STDLIB_RLOC"
STDLIBDIR=$(dirname $(rlocation $STDLIB_RLOC))

if [ $COMPILER = "ocamlc.byte" ]
then
    # OCAMLRUN=runtime/ocamlrun
    # COMPILER=$BINDIR/ocamlc.byte
    CAMLHEADERS="-I `dirname $(rlocation ocamlcc/config/camlheaders/camlheader)`"
    # STDLIBDIR=`dirname $(rlocation ocamlcc/stdlib/${WD}/stdlib.cma)`

elif [ $COMPILER = "ocamlopt.byte" ]
then
    # OCAMLRUN=runtime/ocamlrun
    # COMPILER=bin/_boot/ocamlopt.byte
    RUNTIMEDIR=$(dirname $(rlocation ocamlcc/runtime/libasmrun.a))
    # STDLIBDIR=$(dirname $(rlocation ocamlcc/stdlib/${WD}/stdlib.cmxa))

elif [ $COMPILER = "ocamlopt.opt" ]
then
    COMPILER=bin/_boot/ocamlopt.opt
    RUNTIMEDIR=`dirname $(rlocation ocamlcc/runtime/libasmrun.a)`
    # STDLIBDIR=`dirname $(rlocation ocamlcc/stdlib/${WD}/stdlib.cmxa)`

elif [ $COMPILER = "ocamlc.opt" ]
then
    COMPILER=bin/_boot/ocamlc.opt
    RUNTIMEDIR=`dirname $(rlocation ocamlcc/runtime/libcamlrun.a)`
    CAMLHEADERS="-I `dirname $(rlocation ocamlcc/config/camlheaders/camlheader)`"
    # STDLIBDIR=`dirname $(rlocation ocamlcc/stdlib/${WD}/stdlib.cma)`
else
    echo "BAD COMPILER ARG: $COMPILER"
fi

CMD="$OCAMLRUN $COMPILER_PATH -nostdlib -I $STDLIBDIR $CAMLHEADERS -I $RUNTIMEDIR $@"

if [ $VERBOSE = "true" ]
then
    echo "CWD: $PWD"
    exe eval $CMD
else
    $CMD
fi
