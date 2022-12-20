load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl/actions:executable_impl.bzl", "executable_impl")
load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:ocaml_transitions.bzl",
     "ocamlc_byte_in_transition",
     "ocamlopt_byte_in_transition",
     "ocamlopt_opt_in_transition",
     "ocamlc_opt_in_transition")

##############################
def _ocaml_compiler_r_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    executor = tc.config_executor
    emitter  = tc.config_emitter

    if executor == "boot":
        exe_name = "ocamlc.byte"
    elif executor == "baseline":
        exe_name = "ocamlc.byte"
    elif executor == "vm":
        if emitter == "vm":
            exe_name = "ocamlc.byte"
        elif emitter == "sys":
            exe_name = "ocamlopt.byte"
        else:
            fail("unknown emitter: %s" % emitter)
    elif executor in ["sys"]:
        if emitter in ["boot", "vm"]:
            exe_name = "ocamlc.opt"
        elif emitter == "sys":
            exe_name = "ocamlopt.opt"
        else:
            fail("sys unknown emitter: %s" % emitter)
    elif executor == "unspecified":
        fail("unspecified executor: %s" % executor)
    else:
        fail("unknown executor: %s" % executor)

    return executable_impl(ctx, tc, exe_name, workdir)

#####################
ocaml_compiler_r = rule(
    implementation = _ocaml_compiler_r_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),

        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _rule = attr.string( default = "ocaml_compiler" ),
    ),
    # cfg = compiler_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
##############################
def _ocamlc_byte_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    executor = tc.config_executor
    emitter  = tc.config_emitter

    if executor == "boot":
        exe_name = "ocamlc.byte"
    elif executor == "baseline":
        exe_name = "ocamlc.byte"
    elif executor == "vm":
        if emitter == "vm":
            exe_name = "ocamlc.byte"
        elif emitter == "sys":
            exe_name = "ocamlopt.byte"
        else:
            fail("unknown emitter: %s" % emitter)
    elif executor in ["sys"]:
        if emitter in ["boot", "vm"]:
            exe_name = "ocamlc.opt"
        elif emitter == "sys":
            exe_name = "ocamlopt.opt"
        else:
            fail("sys unknown emitter: %s" % emitter)
    elif executor == "unspecified":
        fail("unspecified executor: %s" % executor)
    else:
        fail("unknown executor: %s" % executor)

    return executable_impl(ctx, tc, exe_name, workdir)

#####################
ocamlc_byte = rule(
    implementation = _ocamlc_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlc_byte" ),
    ),
    cfg = ocamlc_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _ocamlopt_byte_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    executor = tc.config_executor
    emitter  = tc.config_emitter

    if executor == "boot":
        exe_name = "ocamlc.byte"
    elif executor == "baseline":
        exe_name = "ocamlc.byte"
    elif executor == "vm":
        if emitter == "vm":
            exe_name = "ocamlc.byte"
        elif emitter == "sys":
            exe_name = "ocamlopt.byte"
        else:
            fail("unknown emitter: %s" % emitter)
    elif executor in ["sys"]:
        if emitter in ["boot", "vm"]:
            exe_name = "ocamlc.opt"
        elif emitter == "sys":
            exe_name = "ocamlopt.opt"
        else:
            fail("sys unknown emitter: %s" % emitter)
    elif executor == "unspecified":
        fail("unspecified executor: %s" % executor)
    else:
        fail("unknown executor: %s" % executor)

    return executable_impl(ctx, tc, exe_name, workdir)

