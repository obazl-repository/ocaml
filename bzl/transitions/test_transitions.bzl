load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

#####################################################
def _vv_test_in_transition_impl(settings, attr):
    ## set //config/target/executor, emitter to vm

    ## FIXME: can we use two tc adapters instead of transitioning?

    return {
        "//config/target/executor": "vm",
        "//config/target/emitter" : "vm",
        "//toolchain/dev:runtime"  : "@baseline//lib:libcamlrun.a"
    }

#######################
vv_test_in_transition = transition(
    implementation = _vv_test_in_transition_impl,
    inputs = [],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain/dev:runtime"
    ]
)

#####################################################
def _ss_test_in_transition_impl(settings, attr):
    ## set //config/target/executor, emitter to vm
    return {
        "//config/target/executor": "sys",
        "//config/target/emitter" : "sys",
        "//toolchain/dev:runtime"  : "@baseline//lib:libasmrun.a"
    }

#######################
ss_test_in_transition = transition(
    implementation = _ss_test_in_transition_impl,
    inputs = [
        # "//config/target/executor",
        # "//config/target/emitter",
    ],
    outputs = [
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain/dev:runtime",
    ]
)
