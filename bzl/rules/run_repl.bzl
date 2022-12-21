load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl", "BootInfo", "ModuleInfo", "SigInfo")

##############################
def _run_repl_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    runner = ctx.actions.declare_file(ctx.attr.name + ".sh")

    rfs = ctx.attr._tool[DefaultInfo].default_runfiles.files.to_list()

    cmd = " ".join([
        # "echo PWD: ${PWD};",
        # "echo `ls -l`;",
        "{ocamlrun} {ocaml}".format(
            ocamlrun = rfs[0].short_path,
            ocaml    = rfs[1].short_path,
        ),
        "-noinit",
        "-nostdlib",
        "-I",
        "stdlib/_dev_boot" ## FIXME: relativize
    ])

    ctx.actions.write(
        output  = runner,
        content = cmd,
        is_executable = True
    )

    myrunfiles = ctx.runfiles(
        files = [
            ctx.file._tool, ctx.file._stdlib
        ],
        transitive_files =  depset(
            transitive = [
                ctx.attr._tool[DefaultInfo].default_runfiles.files,
                ctx.attr._stdlib[BootInfo].sigs,
                ctx.attr._stdlib[BootInfo].cli_link_deps,
            ]
        )
    )

    defaultInfo = DefaultInfo(
        executable=runner,
        # files = depset([out_exe]),
        runfiles = myrunfiles
    )

    return [defaultInfo]

    # return expect_impl(ctx, exe_name)

#######################
run_repl = rule(
    implementation = _run_repl_impl,
    doc = "Compile and test an OCaml program.",
    attrs = dict(
        _tool = attr.label(
            allow_single_file = True,
            default = "//toplevel:ocaml.tmp"
        ),
        _stdlib = attr.label(
            allow_single_file = True,
            default = "//stdlib" # FIXME: relativize
        ),
        _rule = attr.string( default = "run_repl" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    executable = True,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