#####################
ocamlopt_byte = rule(
    implementation = _ocamlopt_byte_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlopt_byte" ),
    ),
    cfg = ocamlopt_byte_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _ocamlopt_opt_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    executor = tc.config_executor
    emitter  = tc.config_emitter

    if executor == "boot":
        exe_name = "ocamlc.byte"
    elif executor == "baseline":
        exe_name = "ocamlc.byte"
    elif executor == "vm":
        if emitter == "vm":
            exe_name = "ocamlc.byte"
        elif emitter == "sys":
            exe_name = "ocamlopt.byte"
        else:
            fail("unknown emitter: %s" % emitter)
    elif executor in ["sys"]:
        if emitter in ["boot", "vm"]:
            exe_name = "ocamlc.opt"
        elif emitter == "sys":
            exe_name = "ocamlopt.opt"
        else:
            fail("sys unknown emitter: %s" % emitter)
    elif executor == "unspecified":
        fail("unspecified executor: %s" % executor)
    else:
        fail("unknown executor: %s" % executor)

    return executable_impl(ctx, tc, exe_name, workdir)

#####################
ocamlopt_opt = rule(
    implementation = _ocamlopt_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlopt_opt" ),
    ),
    cfg = ocamlopt_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

##############################
def _ocamlc_opt_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    executor = tc.config_executor
    emitter  = tc.config_emitter

    if executor == "boot":
        exe_name = "ocamlc.byte"
    elif executor == "baseline":
        exe_name = "ocamlc.byte"
    elif executor == "vm":
        if emitter == "vm":
            exe_name = "ocamlc.byte"
        elif emitter == "sys":
            exe_name = "ocamlopt.byte"
        else:
            fail("unknown emitter: %s" % emitter)
    elif executor in ["sys"]:
        if emitter in ["boot", "vm"]:
            exe_name = "ocamlc.opt"
        elif emitter == "sys":
            exe_name = "ocamlopt.opt"
        else:
            fail("sys unknown emitter: %s" % emitter)
    elif executor == "unspecified":
        fail("unspecified executor: %s" % executor)
    else:
        fail("unknown executor: %s" % executor)

    return executable_impl(ctx, tc, exe_name, workdir)

