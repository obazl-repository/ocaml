load("//bzl/attrs:lexer_attrs.bzl", "lexer_attrs")
load("//bzl/actions:lexer_impl.bzl", "lexer_impl")

#################
boot_lexer = rule(
    implementation = lexer_impl,
    doc = "Generates an OCaml source file from an ocamllex source file.",
    exec_groups = {
        "boot": exec_group(
            # exec_compatible_with = [
            #     "//platform/constraints/ocaml/executor:vm?",
            #     "//platform/constraints/ocaml/emitter:vm"
            # ],
            toolchains = ["//boot/toolchain/type:boot"],
        ),
        # "baseline": exec_group(
        #     exec_compatible_with = [
        #         "//platform/constraints/ocaml/executor:vm?",
        #         "//platform/constraints/ocaml/emitter:vm"
        #     ],
        #     toolchains = ["//boot/toolchain/type:baseline"],
        # ),
    },

    attrs = dict(
        lexer_attrs(),
        _rule = attr.string( default = "ocaml_lex" )
    ),
    executable = False,
)
