## main dune file:
# (env
#  (dev     (flags (:standard -w +a-4-9-40-41-42-44-45-48)))
#  (release (flags (:standard -w +a-4-9-40-41-42-44-45-48))))


## Makefile
# ROOTDIR = .
ROOTDIR = "/Users/gar/ocaml/ocaml" ## FIXME

################  BOOTSTRAP TOOLS  ################
# OCAMLRUN - in bootstrap:toolchain
## Makefile.common:
# OCAMLRUN ?= $(ROOTDIR)/boot/ocamlrun$(EXE)
# NEW_OCAMLRUN ?= $(ROOTDIR)/runtime/ocamlrun$(EXE)

## OCAMLC - in bootstrap:toolchain
# Use boot/ocamlc.opt if available
# ifeq "$(TEST_BOOT_OCAMLC_OPT)" "0"
#   BOOT_OCAMLC = $(ROOTDIR)/boot/ocamlc.opt
# else
#   BOOT_OCAMLC = $(OCAMLRUN) $(ROOTDIR)/boot/ocamlc
# endif

## root Makefile:
# CAMLC=$(BOOT_OCAMLC) -g -nostdlib -I boot -use-prims runtime/primitives
# CAMLOPT=$(OCAMLRUN) ./ocamlopt$(EXE) -g -nostdlib -I stdlib -I otherlibs/dynlink

## root Makefile.best_binaries
# choose_best = $(strip $(if ...
# BEST_OCAMLC := $(call choose_best,ocamlc)
# BEST_OCAMLOPT := $(call choose_best,ocamlopt)
# BEST_OCAMLLEX := $(call choose_best,lex/ocamllex)
## e.g. chooses either native $(ROOTDIR)/ocamlc.opt
## or bytecode $(OCAMLRUN) $(ROOTDIR)/$1$(EXE)
## so this is handled by toolchain:bootstrap

#### OCAMLLEX
# NOTE: it is important that OCAMLLEX is defined *before* Makefile.common
# gets included, so that its definition here takes precedence
# over the one there.
# OCAMLLEX ?= $(BOOT_OCAMLLEX)
# include Makefile.common

# BOOT_OCAMLLEX ?= $(OCAMLRUN) $(ROOTDIR)/boot/ocamllex
# use rule: bootstrap_ocamllex( )

################ CAMLC
# CAMLC=$(BOOT_OCAMLC) -g -nostdlib -I boot -use-prims runtime/primitives

################################
## Makefile.config:
TARGET = "x86_64-apple-darwin20.6.0"  ## FIXME
HOST   = "x86_64-apple-darwin20.6.0"    ## FIXME

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

###########   CC FLAGS  #########################################
OC_CFLAGS = [
    "-O2", "-fno-strict-aliasing",
    "-fwrapv", "-pthread",
    "-Wall", "-Wdeclaration-after-statement", "-Werror",
    "-fno-common"
]

CFLAGS = []

OC_CPPFLAGS = []
# = select({
# })

SHAREDLIB_CFLAGS = []
SHAREDLIB_DEFINES = []

OC_CPPDEFINES = [
    "_FILE_OFFSET_BITS=64", "CAML_NAME_SPACE"
## ] # + select({
 #    "//config/host:linux": [],
 #    "//config/host:macos": [],
 #    # "//config/host:win32": ["CAMLDLLIMPORT"]
 #    "//conditions:default": []
] + select({
        "//config:debug": ["DEBUG"],
        "//conditions:default": []
}) + select({
        "//config:instrumented": ["CAML_INSTR"],
        "//conditions:default": []
}) + select({
        "//config:pic": SHAREDLIB_DEFINES,
        "//conditions:default": []
    # }) + select({
    #     "//config/mode:native": OC_NATIVE_CPPFLAGS,
    #     "//conditions:default": []
})

CPPFLAGS = []

# OC_DEBUG_CPPFLAGS = [] # use select on OC_CPPFLAGS
# OC_INSTR_CPPFLAGS = [] # use select on OC_CPPFLAGS

OC_NATIVE_CPPFLAGS = []
OC_NATIVE_CPPDEFINES = [
    "NATIVE_CODE", "TARGET_"+ ARCH, "SYS_" + SYSTEM
] + select({
    "//config/host:linux": ["MODEL_" + MODEL],
    "//config/host:macos": ["MODEL_" + MODEL],
    "//conditions:default": []
})

LDFLAGS = select({
    "//config/host:macos": ["-Wl,-no_compact_unwind"],
    "//conditions:default": []
})

OC_LDFLAGS = []

OCAMLC_CFLAGS = [
    "-O2", "-fno-strict-aliasing", "-fwrapv", "-pthread"
] + CFLAGS

OUTPUTEXE = ["-o"] + EMPTY

MKEXE_FLAGS = ["-Wl,-no_compact_unwind"]

BYTE_CCLIB_LDFLAGS = ["-lm", "-lpthread"]

################  OCAML FLAGS  ################
## root Makefile
# COMPFLAGS=-strict-sequence -principal -absname \
#           -w +a-4-9-40-41-42-44-45-48-66-70 \
#           -warn-error +a \
#           -bin-annot -safe-string -strict-formats $(INCLUDES)
COMPFLAGS = [
    "-strict-sequence", "-absname",
    "-w", "+a-4-9-41-42-44-45-48-70",
    "-g", "-warn-error", "+A",
    "-bin-annot",
    "-nostdlib", "-principal",
    "-safe-string", "-strict-formats"
]

# LINKFLAGS=

OPTCOMPFLAGS = []
## Makefile.common
# ifeq "$(FUNCTION_SECTIONS)" "true"  OPTCOMPFLAGS += -function-sections

## stdlib/Makefile
# ifeq "$(FLAMBDA)" "true" OPTCOMPFLAGS += -O3

## otherlibs/systhreads/Makefile
# ifeq "$(FLAMBDA)" "true" OPTCOMPFLAGS += -O3

## otherlibs/dynlink/Makefile:
# ifeq "$(FLAMBDA)" "true" OPTCOMPFLAGS += -O3
# OPTCOMPFLAGS += -I native

## otherlibs/Makefile.otherlibs.common
# ifeq "$(FLAMBDA)" "true" OPTCOMPFLAGS += -O3


# USE_RUNTIME_PRIMS = -use-prims ../runtime/primitives
# USE_STDLIB = -nostdlib -I ../stdlib


################################################################
# bootstrap:

## root Makefile
# coreall: runtime
# 	$(MAKE) ocamlc
# 	$(MAKE) ocamllex ocamltools library


#### OCAMLC executable: use rule bootstrap_executable(  )
# The bytecode compiler
# ocamlc$(EXE): compilerlibs/ocamlcommon.cma \
#               compilerlibs/ocamlbytecomp.cma $(BYTESTART)
# 	$(CAMLC) $(LINKFLAGS) -compat-32 -o $@ $^

## compilerlibs/Makefile.compilerlibs:

# compilerlibs/ocamlcommon.cma: $(COMMON_CMI) $(COMMON)
# 	$(CAMLC) -a -linkall -o $@ $(COMMON)
##  use ocaml_library on modules made by bootstrap_module

## COMMON_CMI = $(UTILS_CMI) $(PARSING_CMI) $(TYPING_CMI) $(LAMBDA_CMI) $(COMP_CMI)
## COMMON = $(UTILS) $(PARSING) $(TYPING) $(LAMBDA) $(COMP)

## these deps are built in their own subdirs: utils, parsing, etc.
