#!/bin/sh

# bazel run testsuite/tools:inline_expect --config=ocamlc.byte -- \
# bazel-bin/testsuite/tools/_dev_ocamlc.opt/inline_expect.opt \

WORKDIR="_dev_boot"

.baseline/bin/ocamlrun \
    bazel-bin/testsuite/tools/${WORKDIR}/inline_expect.byte \
    -drawlambda \
    -dlambda \
    -strict-sequence \
    -strict-formats \
    -absname \
    -nocwd \
    -nostdlib \
    -I $PWD/bazel-bin/stdlib/${WORKDIR} \
    $PWD/$1

# set -x

diff -w \
     $1 \
     "$1.corrected"

if [ $? -eq 0 ]
then
    echo PASS
    # unless -k
    # rm "$1.corrected"
else
    echo FAIL
fi
