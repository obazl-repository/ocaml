load("//bzl/actions:library_impl.bzl", "library_impl")
load("//bzl/attrs:library_attrs.bzl", "library_attrs")

#####################
test_library = rule(
    implementation = library_impl,
    doc = """Aggregates a collection of modules and/or signatures.
    """,

    attrs = dict(
        library_attrs(),
        _rule = attr.string( default = "test_library" ),
    ),
    # provides = [OcamlLibraryMarker],
    executable = False,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
