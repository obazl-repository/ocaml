#!/bin/bash

# runs all boot compilers except ocamlc.boot

# Function to echo commands
exe() { echo "\$ ${@/eval/}" ; "$@" ; }

# echo "args: $@"
OCAMLC=$1
shift
STDLIB=$1
shift

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

OCAMLC=$(rlocation $OCAMLC)
OCAMLRUN=$(rlocation ocamlcc/runtime/ocamlrun)

STDLIBDIR=`dirname $(rlocation $STDLIB)`

CMD="$OCAMLRUN $OCAMLC -I $STDLIBDIR $@"

# echo "VERBOSE: $VERBOSE"

if [ $VERBOSE = "true" ]
then
    exe eval $CMD
else
    $CMD
fi
