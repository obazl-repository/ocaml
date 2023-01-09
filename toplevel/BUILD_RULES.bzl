##############################
def _run_expunger_impl(ctx):

    repl = ctx.actions.declare_file(ctx.label.name)

    args = ctx.actions.args()
    args.add(ctx.file.expunger.path)
    args.add(ctx.file.toplevel.path)
    args.add(repl.path)
    args.add_all(ctx.attr.retain)

    ctx.actions.run(
        executable = ctx.file.ocamlrun,
        arguments = [args],
        inputs    = [
            ctx.file.expunger,
            ctx.file.toplevel,
        ],
        outputs   = [repl],
        tools = [ctx.file.ocamlrun],
        mnemonic = "RunToplevelExpunger",
        # progress_message = progress_msg(workdir, ctx)
    )

    myrunfiles = ctx.runfiles(
        files = [
            ctx.file.ocamlrun,
            ctx.file.expunger,
            ctx.file.toplevel,
        ],
        # transitive_files =  depset(
        #     transitive = [
        #         ctx.attr.tool[DefaultInfo].default_runfiles.files,
        #         depset(cmt_files)
        #     ]
        # )
    )

    defaultInfo = DefaultInfo(
        executable = repl,
        runfiles = myrunfiles
    )

    return [defaultInfo]

    # return expect_impl(ctx, exe_name)

#######################
run_expunger = rule(
    implementation = _run_expunger_impl,
    doc = "Run toplevel expunger tool.",
    attrs = dict(
        ocamlrun = attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        expunger = attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        toplevel = attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        retain = attr.string_list( # label_list?
            mandatory = True,
        ),
        _verbose = attr.label(
            default = "//:verbose"
        ),

        _rule = attr.string( default = "run_expunger" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    executable = True,
    # toolchains not needed to run expunger
)

