#!/bin/bash

shopt -s extglob

BOOTDIR=$BUILD_WORKSPACE_DIRECTORY/.bootstrap

rm -f -- $BOOTDIR/bin/!(BUILD.bazel|*.sh)
rm -f -- $BOOTDIR/lib/!(BUILD.bazel)
