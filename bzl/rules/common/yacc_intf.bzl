#################
def yacc_attrs():

    return dict(
        src = attr.label(
            doc = "A single .mly ocamlyacc source file label",
            allow_single_file = [".mly"]
        ),
        outs = attr.output_list(
            doc = """Output ml and mli files.""",
            mandatory = True
        ),
        opts = attr.string_list(
            doc = "Options"
        ),
    )
