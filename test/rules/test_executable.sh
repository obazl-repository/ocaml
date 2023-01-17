#!/bin/bash

## NB: /bin/sh won't work, sorry

# set -x

# Function to echo commands
exe() { echo "\$ ${@/eval/}" ; "$@" ; }

# VERBOSE=

# echo "VERBOSE: $VERBOSE"
# echo "args: $@"

OCAMLRUN=$1
shift
TESTEXE_PATH=$1
shift
# STDLIB_RLOC=$1
# shift

TESTEXE="$(basename $TESTEXE_PATH)"

# echo "TESTEXE: $TESTEXE"

# ROOTPATH=$1
# shift

# echo "TESTEXE_PATH: $TESTEXE_PATH"
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

# echo "STDLIB_RLOC: $STDLIB_RLOC"
# STDLIBDIR=$(dirname $(rlocation $STDLIB_RLOC))

# OCAMLRUN="$(rlocation ocamlcc/runtime/ocamlrun)"

# OCAMLRUN=runtime/ocamlrun
# TESTEXE=$BINDIR/ocamlc.byte
# CAMLHEADERS="-I `dirname $(rlocation ocamlcc/config/camlheaders/camlheader)`"
# STDLIBDIR=`dirname $(rlocation ocamlcc/stdlib/${WD}/stdlib.cma)`

# CMD="$OCAMLRUN $TESTEXE_PATH -nostdlib -I $STDLIBDIR $CAMLHEADERS -I $RUNTIMEDIR $@"

CMD="$OCAMLRUN $TESTEXE_PATH $@"

if [ $VERBOSE = "true" ]
then
    echo "CWD: $PWD"
    exe eval $CMD
else
    $CMD
fi
