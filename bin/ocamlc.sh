#!/bin/bash

#set -x

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

# echo "RUNFILES_DIR: ${RUNFILES_DIR}"
echo "RUNFILES_MANIFEST_FILE: ${RUNFILES_MANIFEST_FILE}"
for x in `cat ${RUNFILES_MANIFEST_FILE}`; do
    echo $x
done

if [[ -f "${RUNFILES_DIR:-/dev/null}/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
    source "${RUNFILES_DIR}/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
    source "$(grep -m1 "^bazel_tools/tools/bash/runfiles/runfiles.bash" "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
else
    echo >&2 "ERROR: cannot find @bazel_tools//tools/bash/runfiles:runfiles.bash"
    exit 1
fi
#       # --- end runfiles.bash initialization ---

STDLIB=
if [ $1 = "NOSTDLIB" ]; then
    shift
else
    STDLIB="-I `dirname $(rlocation ocaml_tools/lib/stdlib.cma)`"
fi

# echo "STDLIB: $STDLIB"

CMD="$(rlocation ocaml_tools/runtime/ocamlrun) $(rlocation ocaml_tools/bin/ocamlc.byte) $STDLIB $@"

echo "CMD: $CMD"

$CMD


