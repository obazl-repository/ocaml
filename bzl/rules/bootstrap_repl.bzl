load(":impl_executable.bzl", "impl_executable")

load(":boot_attrs_executable.bzl", "options_executable")

load(":options.bzl", "options")

#########################
def _bootstrap_repl_impl(ctx):
    execProvider = impl_executable(ctx)
    print("repl fat: %s" % execProvider)

    ocaml_tmp = execProvider[0].files.to_list()[0]

    print("ocaml_tmp: %s" % ocaml_tmp)

    ## expunge
    # "$(execpath //boot/bin:ocamlrun)",
    # "$(location //utils:expunge)",
    # "$(location :ocaml.tmp)",
    # "$(location ocaml)",

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    args = ctx.actions.args()
    args.add(ctx.file._expunger)
    args.add(ocaml_tmp)
    ocaml = ctx.actions.declare_file("ocaml")
    args.add(ocaml)
    args.add_all(ctx.attr.expunge)

    print("EXPUNGER: %s" % ctx.file._expunger)

    ctx.actions.run(
        executable = tc.compiler[DefaultInfo].files_to_run,
        arguments = [args],
        inputs = [ocaml_tmp, ctx.file._expunger], # ctx.file.stdlib],
        outputs = [ocaml],
        tools = [tc.compiler[DefaultInfo].files_to_run],
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
    toolchains = ["//toolchain/type:bootstrap"],
)
