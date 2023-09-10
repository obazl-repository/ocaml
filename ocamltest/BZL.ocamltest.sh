#!/bin/sh

# We cannot run ocamltest directly; it contains hardcoded paths that
# do not work under Bazel. To make it work we need to edit:
#  ocaml_directories.ml
#  ocaml_files.ml
#  ocaml_flags.ml

#  vm:  "bazel build ocamltest --config=ocamlc.opt"
#  sys: "bazel build ocamltest --config=ocamlopt.opt"

set -x

WORKDIR="_dev_boot"

bazel-bin/ocamltest/${WORKDIR}/ocamltest.byte \
     $PWD/$1



# PGM=ocamlc.byte
# WORKDIR="_dev_ocamlc.byte"

# PGM=ocamlc.opt
# WORKDIR="_dev_ocamlc.opt"

# .baseline/bin/ocamlrun \
#     .baseline/bin/${PGM} \
#     -nostdlib -I $PWD/bazel-bin/stdlib/${WORKDIR} \
#     -I $PWD/bazel-bin/config/camlheaders \
#     -o $PWD/tmp/arrays.byte \
#     $1

# # set -x

# diff -w \
#      $1 \
#      "$1.corrected"

# if [ $? -eq 0 ]
# then
#     echo PASS
#     # unless -k
#     # rm "$1.corrected"
# else
#     echo FAIL
# fi
