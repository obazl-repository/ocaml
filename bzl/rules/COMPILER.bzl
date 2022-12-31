## args common to all compiler rules

OCAMLC_PROLOGUE = select({
    "//config/ocaml/compiler/libs:archived?": ["//stdlib"],
    "//conditions:default": []
}) + [
    "//compilerlibs:ocamlcommon",
    "//bytecomp:ocamlbytecomp"
]
OCAMLC_MAIN = "//driver:Main"

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

