load("//bzl:rules.bzl", "boot_compiler", "boot_executable")

# expand:
# bazel query --output=build //dev/bin:ocamllex.byte

def lexer(name,
          stage = None,
          build_host_constraints = None,
          target_host_constraints = None,
          opts = None,
          visibility = ["//visibility:public"]
          ):

    BOOT_OPTS = ["-strict-sequence", "-nostdlib", "-compat-32", "-w", "-31"]

    boot_compiler(
        name       = name,
        stage      = stage,
        prologue   = ["//lex"],
        main       = "//lex:Main",
        opts       = select({
            "//platforms/target:vm?" : BOOT_OPTS,
            "//platforms/target:sys?": ["-nostdlib"],
            "//conditions:default"   : BOOT_OPTS
        }),
        use_prims  = select({
            "//platforms/target:vm?" : True,
            "//platforms/target:sys?": False,
            "//conditions:default"   : True
        }),
        visibility = ["//visibility:public"]
    )

