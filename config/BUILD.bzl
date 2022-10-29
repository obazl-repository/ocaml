## This Bazel extension file consolidates commonly used variables like
## `OC_CFLAGS` etc.  To be loaded by BUILD.bazel files.

################################################################
## Platform configuration
## For now we just hardcode the platform stuff. For a real
## implementation, we could use the --stamp,
## --workspace_status_command technique to run some kind of
## configuration shell script to obtain ARCH, etc. See .bazelrc for an
## example, where we use the technique to parameterize the camlheader
## files.

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

## root Makefile
# ROOTDIR = .
ROOTDIR = "/Users/gar/ocaml/ocaml" ## FIXME

# NOTE: it is important that OCAMLLEX is defined *before* Makefile.common
# gets included, so that its definition here takes precedence
# over the one there.
# OCAMLLEX ?= $(BOOT_OCAMLLEX)
# include Makefile.common

################  BOOTSTRAP TOOLS  ################
# BOOT_OCAMLC is defined in //toolchain/type:bootstrap as tc.ocamlc => //boot:ocamlc
# OCAMLRUN is defined in //toolchain/type:bootstrap as tc.ocamlrun => //runtime:ocamlrun
# OCAMLRUN ?= $(ROOTDIR)/boot/ocamlrun$(EXE)
# NEW_OCAMLRUN ?= $(ROOTDIR)/runtime/ocamlrun$(EXE)

BOOT_OCAMLRUN = "//boot:ocamlrun"
RUNTIME_OCAMLRUN = "//runtime:ocamlrun"


# Use boot/ocamlc.opt if available
# ifeq "$(TEST_BOOT_OCAMLC_OPT)" "0"
#   BOOT_OCAMLC = $(ROOTDIR)/boot/ocamlc.opt
# else
#   BOOT_OCAMLC = $(OCAMLRUN) $(ROOTDIR)/boot/ocamlc
# endif

## Makefile.common:
# TEST_BOOT_OCAMLC_OPT = $(shell \
#   test $(ROOTDIR)/boot/ocamlc.opt -nt $(ROOTDIR)/boot/ocamlc; \
#   echo $$?)
# # Use boot/ocamlc.opt if available
# ifeq "$(TEST_BOOT_OCAMLC_OPT)" "0"
#   BOOT_OCAMLC = $(ROOTDIR)/boot/ocamlc.opt
# else
#   BOOT_OCAMLC = $(OCAMLRUN) $(ROOTDIR)/boot/ocamlc
# endif

## stdlib/Makefile:
# COMPILER=$(ROOTDIR)/ocamlc$(EXE)
# CAMLC=$(OCAMLRUN) $(COMPILER)

# BOOT_OCAMLLEX ?= $(OCAMLRUN) $(ROOTDIR)/boot/ocamllex
# use rule: bootstrap_ocamllex( )

# CAMLC=$(BOOT_OCAMLC) -g -nostdlib -I boot -use-prims runtime/primitives

## root Makefile.best_binaries
# choose_best = $(strip $(if ...
# BEST_OCAMLC := $(call choose_best,ocamlc)
# BEST_OCAMLOPT := $(call choose_best,ocamlopt)
# BEST_OCAMLLEX := $(call choose_best,lex/ocamllex)
## e.g. chooses either native $(ROOTDIR)/ocamlc.opt
## or bytecode $(OCAMLRUN) $(ROOTDIR)/$1$(EXE)
## so this is handled by toolchain:bootstrap

## root Makefile
# INCLUDES=-I utils -I parsing -I typing -I bytecomp -I file_formats \
#         -I lambda -I middle_end -I middle_end/closure \
#         -I middle_end/flambda -I middle_end/flambda/base_types \
#         -I asmcomp \
#         -I driver -I toplevel

# OCaml build flags defined below, after the cc flags

################################################################
################ C BUILD FLAGS & DEFINES ################
CC = "gcc"

EMPTY = ""

#### CPPFLAGS & DEFINES ####
CPPFLAGS = []
## Makefile.config
#OC_CPPFLAGS= -D_FILE_OFFSET_BITS=64 -DCAML_NAME_SPACE
## ocamltest/Makefile:
# OC_CPPFLAGS += -I$(ROOTDIR)/runtime -DCAML_INTERNALS
## stdlib/Makefile:
# OC_CPPFLAGS += -I$(ROOTDIR)/runtime
#  OC_CPPFLAGS += -DRUNTIME_NAME='"$(HEADER_PATH)ocamlrun$(subst .,,$*)"'
## yacc/Makefile
# OC_CPPFLAGS += -I$(ROOTDIR)/runtime


