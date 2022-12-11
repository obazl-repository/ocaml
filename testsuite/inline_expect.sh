#!/bin/sh

# bazel run testsuite/tools:inline_expect --config=ocamlc.byte -- \
# bazel-bin/testsuite/tools/_dev_ocamlc.opt/inline_expect.opt \

.baseline/bin/ocamlrun \
    bazel-bin/testsuite/tools/_dev_ocamlopt.byte/inline_expect.byte \
    -strict-sequence \
    -strict-formats \
    -absname \
    -nocwd \
    -nostdlib \
    -I $PWD/bazel-bin/stdlib/_dev_ocamlopt.byte \
    $PWD/$1

# set -x

diff -w \
     $1 \
     "$1.corrected"

if [ $? -eq 0 ]
then
    echo PASS
    rm "$1.corrected"
else
    echo FAIL
fi
