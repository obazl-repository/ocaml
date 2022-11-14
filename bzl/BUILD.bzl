load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

EmitterInfo = provider(fields = ["emitter"])

def _impl(ctx):
    if ctx.attr.emitter in ["vm", "sys", "amd64", "arm64"]:
        return BuildSettingInfo( value = ctx.attr.emitter )
    else:
        fail("Invalid emmiter value, must be vm, sys, amd64, or arm64: %s" % ctx.attr.emitter)

emitter_setting = rule(
    implementation = _impl,
    build_setting = config.string(flag = False),
    attrs = dict(
        emitter = attr.string()
    )
)