## runtime/Makefile:
# OC_NATIVE_CPPFLAGS = -DNATIVE_CODE -DTARGET_$(ARCH)
# OC_NATIVE_CPPFLAGS += -DMODEL_$(MODEL)
# OC_NATIVE_CPPFLAGS += -DSYS_$(SYSTEM)
# OC_DEBUG_CPPFLAGS=-DDEBUG
# OC_INSTR_CPPFLAGS=-DCAML_INSTR
# OC_CPPFLAGS += -DCAMLDLLIMPORT=
# %.bd.$(O): OC_CPPFLAGS += $(OC_DEBUG_CPPFLAGS)
# %.bd.$(D): OC_CPPFLAGS += $(OC_DEBUG_CPPFLAGS)
# %.bi.$(O): OC_CPPFLAGS += $(OC_INSTR_CPPFLAGS)
# %.bi.$(D): OC_CPPFLAGS += $(OC_INSTR_CPPFLAGS)
# %.n.$(O): OC_CPPFLAGS += $(OC_NATIVE_CPPFLAGS)
# %.n.$(D): OC_CPPFLAGS += $(OC_NATIVE_CPPFLAGS)
# %.nd.$(O): OC_CPPFLAGS += $(OC_NATIVE_CPPFLAGS) $(OC_DEBUG_CPPFLAGS)
# %.nd.$(D): OC_CPPFLAGS += $(OC_NATIVE_CPPFLAGS) $(OC_DEBUG_CPPFLAGS)
# %.ni.$(O): OC_CPPFLAGS += $(OC_NATIVE_CPPFLAGS) $(OC_INSTR_CPPFLAGS)
# %.ni.$(D): OC_CPPFLAGS += $(OC_NATIVE_CPPFLAGS) $(OC_INSTR_CPPFLAGS)
# %.npic.$(O): OC_CPPFLAGS += $(OC_NATIVE_CPPFLAGS)
# %.npic.$(D): OC_CPPFLAGS += $(OC_NATIVE_CPPFLAGS)
# $(UNIX_OR_WIN32)_non_shared.%.$(O): OC_CPPFLAGS += -DBUILDING_LIBCAMLRUNS

## Makefile.config
# OCAMLC_CPPFLAGS= -D_FILE_OFFSET_BITS=64 $(CPPFLAGS)
# OCAMLOPT_CPPFLAGS= -D_FILE_OFFSET_BITS=64 $(CPPFLAGS)

## stdlib/Makefile:
# OC_CPPFLAGS += -I$(ROOTDIR)/runtime
# OC_CPPFLAGS += -DRUNTIME_NAME='"$(HEADER_PATH)ocamlrun$(subst .,,$*)"'
## ocamltest/Makefile:
# OC_CPPFLAGS += -I$(ROOTDIR)/runtime -DCAML_INTERNALS

## otherlibs/Makefile.otherlibs.common:
# OC_CPPFLAGS += -I$(ROOTDIR)/runtime $(EXTRACPPFLAGS)
# EXTRACPPFLAGS ?=
## otherlibs/win32unix/Makefile:
# EXTRACPPFLAGS=-I../unix
## otherlibs/systhreads/Makefile:
# OC_CPPFLAGS += -I$(ROOTDIR)/runtime
# NATIVE_CPPFLAGS = -DNATIVE_CODE -DTARGET_$(ARCH) -DMODEL_$(MODEL) -DSYS_$(SYSTEM)
# st_stubs.n.$(O): OC_CPPFLAGS += $(NATIVE_CPPFLAGS)
# %.n.$(O): OC_CPPFLAGS += $(NATIVE_CPPFLAGS)
# %.n.$(D): OC_CPPFLAGS += $(NATIVE_CPPFLAGS)

OC_CPPFLAGS = []

OC_CPPDEFINES = [
    "_FILE_OFFSET_BITS=64", "CAML_NAME_SPACE"
## ] # + select({
 #    "//config/host:linux": [],
 #    "//config/host:macos": [],
 #    # "//config/host:win32": ["CAMLDLLIMPORT"]
 #    "//conditions:default": []
] + select({
    #FIXME: debug controlled by build target, not flag?
        "//config:debug_enabled": ["DEBUG"], # runtime/Makefile
        "//conditions:default": []
}) + select({
    #FIXME: instrumented controlled by build target or flag?
        "//config:instrumented": ["CAML_INSTR"],
        "//conditions:default": []
# }) + select({
#         "//config:pic": SHAREDLIB_DEFINES,
#         "//conditions:default": []
    # }) + select({
    #     "//config/mode:native": OC_NATIVE_CPPFLAGS,
    #     "//conditions:default": []
})

