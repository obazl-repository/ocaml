def lexer_attrs():

    return dict(
        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath")
        # ),
        src = attr.label(
            doc = "A single .mll source file label",
            allow_single_file = [".mll"]
        ),
        vmargs = attr.string_list(
            doc = "Args to pass to ocamlrun when it runs ocamllex.",
        ),
        out = attr.output(
            doc = """Output filename.""",
            mandatory = True
        ),
        opts = attr.string_list(
            doc = "Options"
        ),
        # mode       = attr.string(
        #     default = "bytecode",
        # ),
        _rule = attr.string( default = "ocaml_lex" )
    )
