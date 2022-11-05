# load("//bzl/transitions:misc.bzl",
#      "ocamlrun_in_transition",
#      "ocamlrun_out_transition")

load("//bzl/rules:impl_ccdeps.bzl", "dump_CcInfo")

########## RULE:  OCAML_INTERFACE  ################
def _ocamlrun_impl(ctx):
    print("RULE: %s" % ctx.label)

    debug = False
    # if (ctx.label.name == "_Impl"):
    #     debug = True

    cc = ctx.attr._cc_bin
    # print("OCAMLRUN cc: %s" % cc[CcInfo])
    # dump_CcInfo(ctx, cc[CcInfo])

    print("OCAMLRUN files: %s" % ctx.files._cc_bin)
    ocamlrun = ctx.attr._cc_bin[DefaultInfo].files.to_list()[0]
    print("OCAMLRUN cc: %s" % ocamlrun.path)

    ocamlrun_exe = ctx.actions.declare_file("__boot/ocamlrun")
    ctx.actions.symlink(
        output = ocamlrun_exe,
        target_file = ocamlrun
    )
    print("symlinked ocamlrun: %s" % ocamlrun_exe.path)

    return [DefaultInfo(executable = ocamlrun_exe), cc[CcInfo]]

#################
ocamlrun = rule(
    implementation = _ocamlrun_impl,
    doc = "Bootstraps ocamlrun.  The sole purpose of this rule is to ensure ocamlrun gets built only once.",
    attrs = dict(
        _cc_bin = attr.label(
            doc = "The cc_binary rule that actually builds ocamlrun",
            # allow_single_file = True,
            default = "//runtime:_ocamlrun",
            # cfg = ocamlrun_out_transition,
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = ocamlrun_in_transition,
    provides = [CcInfo],
    executable = True,
    # toolchains = ["//toolchain/type:bootstrap"]
)