OC_DEBUG_CPPDEFINES = ["DEBUG"]
OC_INSTR_CPPDEFINES = ["CAML_INSTR"]

## Makefile.config
OCAMLC_CPPFLAGS = ["-D_FILE_OFFSET_BITS=64"] #  + CPPFLAGS
OCAMLC_CPPDEFINES = ["_FILE_OFFSET_BITS=64"]

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

#### CFLAGS & DEFINES ####
CFLAGS = []
OC_CFLAGS = [
    "-O2", "-fno-strict-aliasing",
    "-fwrapv", "-pthread",
    "-Wall", "-Wdeclaration-after-statement", "-Werror",
    "-fno-common"
]

OCAMLC_CFLAGS = [
    "-O2", "-fno-strict-aliasing", "-fwrapv", "-pthread"
]

#### LDFLAGS ####
LDFLAGS = ["-Wl,-no_compact_unwind"]
# LDFLAGS = select({
#     "//config/host:macos": ["-Wl,-no_compact_unwind"],
#     "//conditions:default": []
# })

OC_LDFLAGS = []

## Makefile.config
# NATIVECCLIBS= -lm
NATIVECCLIBS = ["-lm"]

## Makefile.config
# BYTECCLIBS used to build runtime/ocamlrun
BYTECCLIBS = ["-lm", "-lpthread"]

################################################################
################  OTHER TOOLS ################
## Makefile.config
# RANLIBCMD=ranlib
RANLIBCMD = "ranlib"

################
OUTPUTEXE = ["-o"]

## see LDFLAGS:
## ROOT_MKEXE_FLAGS = ["-Wl,-no_compact_unwind"]

## Makefile.config:
# MKEXE_USING_COMPILER=$(CC) $(OC_CFLAGS) $(CFLAGS) $(OC_LDFLAGS) $(LDFLAGS) \
#     $(OUTPUTEXE)$(1) $(2)

################################################################
################  OCAML BUILD FLAGS  ################
## root Makefile:
# CAMLC=$(BOOT_OCAMLC) -g -nostdlib -I boot -use-prims runtime/primitives
# CAMLOPT=$(OCAMLRUN) ./ocamlopt$(EXE) -g -nostdlib -I stdlib -I otherlibs/dynlink

## tools/Makefile:
# CAMLC = $(BOOT_OCAMLC) -g -nostdlib -I $(ROOTDIR)/boot \
#         -use-prims $(ROOTDIR)/runtime/primitives -I $(ROOTDIR)
# CAMLOPT = $(OCAMLRUN) $(ROOTDIR)/ocamlopt$(EXE) \
#   -g -nostdlib -I $(ROOTDIR)/stdlib
# COMPFLAGS = -absname -w +a-4-9-41-42-44-45-48-70 -strict-sequence \
# -warn-error +A -principal -safe-string -strict-formats -bin-annot $(INCLUDES)

## lex/Makefile
# CAMLC = $(BOOT_OCAMLC) -strict-sequence -nostdlib \
#         -I $(ROOTDIR)/boot -use-prims $(ROOTDIR)/runtime/primitives
# CAMLOPT = $(OCAMLRUN) $(ROOTDIR)/ocamlopt$(EXE) -nostdlib -I $(ROOTDIR)/stdlib


## NB: -use-prims implemented by rules, using 'primitives' attr

USE_PRIMS = ["-use-prims", "runtime/primitives"]
## NB: rules must add attr: data = ["//runtime:primitives"],
PRIMITIVES = "//runtime:primitives"
DATA_PRIMS = [PRIMITIVES]

## CAMLC - bytecode
## CAMLOPT - native

# CAMLC=$(BOOT_OCAMLC) -g -nostdlib -I boot
ROOT_CAMLC_OPTS = ["-nostdlib"]
# for some targets: -use-prims runtime/primitives
#     for them, pass 'primitives = "//runtime/primitives"'

OTHERLIBS_CAMLC_OPTS = ROOT_CAMLC_OPTS
TOOLS_CAMLC_OPTS = ROOT_CAMLC_OPTS

################
ROOT_CAMLOPT_OPTS = [
    ## "-g",
    "-nostdlib",
    "-I", "stdlib",
    "-I", "otherlibs/dynlink"
]

