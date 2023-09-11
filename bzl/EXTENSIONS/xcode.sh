#!/bin/sh

DEVELOPER_DIR="$(xcode-select -p)"

## FIXME: also support iphoneos sdk?
SDKROOT="$(xcrun --show-sdk-path)"
## outputs path to MacOSX.sdk, which is the current sdk
## with  MacOSX13.3.sdk -> MacOSX.sdk,  MacOSX13.sdk -> MacOSX.sdk
# $(xcrun --sdk macosx --show-sdk-path) emits path to MacOSX13.3.sdk

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
