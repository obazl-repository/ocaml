## args common to the Big Four compiler rules

OCAMLC_PROLOGUE = select({
    "//config/ocaml/compiler/libs:archived?": ["//stdlib"],
    "//conditions:default": []
}) + [
    "@ocamlcc//compilerlibs:ocamlcommon",
    "@ocamlcc//bytecomp:ocamlbytecomp"
]
OCAMLC_MAIN = "@ocamlcc//driver:Main"

OCAMLOPT_PROLOGUE = select({
    "//config/ocaml/compiler/libs:archived?": ["//stdlib"],
    "//conditions:default": []
}) + [
    "//compilerlibs:ocamlcommon",
    "//asmcomp:ocamloptcomp"
]
OCAMLOPT_MAIN = "//driver:Optmain"

OCAML_COMPILER_OPTS = select({
    # ocamlc.byte: ["-compat-32"]
        "//conditions:default": []
}) + select({
    "//platform/target/os:linux?": [
        "-cclib", "-lm",
        "-cclib", "-ldl",
        "-cclib", "-lpthread",
    ],
    "//conditions:default": []
})

################
# args for profiling compilers

OCAMLCP_MAIN = "//tools:Ocamlcp"

OCAMLCP_PROLOGUE = select({
    "//config/ocaml/compiler/libs:archived?": ["//stdlib"],
    "//conditions:default": []
}) + [
    "//config:Config",
    "//utils:Build_path_prefix_map",
    "//utils:Misc",
    "//utils:Profile",
    "//utils:Warnings",
    "//utils:Identifiable",
    "//utils:Numbers",
    "//utils:Arg_helper",
    "//utils:Clflags",
    "//utils:Local_store",
    "//utils:Terminfo",
    "//parsing:Location",
    "//utils:Load_path",
    "//utils:Ccomp",
    "//driver:Compenv",
    "//driver:Main_args",
    "//tools:Ocamlcp_common"
]

OCAMLOPTP_MAIN = "//tools:Ocamloptp"

OCAMLOPTP_PROLOGUE = select({
    "//config/ocaml/compiler/libs:archived?": ["//stdlib"],
    "//conditions:default": []
}) + [
    "//config:Config",
    "//utils:Build_path_prefix_map",
    "//utils:Misc",
    "//utils:Profile",
    "//utils:Warnings",
    "//utils:Identifiable",
    "//utils:Numbers",
    "//utils:Arg_helper",
    "//utils:Clflags",
    "//utils:Local_store",
    "//utils:Terminfo",
    "//parsing:Location",
    "//utils:Load_path",
    "//utils:Ccomp",
    "//driver:Compenv",
    "//driver:Main_args",
    "//tools:Ocamlcp_common"
]
