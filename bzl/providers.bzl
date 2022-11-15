################
## Bazel version 5
# BootInfo = provider(
#     doc = "foo",
#     fields = {
#         "sigs"          : "Depset of .cmi files. always added to inputs, never to cmd line.",
#         "cli_link_deps" : "Depset of cm[x]a and cm[x|o] files to be added to inputs and link cmd line (executables and archives).",
#         "afiles"        : "Depset of the .a files that go with .cmxa files",
#         "archived_cmx"  : "Depset of archived .cmx and .o files. always added to inputs, never to cmd line.",
#         "paths"         : "string depset, for efficiency",
#         # "ofiles"        :    "depset of the .o files that go with .cmx files",
#         # "archives"      :  "depset of .cmxa and .cma files",
#         # "cma"           :       "depset of .cma files",
#         # "cmxa"          :       "depset of .cmxa files",
#         # "astructs"      :  "depset of archived structs, added to link depgraph but not command line.",
#         # "cmts"          :      "depset of cmt/cmti files",
#     },
# )

################################################################
## For version 6:
def _ModuleInfo_init(*, sig = None, struct = None):
    return { "sig" : sig, "struct": struct }

ModuleInfo, _new_moduleinfo = provider(
    doc = "foo",
    fields = {
        "sig"   : "One .cmi file",
        "struct": "One .cmo or .cmx file"
    },
    init = _ModuleInfo_init
)

##########################
def _BootInfo_init(*,
                   sigs          = [],
                   cli_link_deps = [],
                   afiles        = [],
                   ofiles        = [],
                   archived_cmx  = [],
                   mli           = [],
                   paths         = [],
                   # ofiles      = [],
                   # archives    = [],
                   # astructs    = [],
                   # cmts        = [],
                        ):
    return {
        "sigs"          : sigs,
        "cli_link_deps" : cli_link_deps,
        "afiles"        : afiles,
        "ofiles"        : ofiles,
        "archived_cmx"  : archived_cmx,
        "mli"           : mli,
        "paths"         : paths,
    }

BootInfo, _new_ocamlbootinfo = provider(
    doc = "foo",
    fields = {
        "sigs"          : "Depset of .cmi files. always added to inputs, never to cmd line.",
        "cli_link_deps" : "Depset of cm[x]a and cm[x|o] files to be added to inputs and link cmd line (executables and archives).",
        "afiles"        : "Depset of the .a files that go with .cmxa files",
        "ofiles"        : "Depset of the .o files that go with .cmx files",
        "archived_cmx"  : "Depset of archived .cmx and .o files. always added to inputs, never to cmd line.",
        "mli"           : ".mli files needed for .ml compilation",
        "paths"         : "string depset, for efficiency",
        # "ofiles"        :    "depset of the .o files that go with .cmx files",
        # "archives"      :  "depset of .cmxa and .cma files",
        # "cma"           :       "depset of .cma files",
        # "cmxa"          :       "depset of .cmxa files",
        # "astructs"      :  "depset of archived structs, added to link depgraph but not command line.",
        # "cmts"          :      "depset of cmt/cmti files",
    },
    init = _BootInfo_init
)

##########################
DepsAggregator = provider(
    fields = {
        "deps"    : "struct of BootInfo providers",
        "ccinfos" : "list of CcInfo providers",
    }
)

def new_deps_aggregator():
    return DepsAggregator(
        deps = BootInfo(
            sigs          = [],
            cli_link_deps = [],
            afiles        = [],
            ofiles        = [],
            archived_cmx  = [],
            mli           = [],
            paths         = [],
            # ofiles      = [],
            # archives    = [],
            # astructs    = [], # archived cmx structs, for linking
            # cmts        = [],
        ),
        ccinfos           = []
    )

################################################################
OcamlArchiveProvider = provider(
    doc = """OCaml archive provider.

Produced only by ocaml_archive, ocaml_ns_archive, ocaml_import.  Archive files are delivered in DefaultInfo; this provider holds deps of the archive, to serve as action inputs.
""",
    fields = {
        "manifest": "Depset of direct deps, i.e. members of the archive",
        "files": "file depset of archive's deps",
        "paths": "string depset"
    }
)

# OcamlNsResolverMarker = provider(doc = "OCaml NsResolver Marker provider.")
OcamlNsResolverProvider = provider(
    doc = "OCaml NS Resolver provider.",
    fields = {
        "files"   : "Depset, instead of DefaultInfo.files",
        "paths":    "Depset of paths for -I params",
        "submodules": "String list of submodules in this ns",
        "resolver_file": "file",
        "resolver": "Name of resolver module",
        "prefixes": "List of alias prefix segs",
        "ns_name": "ns name (joined prefixes)"
    }
)

OcamlSignatureProvider = provider(
    doc = "OCaml interface provider.",
    fields = {
        # "deps": "sig deps",

        "mli": ".mli input file",
        "cmi": ".cmi output file",
        # "module_links":    "Depset of module files to be linked by executable or archive rules.",
        # "archive_links":    "Depset of archive files to be linked by executable or archive rules.",
        # "paths":    "Depset of paths for -I params",
        # "depgraph": "Depset containing transitive closure of deps",
        # "archived_modules": "Depset containing archive contents"
    }
    # fields = module_fields
    # {
    #     # "ns_module": "Name of ns module (string)",
    #     "paths"    : "Depset of search path strings",
    #     "resolvers": "Depset of resolver module names",
    #     "deps_opam" : "Depset of OPAM package names"

    #     # "payload": "An [OcamlInterfacePayload](#ocamlinterfacepayload) structure.",
    #     # "deps"   : "An [OcamlDepsetProvider](#ocamldepsetprovider)."
    # }
)

# OcamlArchiveMarker    = provider(doc = "OCaml Archive Marker provider.")
OcamlExecutableMarker = provider(doc = "OCaml Executable Marker provider.")
OcamlImportMarker    = provider(doc = "OCaml Library Marker provider.")
OcamlLibraryMarker   = provider(doc = "OCaml Library Marker provider.")
# OcamlModuleMarker    = provider(doc = "OCaml Module Marker provider.")
OcamlNsMarker        = provider(doc = "OCaml Namespace Marker provider.")
OcamlSignatureMarker = provider(doc = "OCaml Signature Marker provider.")
OcamlTestMarker      = provider(doc = "OCaml Test Marker provider.")

################################################################
################ Config Settings ################
CompilationModeSettingProvider = provider(
    doc = "Raw value of compilation_mode_flag or setting",
    fields = {
        "value": "The value of the build setting in the current configuration. " +
                 "This value may come from the command line or an upstream transition, " +
                 "or else it will be the build setting's default.",
    },
)

################
OcamlVerboseFlagProvider = provider(
    doc = "Raw value of ocaml_verbose_flag",
    fields = {
        "value": "The value of the build setting in the current configuration. " +
                 "This value may come from the command line or an upstream transition, " +
                 "or else it will be the build setting's default.",
    },
)


OcamlVmRuntimeProvider = provider(
    doc = "OCaml VM Runtime provider",
    fields = {
        "kind": "string: dynamic (default), static, or standalone"
    }
)

