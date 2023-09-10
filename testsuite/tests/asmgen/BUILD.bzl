load("//bzl:rules.bzl", "cc_assemble")

#######################
## generates:
##   cc_library(name = "<name>")
##   cc_binary(name = "<name>.exe")
def genbin(name, srcs=[],
           deps=[], c_opts=[],
           textual_hdrs = [],
           defines=None):

    # print("GENBIN deps: %s" % deps)

    if defines:
        defs = ["-D" + d for d in defines]
    else:
        defs = []

    native.cc_binary(
        name = name + ".exe",
        srcs = [":" + name]
    )

    native.cc_library(
        name = name,
        srcs = [
            # "//runtime:archasm", # won't do, need entire libasmrun
            "//runtime/caml:config.h",
            "//runtime/caml:m.h",
            "//runtime/caml:s.h",
        ] + srcs + deps + select({
            "//platform/build:macos_arm64?": [
                "//testsuite/tools:asmgen_arm64"],
            # "//platform/build:macos_amd64?": [
            #     "//testsuite/tools:asmgen_amd64"],
            "//platform/build:macos_x86_64?": [
                "//testsuite/tools:asmgen_amd64"],
        }, no_match_error = "Unsupported arch"),
        textual_hdrs = textual_hdrs,
        copts = [
            "-x", "c",
            "-I", "runtime",
            "-I$(GENDIR)/runtime/caml",
        ] + c_opts + defs,
        # ],
        # linkopts = ["-lpthread"],
        deps = deps + select({
            # "//platform/build:macos_amd64?": [
            #     "//testsuite/tools:asmgen_amd64"],
            "//platform/build:macos_arm64?": [
                "//testsuite/tools:asmgen_arm64"],
        }, no_match_error = "Unsupported arch"),
        ##FIXME: adding asmrun dep causes bazel to add
        ## '[S]' to link cmd, which breaks it, no idea why
        # "//runtime:asmrun",
    )

######################
## generates:
##   genrule(name = "<name>", outs = "<stem>.s" ...)
## FIXME: rename to genasm
def codegen(name, cmm, opts=[]):
    if not cmm.endswith(".cmm"):
        fail("cmm attr value must end in .cmm")
    else:
        stem = cmm[:-4]

    outfile = stem + ".s"

    native.genrule(
        name = name,
        outs = [outfile],
        srcs = [cmm],
        tools = ["//testsuite/tools:codegen"],
        cmd   = " ".join([
            # "echo PWD: $$PWD; ",
            # "set -x;",
            "$(execpath //testsuite/tools:codegen)",
            " ".join(opts),
            "-S",
            "$(location {}); ".format(cmm),
            "cp $(rootpath {}) \"$@\" ;".format(outfile),
        ]),
    )

def codegen_test(name, cmm, opts=[]):
    codegen(name, cmm, opts)

#################################################
ASM_DEFINES = [
    "NATIVE_CODE",
    "TARGET_$(ARCH)",
    "MODEL_$(MODEL)",
    "SYS_$(SYSTEM)"
]

##################################
## asmgen_test: generate .s from .cmm, assemble it,
## link it with
#    hdrs + "//runtime/caml:s.h",
##   c_srs attrib: main.c, mainarith.c, or mainimmed.c
##   "//testsuite/tools:asmgen_[arm,amd]64"
##  and emit the result as test binary

## does NOT emit a cc_test target - only for build_test

## expands to:
##   genrule(name = "<name>",
##           tool: //testsuite/tools:codegen
##           srcs="<stem>.cmm", outs = "<stem>.s" ...)
##   cc_assemble(name = "<stem>_s", src = "<stem>.s" ...)
##        provides <stem>.o
##   genbin(name = "<stem>" ...)
##     => cc_library(name = "<stem>")
##     => cc_binary(name = "<stem>.out", srcs = ["<stem>"]...)
def asmgen_test(name, cmm,
                c_srcs = [],
                main = None,
                c_opts = [],
                codegen_opts = [],
                textual_hdrs = [],
                defines= []):

    if not cmm.endswith(".cmm"):
        fail("cmm attr value must end in .cmm")
    else:
        stem = cmm[:-4]

    asm_src = stem + ".s"
    codegen(name = stem + "_gen", cmm=cmm, opts=codegen_opts)

    asm_tgt = stem + "_s"
    cc_assemble(
        name = asm_tgt,
        src = asm_src,
        defines = ASM_DEFINES + defines,
        ## This tc provides custom MAKE vars
        toolchains = ["//profile/system/local"],
    )

    if main:
        deps = [":" + asm_tgt, main]
        print("DEPS: %s" % deps)
    else:
        deps = [stem]

    genbin(name = stem,
           srcs = c_srcs,
           deps = [asm_tgt],
           c_opts = c_opts,
           textual_hdrs = textual_hdrs,
           defines = defines)