#####################
ocamlc_opt = rule(
    implementation = _ocamlc_opt_impl,
    doc = "Builds a compiler",

    attrs = dict(
        executable_attrs(),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
        _rule = attr.string( default = "ocamlc_opt" ),
    ),
    cfg = ocamlc_opt_in_transition,
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

################################################################
####  MACRO
################################################################
def ocaml_compilers(name,
                    visibility = ["//visibility:public"],
                    **kwargs):
    ocamlc_byte(
        name = "ocamlc.byte",
        opts = [ ] + select({
            # ocamlc.byte: ["-compat-32"]
        "//conditions:default": []
        }) + [
            ## use --//config/ocaml/link:verbose instead
            # "-verbose",

        ## for testing (linux):
            # "-cc", "gcc",  ## cancels mkexe
            # "-ccopt", "-B/usr/bin",
            # "-ccopt", "-B/usr/lib",
            # "-ccopt", "-B/usr/lib/gcc/x86_64-linux-gnu/9",
            ## bazel-generated args:
            # "-ccopt", "-fuse-ld=gold",
            # "-ccopt", "-fno-use-linker-plugin",
            # "-ccopt", "-Wl,-no-as-needed",
            # "-ccopt", "-Wl,-z,relro,-z,now",
            # "-ccopt", "-pass-exit-codes",
            # "-ccopt", "-lstdc++",

        # "-ccopt", "-Wl,-export_dynamic",
            # "-ccopt", "-Wl,-all_load"
    ] + select({
        "//platform/target/os:linux?": [
            "-cclib", "-lm",
            "-cclib", "-ldl",
            "-cclib", "-lpthread",
        ],
        "//conditions:default": []
    }),
        cc_linkopts = select({
            "@platforms//os:macos": [ ## FIXME: default tc, not zig
                # "-Wl,-v", # prints config, search paths
                # "-Wl,-print_statistics", # -Wl,-v plus timings, mem, etc.
                # "-t", # -Wl-v plus logs each file the linker loads.
                # "-why_load" # Log why each object file in a static library
                #             # is loaded. That is, what symbol was needed.
                ## zig linker opts
                # "-v",
            ],
            "@platforms//os:linux": [
                # "-Wl,--verbose"
                ##FIXME: depends on linker used (bfd, gold, etc.)
        ]
        }),
        prologue = ["//compilerlibs:ocamlcommon",
                    ] + select({
                        # "//config/target:baseline_vm?": ["//bytecomp:ocamlbytecomp"],
                        # "//config/target:baseline_sys?": ["//asmcomp:ocamloptcomp"],
                        # "//config/target:ult_sys?": ["//asmcomp:ocamloptcomp"],

        "//config/target/emitter:sys_emitter?": ["//asmcomp:ocamloptcomp"],
        "//conditions:default": ["//bytecomp:ocamlbytecomp"]
                    }),
        main = select({
            # "//config/target:baseline_vm?": "//driver:Main",
            # "//config/target:baseline_sys?": "//driver:Optmain",
            # "//config/target:ult_sys?": "//driver:Optmain",

        "//config/target/emitter:sys_emitter?": "//driver:Optmain",
        "//conditions:default": "//driver:Main"
        }),
        # cc_deps = ["//runtime:asmrun"],
        visibility = visibility
    )

    ocamlopt_byte(
        name = "ocamlopt.byte",
        opts = [ ] + select({
            # ocamlc.byte: ["-compat-32"]
        "//conditions:default": []
        }) + [
            ## use --//config/ocaml/link:verbose instead
            # "-verbose",

        ## for testing (linux):
            # "-cc", "gcc",  ## cancels mkexe
            # "-ccopt", "-B/usr/bin",
            # "-ccopt", "-B/usr/lib",
            # "-ccopt", "-B/usr/lib/gcc/x86_64-linux-gnu/9",
            ## bazel-generated args:
            # "-ccopt", "-fuse-ld=gold",
            # "-ccopt", "-fno-use-linker-plugin",
            # "-ccopt", "-Wl,-no-as-needed",
            # "-ccopt", "-Wl,-z,relro,-z,now",
            # "-ccopt", "-pass-exit-codes",
            # "-ccopt", "-lstdc++",

        # "-ccopt", "-Wl,-export_dynamic",
            # "-ccopt", "-Wl,-all_load"
    ] + select({
        "//platform/target/os:linux?": [
            "-cclib", "-lm",
            "-cclib", "-ldl",
            "-cclib", "-lpthread",
        ],
        "//conditions:default": []
    }),
        cc_linkopts = select({
            "@platforms//os:macos": [ ## FIXME: default tc, not zig
                # "-Wl,-v", # prints config, search paths
                # "-Wl,-print_statistics", # -Wl,-v plus timings, mem, etc.
                # "-t", # -Wl-v plus logs each file the linker loads.
                # "-why_load" # Log why each object file in a static library
                #             # is loaded. That is, what symbol was needed.
                ## zig linker opts
                # "-v",
            ],
            "@platforms//os:linux": [
                # "-Wl,--verbose"
                ##FIXME: depends on linker used (bfd, gold, etc.)
        ]
        }),
        prologue = [
            "//compilerlibs:ocamlcommon",
        ] + select({
            "//config/target/emitter:sys_emitter?": ["//asmcomp:ocamloptcomp"],
            "//conditions:default": ["//bytecomp:ocamlbytecomp"]
        }),
        main = select({
        "//config/target/emitter:sys_emitter?": "//driver:Optmain",
        "//conditions:default": "//driver:Main"
        }),
        # cc_deps = ["//runtime:asmrun"],
        visibility = visibility
    )

    ocamlopt_opt(
        name = "ocamlopt.opt",
        opts = [ ] + select({
            # ocamlc.byte: ["-compat-32"]
        "//conditions:default": []
        }) + [
            ## use --//config/ocaml/link:verbose instead
            # "-verbose",

        ## for testing (linux):
            # "-cc", "gcc",  ## cancels mkexe
            # "-ccopt", "-B/usr/bin",
            # "-ccopt", "-B/usr/lib",
            # "-ccopt", "-B/usr/lib/gcc/x86_64-linux-gnu/9",
            ## bazel-generated args:
            # "-ccopt", "-fuse-ld=gold",
            # "-ccopt", "-fno-use-linker-plugin",
            # "-ccopt", "-Wl,-no-as-needed",
            # "-ccopt", "-Wl,-z,relro,-z,now",
            # "-ccopt", "-pass-exit-codes",
            # "-ccopt", "-lstdc++",

        # "-ccopt", "-Wl,-export_dynamic",
            # "-ccopt", "-Wl,-all_load"
    ] + select({
        "//platform/target/os:linux?": [
            "-cclib", "-lm",
            "-cclib", "-ldl",
            "-cclib", "-lpthread",
        ],
        "//conditions:default": []
    }),
        cc_linkopts = select({
            "@platforms//os:macos": [ ## FIXME: default tc, not zig
                # "-Wl,-v", # prints config, search paths
                # "-Wl,-print_statistics", # -Wl,-v plus timings, mem, etc.
                # "-t", # -Wl-v plus logs each file the linker loads.
                # "-why_load" # Log why each object file in a static library
                #             # is loaded. That is, what symbol was needed.
                ## zig linker opts
                # "-v",
            ],
            "@platforms//os:linux": [
                # "-Wl,--verbose"
                ##FIXME: depends on linker used (bfd, gold, etc.)
        ]
        }),
        prologue = [
            "//compilerlibs:ocamlcommon",
        ] + select({
            "//config/target/emitter:sys_emitter?": ["//asmcomp:ocamloptcomp"],
            "//conditions:default": ["//bytecomp:ocamlbytecomp"]
        }),
        main = select({
            "//config/target/emitter:sys_emitter?": "//driver:Optmain",
            "//conditions:default": "//driver:Main"
        }),
        # cc_deps = ["//runtime:asmrun"],
        visibility = visibility
    )

    ocamlc_opt(
        name = "ocamlc.opt",
        opts = [ ] + select({
            # ocamlc.byte: ["-compat-32"]
        "//conditions:default": []
        }) + [
            ## use --//config/ocaml/link:verbose instead
            # "-verbose",

        ## for testing (linux):
            # "-cc", "gcc",  ## cancels mkexe
            # "-ccopt", "-B/usr/bin",
            # "-ccopt", "-B/usr/lib",
            # "-ccopt", "-B/usr/lib/gcc/x86_64-linux-gnu/9",
            ## bazel-generated args:
            # "-ccopt", "-fuse-ld=gold",
            # "-ccopt", "-fno-use-linker-plugin",
            # "-ccopt", "-Wl,-no-as-needed",
            # "-ccopt", "-Wl,-z,relro,-z,now",
            # "-ccopt", "-pass-exit-codes",
            # "-ccopt", "-lstdc++",

        # "-ccopt", "-Wl,-export_dynamic",
            # "-ccopt", "-Wl,-all_load"
    ] + select({
        "//platform/target/os:linux?": [
            "-cclib", "-lm",
            "-cclib", "-ldl",
            "-cclib", "-lpthread",
        ],
        "//conditions:default": []
    }),
        cc_linkopts = select({
            "@platforms//os:macos": [ ## FIXME: default tc, not zig
                # "-Wl,-v", # prints config, search paths
                # "-Wl,-print_statistics", # -Wl,-v plus timings, mem, etc.
                # "-t", # -Wl-v plus logs each file the linker loads.
                # "-why_load" # Log why each object file in a static library
                #             # is loaded. That is, what symbol was needed.
                ## zig linker opts
                # "-v",
            ],
            "@platforms//os:linux": [
                # "-Wl,--verbose"
                ##FIXME: depends on linker used (bfd, gold, etc.)
        ]
        }),
        prologue = [
            "//compilerlibs:ocamlcommon",
        ] + select({
            "//config/target/emitter:sys_emitter?": ["//asmcomp:ocamloptcomp"],
            "//conditions:default": ["//bytecomp:ocamlbytecomp"]
        }),
        main = select({
            "//config/target/emitter:sys_emitter?": "//driver:Optmain",
            "//conditions:default": "//driver:Main"
        }),
        # cc_deps = ["//runtime:asmrun"],
        visibility = visibility
    )
