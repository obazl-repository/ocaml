load("//bzl:rules.bzl", "boot_compiler")

# expand:
# bazel query --output=build //dev/bin:ocamlc.byte

def compiler(name,
             stage = None,
             build_host = "vm",
             target_host = "vm",
             build_host_constraints = None,
             target_host_constraints = None,
             opts = ["-nostdlib", "-compat-32"],
             visibility = ["//visibility:public"]
             ):

    prologue = ["//compilerlibs:ocamlcommon"]

    if build_host == "vm":
        prologue.append("//bytecomp:ocamlbytecomp")
        main = "//driver:Main"
    elif build_host == "sys":
        prologue.append("//asmcomp:ocamloptcomp")
        main = "//driver:OptMain"

    boot_compiler(
        name                   = name,
        stage                  = stage,
        prologue               = prologue,
        main                   = main,
        opts                   = opts,
        exec_compatible_with   = build_host_constraints,
        target_compatible_with = target_host_constraints,
        visibility             = visibility
    )

