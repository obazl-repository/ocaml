load(":impl_executable.bzl", "impl_executable")

# load("//ocaml/_transitions:transitions.bzl", "executable_in_transition")

load(":options.bzl", "options", "options_executable")

################################
# rule_options = options("ocaml")
# rule_options.update(options_executable("ocaml"))

rule_options = options_executable("ocaml")

##################
bootstrap_test = rule(
    implementation = impl_executable,
    doc = """Bootstrap test rule.
    """,
    attrs = dict(
        rule_options,
        _rule = attr.string( default = "bootstrap_test" ),
    ),
    # cfg = executable_in_transition,
    test = True,
    toolchains = ["//toolchain/type:bootstrap"],
)
