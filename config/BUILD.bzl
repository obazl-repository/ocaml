load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

################################################################
def _target_executor_constraint_impl(ctx):
    return BuildSettingInfo( value = ctx.attr.constraint )

target_executor_constraint = rule(
    implementation = _target_executor_constraint_impl,
    build_setting = config.string(flag = False),
    attrs = dict( constraint = attr.string())
)

################################################################
def _target_runtime_constraint_impl(ctx):
    return BuildSettingInfo( value = ctx.attr.constraint )

target_runtime_constraint = rule(
    implementation = _target_runtime_constraint_impl,
    build_setting = config.string(flag = False),
    attrs = dict( constraint = attr.string())
)

################################################################
def _executor_impl(ctx):
    return BuildSettingInfo( value = ctx.attr.executor )

executor_setting = rule(
    implementation = _executor_impl,
    build_setting = config.string(flag = False),
    attrs = dict(
        executor = attr.string()
    )
)

################################################################
def _emitter_impl(ctx):
    return BuildSettingInfo( value = ctx.attr.emitter )

emitter_setting = rule(
    implementation = _emitter_impl,
    build_setting = config.string(flag = False),
    attrs = dict(
        emitter = attr.string()
    )
)