################
## stdlib/Makefile:
# COMPFLAGS=-strict-sequence -absname -w +a-4-9-41-42-44-45-48-70 \
#           -g -warn-error +A -bin-annot -nostdlib -principal \
#           -safe-string -strict-formats


ROOT_COMPFLAGS = [
    "-strict-sequence", "-principal", "-absname",
    "-w", "+a-4-9-40-41-42-44-45-48-66-70",
    "-warn-error", "+A",
    "-bin-annot",
    "-safe-string", "-strict-formats"
]

## otherlibs/Makefile.otherlibs.common:
# COMPFLAGS=-absname -w +a-4-9-41-42-44-45-48 -warn-error +A -bin-annot -g \
#           -safe-string -strict-sequence -strict-formats $(EXTRACAMLFLAGS)

## otherlibs/dynlink/Makefile:
# # COMPFLAGS should be in sync with the toplevel Makefile's COMPFLAGS.
# COMPFLAGS=-strict-sequence -principal -absname \
#           -w +a-4-9-40-41-42-44-45-48-66-70 \
#           -warn-error +A \
#           -bin-annot -safe-string -strict-formats

## otherlibs/systhreads/Makefile:
# COMPFLAGS=-w +33..39 -warn-error +A -g -bin-annot -safe-string


OTHERLIBS_COMPFLAGS = [
    "-absname",
    "-w", "+a-4-9-41-42-44-45-48",
    "-warn-error", "+A",
    "-bin-annot",
    # "-g",
    "-safe-string", "-strict-sequence", "-strict-formats"
    ## $(EXTRACAMLFLAGS)
]

TOOLS_COMPFLAGS = [  # tools/Makefile
# COMPFLAGS = -absname -w +a-4-9-41-42-44-45-48-70 -strict-sequence \
# -warn-error +A -principal -safe-string -strict-formats -bin-annot $(INCLUDES)
    "-absname",
    "-w", "+a-4-9-41-42-44-45-48-70",
    "-strict-sequence",
    "-warn-error", "+A",
    "-principal",
    "-safe-string", "-strict-formats",
    "-bin-annot" ## $(INCLUDES)
]

## TODO: convert INCLUDES here to deps

## root Makefile:
# %.cmo: %.ml
# 	$(CAMLC) $(COMPFLAGS) -c $< -I $(@D)
ROOT_MODULE_OPTS = ROOT_CAMLC_OPTS + ROOT_COMPFLAGS

# %.cmi: %.mli
# 	$(CAMLC) $(COMPFLAGS) -c $<
ROOT_SIG_OPTS = ROOT_MODULE_OPTS

OTHERLIBS_MODULE_OPTS = OTHERLIBS_CAMLC_OPTS + OTHERLIBS_COMPFLAGS
OTHERLIBS_SIG_OPTS    = OTHERLIBS_MODULE_OPTS
OTHERLIBS_ARCHIVE_OPTS = ["-linkall"]

TOOLS_MODULE_OPTS = TOOLS_CAMLC_OPTS + TOOLS_COMPFLAGS
TOOLS_SIG_OPTS = TOOLS_MODULE_OPTS

# %.cmx: %.ml
# 	$(CAMLOPT) $(COMPFLAGS) $(OPTCOMPFLAGS) -c $< -I $(@D)

## tools/Makefile, CAMLC == :
# %.cmo: %.ml
# 	$(CAMLC) -c $(COMPFLAGS) - $<
# %.cmi: %.mli
# 	$(CAMLC) -c $(COMPFLAGS) - $<
# %.cmx: %.ml
# 	$(CAMLOPT) $(COMPFLAGS) -c - $<




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
################  COMMANDS  ################
## Makefile.config:
# MKEXE=$(CC) $(OC_CFLAGS) $(CFLAGS) $(OC_LDFLAGS) $(LDFLAGS) -Wl,-no_compact_unwind
## Do not edit these MK vars, they are passed to preprocessors.
## (adding spaces, to match what the makefile generates:)
MKEXE = [CC] + OC_CFLAGS + CFLAGS + OC_LDFLAGS + ["  "] + LDFLAGS

## Makefile.config:
MKDLL = "gcc -shared                    -flat_namespace -undefined suppress -Wl,-no_compact_unwind                    "  #  + " ".join(LDFLAGS)

MKMAINDLL="gcc -shared                    -flat_namespace -undefined suppress -Wl,-no_compact_unwind                    " # + " ".join(LDFLAGS)

## for exe targets using MKEXE:
MKEXE_FLAGS = OC_CFLAGS + CFLAGS + OC_LDFLAGS + ["  "] + LDFLAGS

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
