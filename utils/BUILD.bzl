load("//config:CONFIG.bzl",
     "CC",
     "CPPFLAGS",
     # "OCAMLC_CPPFLAGS",
     # "OCAMLC_CPPDEFINES",
     "CFLAGS", "OC_CFLAGS",
     # "OCAMLC_CFLAGS",
     "LDFLAGS", "OC_LDFLAGS", "BYTECCLIBS", "NATIVECCLIBS",
     ## cmds:
     # "MKEXE", "MKDLL", "MKMAINDLL", "RANLIBCMD",
     "EMPTY",
     )

## Makefile.common:
# Escape special characters in an OCaml string literal "..."
# There are two: backslash and double quote.
#OCAML_ESCAPE=$(subst ",\",$(subst \,\\,$1))
# SUBST generates the sed substitution for the variable *named* in $1
#SUBST=-e 's!%%$1%%!$(call SED_ESCAPE,$($1))!'

# SUBST_STRING does the same, for a variable that occurs between "..."
# in config.mlp.  Thus, backslashes and double quotes must be escaped.
#SUBST_STRING=-e 's!%%$1%%!$(call SED_ESCAPE,$(call OCAML_ESCAPE,$($1)))!'

## utils/Makefile:
# SUBST_QUOTE does the same as SUBST_STRING, adding OCaml quotes around
#   non-empty strings (see FLEXDLL_DIR which must empty if FLEXDLL_DIR is empty
#   but an OCaml string otherwise)
#SUBST_QUOTE2=\
#  -e 's!%%$1%%!$(if $2,$(call SED_ESCAPE,"$(call OCAML_ESCAPE,$2)"))!'
#SUBST_QUOTE=$(call SUBST_QUOTE2,$1,$($1))

# CONFIG_MAP = {
#     "%%AFL_INSTRUMENT%%" : "false",
#     "%%ARCH%%" : "amd64",
#     "%%ARCMD%%" : "ar",
#     "%%ASM%%" : "gcc -c -Wno-trigraphs",
#     "%%ASM_CFI_SUPPORTED%%" : "true",
#     "%%BYTECCLIBS%%" : "{BYTECCLIBS}".format(
#         BYTECCLIBS=" ".join(BYTECCLIBS)
#     ),
#     "%%CC%%" : "gcc",
#     "%%CCOMPTYPE%%" : "cc",
#     "%%OUTPUTOBJ%%" : "-o ",
#     "%%EXT_ASM%%" : ".s",
#     "%%EXT_DLL%%" : ".so",
#     "%%EXE%%" : "",
#     "%%EXT_LIB%%" : ".a",
#     "%%EXT_OBJ%%" : ".o",
#     "%%FLAMBDA%%" : "false",
#     "%%WITH_FLAMBDA_INVARIANTS%%" : "false",
#     "%%WITH_CMM_INVARIANTS%%" : "false",
#     "%%FLEXLINK_FLAGS%%" : "",
#     "%%FLEXDLL_DIR%%" : "",
#     "%%HOST%%" : "x86_64-apple-darwin20.6.0",
#     "%%BINDIR%%" : "/usr/local/bin",
#     "%%LIBDIR%%" : "/usr/local/lib/ocaml",
#     "%%MKDLL%%" : "{MKDLL}".format(MKDLL=MKDLL),
#     "%%MKEXE%%" : "{MKEXE}".format(
#         MKEXE=" ".join(MKEXE)
#     ),
#     "%%FLEXLINK_LDFLAGS%%" : "",
#     "%%FLEXLINK_DLL_LDFLAGS%%" : "",
#     "%%MKMAINDLL%%" : "{MKMAINDLL}".format(
#         MKMAINDLL = MKMAINDLL
#     ),
#     "%%MODEL%%" : "default",
#     "%%NATIVECCLIBS%%" : "{NATIVECCLIBS} ".format(
#         NATIVECCLIBS=" ".join(NATIVECCLIBS)
#     ),
#     "%%OCAMLC_CFLAGS%%" : "{OCAMLC_CFLAGS}  ".format(
#         OCAMLC_CFLAGS=" ".join(OCAMLC_CFLAGS)
#     ),
#     "%%OCAMLC_CPPFLAGS%%" : "{OCAMLC_CPPFLAGS} ".format(
#         OCAMLC_CPPFLAGS=" ".join(OCAMLC_CPPFLAGS)
#     ),
#     "%%OCAMLOPT_CFLAGS%%" : "{OCAMLC_CFLAGS} ".format(
#         OCAMLC_CFLAGS=" ".join(OCAMLC_CFLAGS)
#     ),
#     "%%OCAMLOPT_CPPFLAGS%%" : "{OCAMLC_CPPFLAGS} ".format(
#         OCAMLC_CPPFLAGS=" ".join(OCAMLC_CPPFLAGS)
#     ),
#     "%%PACKLD%%" : "ld -r -arch x86_64 -o {EMPTY}".format(EMPTY=EMPTY),
#     "%%PROFINFO_WIDTH%%" : "0",
#     "%%RANLIBCMD%%" : "{RANLIBCMD}".format(RANLIBCMD=RANLIBCMD),
#     "%%RPATH%%" : "",
#     "%%MKSHAREDLIBRPATH%%" : "",
#     "%%FORCE_SAFE_STRING%%" : "true",
#     "%%DEFAULT_SAFE_STRING%%" : "true",
#     "%%WINDOWS_UNICODE%%" : "0",
#     "%%NAKED_POINTERS%%" : "true",
#     "%%SUPPORTS_SHARED_LIBRARIES%%" : "true",
#     "%%SYSTEM%%" : "macosx",
#     "%%SYSTHREAD_SUPPORT%%" : "true",
#     "%%TARGET%%" : "x86_64-apple-darwin20.6.0",
#     "%%WITH_FRAME_POINTERS%%" : "false",
#     "%%WITH_PROFINFO%%" : "false",
#     "%%FLAT_FLOAT_ARRAY%%" : "true",
#     "%%FUNCTION_SECTIONS%%" : "false",
#     "%%CC_HAS_DEBUG_PREFIX_MAP%%" : "true",
#     "%%AS_HAS_DEBUG_PREFIX_MAP%%" : "false"
# }

def _write_config_impl(ctx):
    ctx.actions.expand_template(
        output = ctx.outputs.output,
        template = ctx.file.template,
        substitutions = ctx.attr.data
    )
    return [
        DefaultInfo(files = depset(direct=[ctx.outputs.output]))
    ]

write_config = rule(
    implementation = _write_config_impl,
    doc = "Generates config.ml",
    attrs = dict(
        output = attr.output(
            mandatory = True
        ),

        template = attr.label(
            mandatory = True,
            allow_single_file = True
        ),

        data = attr.string_dict(
            mandatory = True,
        )
    )
)
