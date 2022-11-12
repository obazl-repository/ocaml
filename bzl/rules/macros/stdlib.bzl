load("//bzl:rules.bzl", "boot_stdlib")

load("//stdlib:BUILD.bzl", "STDLIB_MANIFEST")

# expand:
# bazel query --output=build //boot/lib:stdlib

def stdlib(stage = None,
           build_host_constraints = None,
           target_host_constraints = None,
           visibility = ["//visibility:public"]
           ):

    boot_stdlib(
        name       = "stdlib",
        stage      = stage,
        manifest   = STDLIB_MANIFEST,
        visibility = visibility
    )


