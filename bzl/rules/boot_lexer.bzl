load("//bzl/rules/common:lexer_intf.bzl", "lexer_attrs")
load("//bzl/rules/common:lexer_impl.bzl", "impl_lexer")

#################
boot_lexer = rule(
    implementation = impl_lexer,
    doc = "Generates an OCaml source file from an ocamllex source file.",
    exec_groups = {
        "boot": exec_group(
            exec_compatible_with = [
                "//platforms/ocaml/executor:vm?",
                "//platforms/ocaml/emitter:vm?"
            ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        "baseline": exec_group(
            exec_compatible_with = [
                "//platforms/ocaml/executor:vm?",
                "//platforms/ocaml/emitter:vm?"
            ],
            toolchains = ["//boot/toolchain/type:baseline"],
        ),
    },

    attrs = dict(
        lexer_attrs(),
        _rule = attr.string( default = "ocaml_lex" )
    ),
    executable = False,
)
