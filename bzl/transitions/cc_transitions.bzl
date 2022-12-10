
#####################################################
## reset_cc_config_transition - called only for mustache._tool
# resets to fixed config so mustache will only be built once
# applies to:
# __asm
# config_ml
# domain_state_h
# domainstate_ml
# domainstate_mli
# fail_h
# instruct_h
# jumptbl_h
# opcodes_ml
# opnames_h
# primitives_dat
# primitives_h
# prims_c
# runtimedef_ml
# stdlib_ml
# stdlib_mli

def _reset_cc_config_transition_impl(settings, attr):
    # print("reset_cc_config_transition: %s" % attr.name)
    return {
        "//command_line_option:host_compilation_mode": "opt",
        "//command_line_option:compilation_mode": "opt",

        # "//toolchain/target/executor": "boot",
        # "//toolchain/target/emitter" : "boot",

        "//config/target/executor": "boot",
        "//config/target/emitter" : "boot",

        "//toolchain:compiler" : "//boot:ocamlc.boot",
        "//toolchain:lexer"    : "//boot:ocamllex.boot",
    }

#######################
reset_cc_config_transition = transition(
    implementation = _reset_cc_config_transition_impl,
    inputs = [],
    outputs = [
        "//command_line_option:host_compilation_mode",
        "//command_line_option:compilation_mode",
        # "//toolchain/target/executor",
        # "//toolchain/target/emitter",
        "//config/target/executor",
        "//config/target/emitter",
        "//toolchain:compiler",
        "//toolchain:lexer",

    ]
)
