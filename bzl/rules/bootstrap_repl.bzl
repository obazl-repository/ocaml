load(":impl_executable.bzl", "impl_executable")

load("//bzl:functions.bzl", "config_tc")

load(":options.bzl", "options", "options_executable")

#########################
def _bootstrap_repl_impl(ctx):
    execProvider = impl_executable(ctx)
    print("repl fat: %s" % execProvider)

    ocaml_tmp = execProvider[0].files.to_list()[0]

    print("ocaml_tmp: %s" % ocaml_tmp)

    ## expunge
    # "$(execpath //runtime:ocamlrun)",
    # "$(location //utils:expunge)",
    # "$(location :ocaml.tmp)",
    # "$(location ocaml)",

    (mode, tc, tool, tool_args, scope, ext) = config_tc(ctx)

    args = ctx.actions.args()
    args.add(ctx.file._expunger)
    args.add(ocaml_tmp)
    ocaml = ctx.actions.declare_file("ocaml")
    args.add(ocaml)
    args.add_all(ctx.attr.expunge)

    print("EXPUNGER: %s" % ctx.file._expunger)

    ctx.actions.run(
        executable = tool,
        arguments = [args],
        inputs = [ocaml_tmp, ctx.file._expunger], # ctx.file.stdlib],
        outputs = [ocaml],
        tools = [tool],
        mnemonic = "toplevel",
        progress_message = "building toplevel: {ws}//{pkg}:{tgt}".format(
            # mode = mode,
            # rule = ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name,
            pkg = ctx.label.package,
            tgt = ctx.label.name,
        )
    )
    return DefaultInfo(executable = ocaml)

################################
# rule_options = options("ocaml")
# rule_options.update(options_executable("ocaml"))

rule_options = options_executable("ocaml")

##################
bootstrap_repl = rule(
    implementation = _bootstrap_repl_impl,
    doc = """Bootstrap repl (toplevel) builder.
    """,
    attrs = dict(
        rule_options,

        expunge = attr.string_list(
            doc = "List of module names to expunge",
        ),

        _expunger = attr.label(
            default = "//utils:expunge",
            allow_single_file = True,
            executable = True,
            cfg = "exec"
        ),

        # stdlib = attr.label(
        #     default = "//stdlib",
        #     allow_single_file = True
        # ),

        _rule = attr.string( default = "bootstrap_repl" ),
    ),
    # cfg = executable_in_transition,
    executable = True,
    toolchains = ["//bzl/toolchain:bootstrap"],
)
