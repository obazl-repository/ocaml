# ################################################################
# ## llvm

# ## to use the llvm toolchain (https://github.com/grailbio/bazel-toolchain):
# BAZEL_TOOLCHAIN_TAG = "0.7.2"
# BAZEL_TOOLCHAIN_SHA = "f7aa8e59c9d3cafde6edb372d9bd25fb4ee7293ab20b916d867cd0baaa642529"

# http_archive(
#     name = "com_grail_bazel_toolchain",
#     sha256 = BAZEL_TOOLCHAIN_SHA,
#     strip_prefix = "bazel-toolchain-{tag}".format(tag = BAZEL_TOOLCHAIN_TAG),
#     canonical_id = BAZEL_TOOLCHAIN_TAG,
#     url = "https://github.com/grailbio/bazel-toolchain/archive/{tag}.tar.gz".format(tag = BAZEL_TOOLCHAIN_TAG),
# )
# load("@com_grail_bazel_toolchain//toolchain:deps.bzl",
#      "bazel_toolchain_dependencies")
# bazel_toolchain_dependencies()
# load("@com_grail_bazel_toolchain//toolchain:rules.bzl", "llvm_toolchain")
# llvm_toolchain(name = "llvm_toolchain", llvm_version = "14.0.0")
# load("@llvm_toolchain//:toolchains.bzl", "llvm_register_toolchains")
# llvm_register_toolchains()

# ## end llvm ##

################################################################
## zig
## https://sr.ht/~motiejus/bazel-zig-cc/

BAZEL_ZIG_CC_VERSION = "v0.9.2"
SHA256 = "73afa7e1af49e3dbfa1bae9362438cdc51cb177c359a6041a7a403011179d0b5"

# not yet:
BAZEL_ZIG_CC_VERSION = "v1.0.0-rc4"
SHA256 = "af784b604c08f385358113dc41e22736369a8ad09951fecf31dd13c35f4aaa62"

http_archive(
    name = "bazel-zig-cc",
    sha256 = SHA256,
    strip_prefix = "bazel-zig-cc-{}".format(BAZEL_ZIG_CC_VERSION),
    urls = ["https://git.sr.ht/~motiejus/bazel-zig-cc/archive/{}.tar.gz".format(BAZEL_ZIG_CC_VERSION)],
)

load("@bazel-zig-cc//toolchain:defs.bzl", zig_toolchains = "toolchains")

# version, url_formats and host_platform_sha256 are optional, but highly
# recommended. Zig SDK is by default downloaded from dl.jakstys.lt, which is a
# tiny server in the closet of Yours Truly.
zig_toolchains(
    # version = "<...>",
    # url_formats = [
    #     "https://example.org/zig/zig-{host_platform}-{version}.{_ext}",
    # ],
    # host_platform_sha256 = { ... },
)

register_toolchains(
    ## enable these to always use zig, and to cross-compile
    # if no `--platform` is specified, these toolchains will be used for
    # (linux,darwin)x(amd64,arm64)
    # "@zig_sdk//toolchain:linux_amd64_gnu.2.25",
    # "@zig_sdk//toolchain:linux_arm64_gnu.2.28",
    # "@zig_sdk//toolchain:darwin_amd64",
    # "@zig_sdk//toolchain:darwin_arm64",

    # # amd64 toolchains for libc-aware platforms:
    # "@zig_sdk//libc_aware/toolchain:linux_amd64_gnu.2.19",
    # "@zig_sdk//libc_aware/toolchain:linux_amd64_gnu.2.28",
    # "@zig_sdk//libc_aware/toolchain:linux_amd64_gnu.2.31",
    # "@zig_sdk//libc_aware/toolchain:linux_amd64_musl",

    # # arm64 toolchains for libc-aware platforms:
    # "@zig_sdk//libc_aware/toolchain:linux_arm64_gnu.2.28",
    # "@zig_sdk//libc_aware/toolchain:linux_arm64_musl",
)

#### end zig ####