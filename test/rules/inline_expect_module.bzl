load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "BootInfo", "dump_bootinfo",
     "DumpInfo",
     "ModuleInfo",
     "NsResolverInfo",
     "SigInfo",
     "StdStructMarker",
     "StdlibStructMarker",
     "StdLibMarker")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")
load("//bzl/rules/common:impl_common.bzl", "dsorder")
load("//bzl/rules/common:impl_ccdeps.bzl", "dump_CcInfo", "ccinfo_to_string")

load(":test_transitions.bzl",
     "vv_test_in_transition")

load("//bzl/actions:module_compile_action.bzl", "construct_module_compile_action")

######################
def _inline_expect_module_impl(ctx):

    debug = False
    debug_ccdeps = False

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]
    module_name = None

    # return module_impl(ctx, module_name)

    (inputs,
     outputs, # dictionary of files
     executor,
     executor_arg,  ## ignore - only used for compile_module_test
     workdir,
     args) = construct_module_compile_action(ctx, module_name)

    if debug:
        print("compiling module: %s" % ctx.label)
        print("INPUT BOOTINFO:")
        dump_bootinfo(inputs.bootinfo)
        print("OUTPUTS: %s" % outputs)
        print("INPUT FILES: %s" % inputs.files)
        print("INPUT.structfile: %s" % inputs.structfile)
        print("INPUT.cmi: %s" % inputs.cmi)
        # fail()

    outs = []
    for v in outputs.values():
        if v: outs.append(v)

    print("OUTS: %s" % outs)
    # if ctx.attr._rule == "test_infer_signature":
    #     fail()

    cc_toolchain = find_cpp_toolchain(ctx)

    ##FIXME: use rule-specific mnemonic, e.g CompileStdlibModule

    ################
    ctx.actions.run(
        # env        = env,
        executable = executor.path,
        arguments = [args],
        # inputs: from deps we get a list of depsets, so:
        # inputs = depset(direct=[action inputfiles...],
        #                 transitive=[deps dsets...])
        inputs    = depset(
            direct = inputs.files + [executor],
            transitive = []
            + inputs.bootinfo.sigs
            + inputs.bootinfo.structs
            + inputs.bootinfo.cli_link_deps
            # etc.
            + [cc_toolchain.all_files] ##FIXME: only for sys outputs
        ),
        outputs   = outs,
        # tools = [],
        mnemonic = "CompileModule",
        # progress_message = progress_msg(workdir, ctx)
    )

    #############################################
    ################  PROVIDERS  ################

    default_depset = depset(
        order = dsorder,
        # only output one file; for cmx, get .o from ModuleInfo
        # direct = [outputs["cmstruct"]]
        direct = [outputs["corrected"]]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )
    providers = [defaultInfo]

    return providers

####################
inline_expect_module = rule(
    implementation = _inline_expect_module_impl,
    doc = "Compiles a module.",
    attrs = dict(
        module_attrs(),
        _expect_compiler = attr.label(
            allow_single_file = True,
            default = "//testsuite/tools:inline_expect",
            executable = True,
            cfg = "exec"
            # cfg = reset_cc_config_transition ## only build once
        ),

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
        _rule = attr.string( default = "inline_expect_module" ),
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

