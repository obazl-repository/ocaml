## WARNING: 'ocamlc -i' writes to stdout, and actions.run cannot
## redirect stdout. So we have to use actions.run_shell.

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/rules/common:impl_common.bzl", "dsorder")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "SigInfo",
     "StdLibMarker")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

load(":test_transitions.bzl",
     "vv_test_in_transition")

load("//bzl/actions:module_compile_action.bzl", "construct_module_compile_action")

######################
def _test_infer_signature_impl(ctx):
    debug = True
    debug_ccdeps = True

    if ctx.label.name == "Load_path":
        debug = True

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    (inputs,
     outputs, # dictionary of files
     executor,
     executor_arg,
     workdir,
     args) = construct_module_compile_action(ctx, module_name)

    outs = []
    for v in outputs.values():
        if v: outs.append(v)

    cc_toolchain = find_cpp_toolchain(ctx)

    ##################
    ctx.actions.run_shell(
        inputs = depset(
            direct = inputs.files,
            transitive = []
            + inputs.bootinfo.sigs
            + inputs.bootinfo.structs
            + inputs.bootinfo.cli_link_deps
        ),
        outputs = outs,
        tools = [executor, executor_arg],
        arguments = [args],
        command = " ".join([
            "{exe} $@".format(exe=executor.path),
            ">", "{}".format(outputs["mli"].path)
        ])
        # toolchain = "???"
    )

    ##################
    # tc = ctx.toolchains["//toolchain/type:ocaml"]

    # runfiles = []
    # myrunfiles = ctx.runfiles(
    #     files = [
    #         executor,
    #         args_file,
    #         ctx.file.struct, ctx.file.expected,
    #         ctx.file._runfiles_tool
    #     ] + ([executor_arg] if executor_arg else []),
    #     transitive_files =  depset(
    #         transitive = []
    #         + inputs.bootinfo.sigs
    #         + inputs.bootinfo.structs
    #         + inputs.bootinfo.cli_link_deps
    #         # etc.
    #         + [ctx.attr._runfiles_tool[DefaultInfo].files]
    #         + [ctx.attr._runfiles_tool[DefaultInfo].default_runfiles.files]
    #         + [cc_toolchain.all_files] ##FIXME: only for sys outputs
    #     ),
    #         # direct=compiler_runfiles,
    #         # transitive = [depset(
    #         #     # [ctx.file._std_exit, ctx.file._stdlib]
    #         # )]
    # )

    ################################################################
    defaultInfo = DefaultInfo(
        files = depset([outputs["mli"]]),
    )
    providers = [defaultInfo]

    return providers

####################
test_infer_signature = rule(
    implementation = _test_infer_signature_impl,
    doc = "Compiles a module.",
    attrs = dict(
        module_attrs(),
        suppress_cmi = attr.label_list(
            doc = "For testing only: do not pass on cmi files in Providers.",
            providers = [
                [ModuleInfo],
                [SigInfo],
                [StdLibMarker],
            ],
        ),
        #FIXME: rename 'dump' > 'logging'
        dump = attr.string_list(
            doc = """
            List of 'dump' options without the -d, e.g. 'lambda' for -dambda
            """
        ),
        # open_stdlib = attr.bool(),
        # stdlib_primitives = attr.bool(default = False),
        # _stdlib = attr.label(
        #     ## only added to depgraph if stdlib_primitives == True
        #     # allow_single_file = True,
        #     default = "//stdlib"
        # ),
        # _resolver = attr.label(
        #     doc = "The compiler always opens Stdlib, so everything depends on it.",
        #     default = "//stdlib:Stdlib"
        # ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
        _rule = attr.string( default = "test_infer_signature" ),
    ),
    ## Should not be run as direct CLI build, only as a dep of
    ## toplevel test rule, which sets config. (?)

    ## cfg must match that of test executable rules, otherwise we may
    ## get the dreaded Interface mismatch (for e.g. Stdlib)
    # cfg = vv_test_in_transition,
    # provides = [BootInfo,ModuleInfo],
    executable = False,
    fragments = ["platform", "cpp"],
    host_fragments = ["platform",  "cpp"],
    # incompatible_use_toolchain_transition = True, #FIXME: obsolete?
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)

# ################################################################
# ##  MACRO: adds tag attribute
# def test_module(name,
#                 visibility = ["//visibility:public"],
#                 **kwargs):

#     if name.endswith(".cmo") or name.endswith(".cmx"):
#         fail("test_module target names are automatically suffixed with .cmo and .cmx; do not include in name attribute.")


#     test_module_(
#         name   = name,
#         visibility = visibility,
#         tags   = ["test_module"],
#         **kwargs
#     )

