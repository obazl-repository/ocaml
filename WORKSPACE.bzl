load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _ocaml_xcode_impl(repo_ctx):
    result = repo_ctx.execute([repo_ctx.attr._script])

_ocaml_xcode = repository_rule(
    implementation=_ocaml_xcode_impl,
    local = True,
    attrs = {
        "_script" : attr.label(
            allow_single_file = True,
            default = "//bzl/bin:xcode.sh"
        )
    }
)

def ocaml_xcode():
    _ocaml_xcode(name = "ocaml_xcode")

###############  OBazl Deps ###############
def obazl_deps():

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    )

    # native.register_toolchains("@ocaml//toolchain/profile:default-opt")
