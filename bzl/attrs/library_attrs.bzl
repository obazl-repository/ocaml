load("//bzl:providers.bzl",
     "CompilationModeSettingProvider",
     "ModuleInfo",
     "OcamlArchiveProvider",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlSignatureProvider")

###################
def library_attrs():

    return dict(

        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),

        _protocol = attr.label(default = "//config/build/protocol"),

        manifest = attr.label_list(
            doc = "List of elements of library, which may be compiled modules, signatures, or other libraries.",

            ## will set ns config for packed modules if 'ns' not null
            # cfg = manifest_out_transition,

            providers = [
                [OcamlArchiveProvider],
                [OcamlLibraryMarker],
                [ModuleInfo],
                [OcamlNsResolverProvider],
                # [OcamlNsMarker],
                [OcamlSignatureProvider],
            ],
        ),

        pack_ns = attr.string(
            doc = """Name(space) to use to build a packed module using -pack.
            Will be passed to submodules by a transition function, using global setting //config/pack/ns.
"""
        ),
    )
