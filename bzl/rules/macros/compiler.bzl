load("//bzl:rules.bzl", "boot_compiler")

# expand:
# bazel query --output=build //dev/bin:ocamlc.byte

def compiler(name,
             # stage = None,
             build_host = None,
             target_host = None,
             build_host_constraints = None,
             target_host_constraints = None,
             opts = None,
             visibility = ["//visibility:public"]
             ):

    ## boot compiler, produces baseline:ocamlc.byte
    boot_compiler(
        name                   = "baseline",
        # stage                  = "boot", # stage,
        prologue = [
            "//compilerlibs:ocamlcommon",
            "//bytecomp:ocamlbytecomp"
        ],
        main = "//driver:Main",
        opts                   = opts,
        exec_compatible_with   = [
            # platform: boot_build == sys_vm_vm + build + boot
            "//platform/constraints/ocaml/build/executor:vm_executor",
            "//platform/constraints/ocaml/build/emitter:vm_emitter",
            "//platform/constraints/stage:boot"
        ],
        target_compatible_with = [
            # platform: boot_target == sys_vm_vm + target + boot
            "//platform/constraints/ocaml/target/executor:vm_executor",
            "//platform/constraints/ocaml/target/emitter:vm_emitter",
            "//platform/constraints/stage:boot"
        ],
        visibility             = visibility
    )

    boot_compiler(
        name                   = "dev",
        # stage                  = "dev", # stage,
        prologue = ["//compilerlibs:ocamlcommon"] + select({
            "//platform/constraints/ocaml/target/emitter:sys_emitter?":
            ["//asmcomp:ocamloptcomp"],

            "//platform/constraints/ocaml/target/emitter:vm_emitter?":
            ["//bytecomp:ocamlbytecomp"],
        }),
        main = select({
            "//platform/constraints/ocaml/target/emitter:sys_emitter?":
            "//driver:Optmain",

            "//platform/constraints/ocaml/target/emitter:vm_emitter?":
            "//driver:Main"
        }),
        opts                   = opts,
        exec_compatible_with   = [
            "//platform/constraints/ocaml/build/executor:vm_executor",
            "//platform/constraints/ocaml/build/emitter:vm_emitter",
            "//platform/constraints/stage:baseline"
        ],
        target_compatible_with = [
            # platform: boot_target == sys_vm_vm + target + boot
            # "//platform/constraints/ocaml/target/executor:vm_executor",
            # "//platform/constraints/ocaml/target/emitter:vm_emitter",
            # "//platform/constraints/stage:baseline"
        ],
        visibility             = visibility
    )
