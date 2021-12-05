load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl", "CompilationModeSettingProvider")

# load("//ocaml/_functions:utils.bzl", "get_sdkpath")

########## RULE:  OCAML_INTERFACE  ################
def _bootstrap_ocamlyacc_impl(ctx):

  debug = False
  # if (ctx.label.name == "_Impl"):
  #     debug = True

  if debug:
      print("OCAML YACC TARGET: %s" % ctx.label.name)

  tc = ctx.toolchains["//bzl/toolchain:bootstrap"]
  tool = tc.ocamlyacc

  # env = {"PATH": get_sdkpath(ctx)}

  yaccer_fname = paths.replace_extension(ctx.file.src.basename, ".ml")
  yacceri_fname = paths.replace_extension(ctx.file.src.basename, ".mli")

  tmpdir = "_obazl_/"

  # yaccer = ctx.actions.declare_file(scope + yaccer_fname)
  # yacceri = ctx.actions.declare_file(scope + yacceri_fname)

  yaccer = ctx.outputs.out

  ctx.actions.run_shell(
      inputs  = [ctx.file.src],
      outputs = [yaccer], # yacceri],
      tools   = [tool],
      command = "\n".join([
          ## ocamlyacc is inflexible, it writes to cwd, that's it.
          ## so we copy source to output dir, cd here, and run ocamlyacc
          "cp {src} {dest}".format(src = ctx.file.src.path, dest=yaccer.dirname),
          "cd {dest} && {tool} {src}".format(
              dest=yaccer.dirname,
              tool = tc.ocamlyacc.basename,
              src=ctx.file.src.basename,
          ),

      ])
  )

  return [DefaultInfo(files = depset(direct = [yaccer]))]

#################
bootstrap_ocamlyacc = rule(
    implementation = _bootstrap_ocamlyacc_impl,
    doc = """Generates an OCaml source file from an ocamlyacc source file.
    """,
    attrs = dict(
        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath")
        # ),
        src = attr.label(
            doc = "A single .mly ocamlyacc source file label",
            allow_single_file = [".mly"]
        ),
        out = attr.output(
            doc = """Output filename.""",
            mandatory = True
        ),
        opts = attr.string_list(
            doc = "Options"
        ),
        _rule = attr.string( default = "ocaml_yacc" )
    ),
    # provides = [],
    executable = False,
    toolchains = ["//bzl/toolchain:bootstrap"]
)
