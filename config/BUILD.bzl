## Makefile.config:
TARGET = "x86_64-apple-darwin20.6.0"  ## FIXME
HOST   = "x86_64-apple-darwin20.6.0"    ## FIXME

ROOTDIR = "/Users/gar/ocaml/ocaml" ## FIXME

## FIXME: convert to select constraints
ARCH       = "amd64"
ARCH64     = True
ENDIANNESS = "le"
MODEL      = "default"
SYSTEM     = "macosx"

### Where to install the standard library
# LIBDIR=${exec_prefix}/lib/ocaml
EXEC_PREFIX = "/usr/local"            ## FIXME
LIBDIR = EXEC_PREFIX + "/lib/ocaml"

### Where to install the stub code for the standard library
# STUBLIBDIR=${exec_prefix}/lib/ocaml/stublibs

EMPTY = []

################################################################
OC_CFLAGS = [
    "-O2", "-fno-strict-aliasing",
    "-fwrapv", "-pthread",
    "-Wall", "-Wdeclaration-after-statement", "-Werror",
    "-fno-common"
]

CFLAGS = []

OC_CPPFLAGS = []
OC_CPPDEFINES = [
    "_FILE_OFFSET_BITS=64", "CAML_NAME_SPACE"
] + select({
    # "//config/host:win32": ["CAMLDLLIMPORT"]
    "//conditions:default": []
})

CPPFLAGS = []

OC_DEBUG_CPPFLAGS = []
OC_INSTR_CPPFLAGS = []
OC_NATIVE_CPPFLAGS = []
OC_NATIVE_CPPDEFINES = [
    "NATIVE_CODE", "TARGET_"+ ARCH, "SYS_" + SYSTEM
] + select({
    "//config/host:linux": ["MODEL_" + MODEL],
    "//config/host:macos": ["MODEL_" + MODEL],
    "//conditions:default": []
})

OC_LDFLAGS = []
LDFLAGS    = []

OCAMLC_CFLAGS = [
    "-O2", "-fno-strict-aliasing", "-fwrapv", "-pthread"
] + CFLAGS

OUTPUTEXE = ["-o"] + EMPTY

SHAREDLIB_CFLAGS = []
