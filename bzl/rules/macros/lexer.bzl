load("//bzl:rules.bzl", "boot_compiler", "boot_executable")

# expand:
# bazel query --output=build //dev/bin:ocamllex.byte

def lexer(name,
          stage = None,
          build_host_constraints = None,
          target_host_constraints = None,
          opts = False,
          use_prims = None,
          visibility = ["//visibility:public"]
          ):

    BOOT_OPTS = ["-strict-sequence", "-nostdlib", "-compat-32", "-w", "-31"]
    if use_prims:
        use_prims = select({
            "//platform/target:vm?" : True,
            "//platform/target:sys?": False,
            "//conditions:default"   : True
        })


    boot_compiler(
        name       = name,
        stage      = stage,
        prologue   = ["//lex"],
        main       = "//lex:Main",
        opts       = select({
            "//platform/target:vm?" : BOOT_OPTS,
            "//platform/target:sys?": ["-nostdlib"],
            "//conditions:default"   : BOOT_OPTS
        }),
        use_prims  = use_prims,
        visibility = ["//visibility:public"]
    )

