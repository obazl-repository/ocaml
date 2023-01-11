load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:archive_impl.bzl", "archive_impl")
load("//bzl/attrs:archive_attrs.bzl", "archive_attrs")
load("//bzl/actions:library_impl.bzl", "library_impl")
# load("//bzl/attrs:library_attrs.bzl", "library_attrs")

############################
def _test_library_impl(ctx):

    # print("lbl: %s" % ctx.label)
    # print("COMPILER LIB: %s" % ctx.attr.archive)
    # print(" hasattr: %s" % hasattr(ctx.attr, "archive"))
    # print(" local arch: %s" % ctx.attr.archive)
    # print(" global arch %s" % ctx.attr._compilerlibs_archived[BuildSettingInfo].value)

    # if (ctx.attr.archive or ctx.attr._compilerlibs_archived[BuildSettingInfo].value):
    #     return archive_impl(ctx)
    if ctx.attr.archive:
        return archive_impl(ctx)
    elif ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
        if ctx.attr.cmxa_eligible:
            return archive_impl(ctx)
        else:
            return library_impl(ctx)
    else:
        return library_impl(ctx)

#####################
test_library = rule(
    implementation = _test_library_impl,
    doc = """Aggregates a collection of modules and/or signatures.
    """,

    attrs = dict(
        archive_attrs(),
        _rule = attr.string( default = "test_library" ),
    ),
    # provides = [OcamlLibraryMarker],
    executable = False,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
