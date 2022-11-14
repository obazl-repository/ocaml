load("//bzl:rules.bzl", "boot_compiler")

# expand:
# bazel query --output=build //dev/bin:ocamlc.byte

def compiler(name,
             stage = None,
             build_host = None,
             target_host = None,
             build_host_constraints = None,
             target_host_constraints = None,
             opts = None,
             visibility = ["//visibility:public"]
             ):

    boot_compiler(
        name                   = name,
        stage                  = stage,
        prologue = ["//compilerlibs:ocamlcommon"] + select({
            "//platform/constraints/ocaml/target/emitter:sys?":
            ["//asmcomp:ocamloptcomp"],

            "//platform/constraints/ocaml/target/emitter:vm?":
            ["//bytecomp:ocamlbytecomp"],
        }),
        main = select({
            "//platform/constraints/ocaml/target/emitter:sys?":
            "//driver:Optmain",

            "//platform/constraints/ocaml/target/emitter:vm?":
            "//driver:Main"
        }),
        opts                   = opts,
        exec_compatible_with   = build_host_constraints,
        target_compatible_with = target_host_constraints,
        visibility             = visibility
    )

