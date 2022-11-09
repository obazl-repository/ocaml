load("//bzl/rules/common:lexer_intf.bzl", "lexer_attrs")
load("//bzl/rules/common:lexer_impl.bzl", "impl_lexer")

#################
boot_lexer = rule(
    implementation = impl_lexer,
    doc = """Generates an OCaml source file from an ocamllex source file.
    """,
    attrs = dict(
        lexer_attrs(),
        _rule = attr.string( default = "ocaml_lex" )
    ),
    executable = False,
    toolchains = ["//toolchain/type:bootstrap"]
)
