load("//bzl/actions:library_impl.bzl", "library_impl")
load("//bzl/attrs:library_attrs.bzl", "library_attrs")

#####################
boot_library = rule(
    implementation = library_impl,
    doc = """Aggregates a collection of modules and/or signatures.
An `boot_library` is a collection of modules packaged into an OBazl
target; it is not a single binary file. It is a OBazl convenience rule
that allows a target to depend on a collection of deps under a single
label, rather than having to list each individually.

Be careful not to confuse `boot_library` and `boot_archive`. The
latter generates OCaml binaries (`.cma`, `.cmxa`, '.a' archive files);
the former does not generate anything, it just passes on its
dependencies under a single label, packaged in a
[OcamlLibraryMarker](providers_ocaml.md#ocamllibraryprovider).
    """,

    attrs = dict(
        library_attrs(),
        _rule = attr.string( default = "boot_library" ),
    ),
    # provides = [OcamlLibraryMarker],
    executable = False,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
