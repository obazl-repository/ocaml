load("@bazel_skylib//lib:paths.bzl", "paths")

###################
def impl_yacc(ctx):

  debug = False
  # if (ctx.label.name == "_Impl"):
  #     debug = True

  if debug:
      print("OCAML YACC TARGET: %s" % ctx.label.name)

  tc = ctx.toolchains["//toolchain/type:bootstrap"]
  print("yacc tc: %s" % tc.name)

  yaccer_fname = paths.replace_extension(ctx.file.src.basename, ".ml")
  yacceri_fname = paths.replace_extension(ctx.file.src.basename, ".mli")

  # tmpdir = "_obazl_/"

  # yaccer = ctx.actions.declare_file(scope + yaccer_fname)
  yacceri = ctx.actions.declare_file(yacceri_fname)
  print("o: %s" % ctx.outputs.outs)
  yaccer = ctx.outputs.outs[0]

  ctx.actions.run_shell(
      inputs  = [ctx.file.src],
      outputs = ctx.outputs.outs,
      tools   = [tc.yacc],
      command = "\n".join([
          ## ocamlyacc is inflexible, it writes to cwd, that's it.
          ## so we copy source to output dir, cd here, and run ocamlyacc
          # "echo 'output: {}';".format(yaccer.path),
          "cp {src} {dest};".format(src = ctx.file.src.path, dest=yaccer.dirname),
          "cd {dest} && {tool} {src}".format(
              dest=yaccer.dirname,
              tool = "../" + tc.yacc.short_path,
              src=ctx.file.src.basename,
          ),

      ])
  )

  return [DefaultInfo(files = depset(direct = [yaccer, yacceri]))]
