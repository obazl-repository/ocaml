load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

# load("//bzl/actions:BUILD.bzl", "progress_msg", "get_build_executor")

################################################################
def _run_ocamllex_impl(ctx):

    debug = False

    if debug:
        print("run_ocamllex: %s" % ctx.label)
        print("lexer: %s" % ctx.attr._lexer)

    # tc = ctx.toolchains["//toolchain/type:boot"]

    #########################
    args = ctx.actions.args()

    args.add(ctx.file._lexer)

    # toolarg = tc.lexer_arg
    # if toolarg:
    #     args.add(toolarg.path)
    #     toolarg_input = [toolarg]
    # else:
    #     toolarg_input = []

    # print("TCLEX: %s" % tc.lexer)
    inputs_depset = depset(
        direct = [
            ctx.file.src,
        ]
        ,
        transitive = [
            # tc.lexer[DefaultInfo].default_runfiles.files
        ]
    )

    # args.add_all(tc.copts)
    # args.add_all(tc.vmargs[BuildSettingInfo].value)

    args.add_all(ctx.attr.vmargs)

    args.add_all(ctx.attr.opts)

    args.add("-q")

    args.add("-o", ctx.outputs.out)

    args.add(ctx.file.src)

    # lexec = tc.lexecutable

    ctx.actions.run(
        executable = ctx.file._ocamlrun.path,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [ctx.outputs.out],
        tools = [ctx.file._ocamlrun, ctx.file._lexer],
        mnemonic = "OcamlLex",
        progress_message = "runlex"
    )

    return [DefaultInfo(files = depset(direct = [ctx.outputs.out]))]

#################
run_ocamllex = rule(
    implementation = _run_ocamllex_impl,
    doc = "Generates an OCaml source file from an ocamllex source file.",
    attrs = dict(
        _lexer = attr.label(
            allow_single_file = True,
            default = "//boot:ocamllex.boot"
            # default = "//toolchain:lexer"
        ),
        _ocamlrun = attr.label(
            allow_single_file = True,
            default = "//toolchain:ocamlrun",
            executable = True,
            # cfg = "exec"
            cfg = reset_cc_config_transition
        ),
        src = attr.label(
            doc = "A single .mll source file label",
            allow_single_file = [".mll"]
        ),

        out = attr.output(
            mandatory = True,
        ),

        vmargs = attr.string_list(
            doc = "Args to pass to ocamlrun when it runs ocamllex.",
        ),
        opts = attr.string_list(
            doc = "Options"
        ),

        _protocol = attr.label(default = "//config/build/protocol"),

        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),

        _rule = attr.string( default = "run_ocamllex" )
    ),
    executable = False,
    # toolchains = ["//toolchain/type:boot",
    #               ## //toolchain/type:profile,",
    #               "@bazel_tools//tools/cpp:toolchain_type"]
)
