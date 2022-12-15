load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:functions.bzl", "get_workdir")

load("//bzl/rules/common:impl_common.bzl", "tmpdir")

###########################
def _camlheaders_impl(ctx):

    tc = ctx.toolchains["//toolchain/type:boot"]
    # print("CAMLHEADERS tc.ocamlrun: %s" % tc.ocamlrun.path)

    f = ctx.actions.declare_file("camlheader")
    ctx.actions.write(
        output = f,
        content = "#!{f}\n".format(
            f = tc.ocamlrun.path
        )
    )
    fur = ctx.actions.declare_file("camlheader_ur")
    ctx.actions.write(
        output = fur,
        content = "#!\n"
    )
    return [DefaultInfo(files=depset([f, fur]))]

###################
camlheaders = rule(
    implementation = _camlheaders_impl,
    doc = "Generates dummy camlheader file",
    toolchains = ["//toolchain/type:boot"]
)

########################
## future: for production:
# def _prod_camlheaders_impl(ctx):

#     debug_bootstrap = False
#     # NOTE: we only need to emit one file, since we do not build *d,
#     # *i named variants.

#     # print("PFX: %s" % ctx.attr.prefix)

#     # for f in ctx.attr.runtimes:
#     #     print("RF: %s" % f[DefaultInfo].default_runfiles.symlinks.to_list())
#     pfx = ""
#     tc = ctx.toolchains["//toolchain/type:boot"]

#     (executor, emitter, workdir) = get_workdir(ctx, tc)

#     if executor == "vm":
#         ext = ".cmo"
#     else:
#         ext = ".cmx"

#     outputs = []
#     # for f in ctx.file.runtime:

#         # write a template file with abs path to ws root
#         # o = ctx.actions.declare_file("_build/camlheader")
#         # ctx.actions.run_shell(
#         #     outputs = [o],
#         #     command = """
#         #     full_path="$(readlink -f -- "{wsfile}")"
#         #     echo $full_path;
#         #     echo "#!$full_path/{runtime}" > {ofile}
#         #     """.format(
#         #         wsfile = ctx.file._wsfile.dirname,
#         #         runtime = f.path,
#         #         ofile = o.path),
#         #     execution_requirements = {
#         #         # "no-sandbox": "1",
#         #         "no-remote": "1",
#         #         "local": "1",
#         #     }
#         # )

#     camlheader = ctx.actions.declare_file(workdir + "camlheader")

#     runtime = ctx.file._runtime

#     if debug_bootstrap:
#         print("Emitting camlheader: %s" % camlheader.path)
#         print("  camlheader path: %s" % pfx + runtime.path)

#     ctx.actions.expand_template(
#         output   = camlheader,
#         template = ctx.file.template,
#         substitutions = {"PATH": pfx + runtime.path})
#     outputs.append(camlheader)

#     camlheaderd = ctx.actions.declare_file(workdir + "camlheaderd")
#     # print("Emitting camlheaderd: %s" % camlheaderd.path)
#     ctx.actions.expand_template(
#         output   = camlheaderd,
#         template = ctx.file.template,
#         substitutions = {"PATH": pfx + runtime.path + "d"})
#     outputs.append(camlheaderd)

#     camlheaderi = ctx.actions.declare_file(workdir + "camlheaderi")
#     # print("Emitting camlheaderi: %s" % camlheaderi.path)
#     ctx.actions.expand_template(
#         output   = camlheaderi,
#         template = ctx.file.template,
#         substitutions = {"PATH": pfx + runtime.path + "i"})
#     outputs.append(camlheaderi)

#     ctx.actions.do_nothing(
#         mnemonic = "CamlHeaders"
#     )

#     runfiles = ctx.runfiles(
#         files = [ctx.file._runtime]
#     )

#     defaultInfo = DefaultInfo(
#         files=depset(direct = outputs),
#         runfiles = runfiles
#     )
#     return defaultInfo

# #####################
# prod_camlheaders = rule(
#     implementation = _prod_camlheaders_impl,
#     doc = "Generates camlheader files",
#     attrs = {
#         "template" : attr.label(mandatory = True,allow_single_file=True),
#         "_runtime" : attr.label(
#             allow_single_file=True,
#             default = "//runtime:ocamlrun",
#             executable = True,
#             # cfg = "exec"
#             cfg = reset_config_transition,
#         ),
#         # "prefix"   : attr.string(mandatory = False),
#         "suffix"   : attr.string(mandatory = False),
#         "_wsfile": attr.label(
#             allow_single_file = True,
#             default = "@//:BUILD.bazel"),
#         "_allowlist_function_transition": attr.label(
#             default = "@bazel_tools//tools/allowlists/function_transition_allowlist"),
#     },
#     incompatible_use_toolchain_transition = True, #FIXME: obsolete?
#     toolchains = ["//toolchain/type:boot",
#                   # ## //toolchain/type:profile,",
#                   "@bazel_tools//tools/cpp:toolchain_type"]
# )
