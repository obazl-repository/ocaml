load("//bzl/actions:executable_impl.bzl", "executable_impl")

load("//bzl/attrs:executable_attrs.bzl", "executable_attrs")

load("//bzl/transitions:cc_transitions.bzl", "reset_cc_config_transition")

load("//bzl/rules/common:options.bzl", "options")

#########################
def _bootstrap_repl_impl(ctx):
    return DefaultInfo()
    # execProvider = executable_impl(ctx)
    # print("repl fat: %s" % execProvider)

    # ocaml_tmp = execProvider[0].files.to_list()[0]

    # print("ocaml_tmp: %s" % ocaml_tmp)

    # ## expunge
    # # "$(execpath //boot/bin:ocamlrun)",
    # # "$(location //utils:expunge)",
    # # "$(location :ocaml.tmp)",
    # # "$(location ocaml)",

    # tc = ctx.toolchains["//toolchain/type:bootstrap"]

    # args = ctx.actions.args()
    # args.add(ctx.file._expunger)
    # args.add(ocaml_tmp)
    # ocaml = ctx.actions.declare_file("ocaml")
    # args.add(ocaml)
    # args.add_all(ctx.attr.expunge)

    # print("EXPUNGER: %s" % ctx.file._expunger)

    # ctx.actions.run(
    #     executable = tc.compiler[DefaultInfo].files_to_run,
    #     arguments = [args],
    #     inputs = [ocaml_tmp, ctx.file._expunger], # ctx.file.stdlib],
    #     outputs = [ocaml],
    #     tools = [tc.compiler[DefaultInfo].files_to_run],
    #     mnemonic = "toplevel",
    #     progress_message = "building toplevel: {ws}//{pkg}:{tgt}".format(
    #         # mode = mode,
    #         # rule = ctx.attr._rule,
    #         ws  = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name,
    #         pkg = ctx.label.package,
    #         tgt = ctx.label.name,
    #     )
    # )
    # return DefaultInfo(executable = ocaml)

################################
# rule_options = options("ocaml")
# rule_options.update(options_executable("ocaml"))

# rule_options = options_executable("ocaml")

##################
bootstrap_repl = rule(
    implementation = _bootstrap_repl_impl,
    doc = """Bootstrap repl (toplevel) builder.
    """,
    attrs = dict(
        executable_attrs(),

        ## _runtime: for sys executor only
        _runtime = attr.label(
            # allow_single_file = True,
            default = "//runtime:asmrun",
            executable = False,
            # cfg = reset_cc_config_transition ## only build once
            # default = "//config/runtime" # label flag set by transition
        ),

        expunge = attr.string_list(
            doc = "List of module names to expunge",
        ),

        _expunger = attr.label(
            default = "//toplevel:expunge",
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
