load("//bzl/rules/common:yacc_intf.bzl", "yacc_attrs")
load("//bzl/rules/common:yacc_impl.bzl", "impl_yacc")

#################
boot_yacc = rule(
    implementation = impl_yacc,
    doc = """Generates an OCaml source file from an ocamlyacc source file.
    """,
    attrs = dict(
        yacc_attrs(),
        _rule = attr.string( default = "ocaml_yacc" )
    ),
    executable = False,
    toolchains = ["//toolchain/type:bootstrap"]
)
