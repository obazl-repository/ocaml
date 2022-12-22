#!/bin/sh

DEVELOPER_DIR="$(xcode-select -p)"
SDKROOT="$(xcrun --show-sdk-path)"

echo "DD: $DEVELOPER_DIR"
echo "SDK: $SDKROOT"

mkdir env

echo "load(\"@bazel_skylib//rules:common_settings.bzl\", \"string_setting\")" > env/BUILD.bazel

echo "" >> env/BUILD.bazel

echo "string_setting(name = \"developer_dir\"," >> env/BUILD.bazel
echo "               build_setting_default = \"$DEVELOPER_DIR\"," >> env/BUILD.bazel
echo "               visibility = [\"//visibility:public\"])" >> env/BUILD.bazel

echo "" >> env/BUILD.bazel

echo "string_setting(name = \"sdkroot\"," >> env/BUILD.bazel
echo "               build_setting_default = \"$SDKROOT\"," >> env/BUILD.bazel
echo "               visibility = [\"//visibility:public\"])" >> env/BUILD.bazel
