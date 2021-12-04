load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl/rules:impl_common.bzl",
     "dsorder", "module_sep", "resolver_suffix",
     "opam_lib_prefix",
     "tmpdir"
     )


load("//bzl:providers.bzl",
     "OcamlArchiveProvider",
     "OcamlImportMarker",
     "OcamlLibraryMarker",
     "OcamlNsResolverProvider",
     "OcamlModuleMarker",
     "OcamlNsMarker",
     "OcamlProvider",
     "OcamlSignatureProvider")

WARNING_FLAGS = "@1..3@5..28@30..39@43@46..47@49..57@61..62-40"

###############################
def submodule_from_label_string(s):
    """Derive module name from label string."""
    lbl = Label(s)
    target = lbl.name
    # (segs, sep, basename) = s.rpartition(":")
    # (basename, ext) = paths.split_extension(basename)
    basename = target.strip("_")
    submod = basename[:1].capitalize() + basename[1:]
    return lbl.package, submod

######################################################
def _this_module_in_submod_list(ctx, src, submodules):
    # src: File
    # submodules: list of strings (bottomup) or labels (topdown)
    print("_this_module_in_submod_list submodules: %s" % submodules)
    (this_module, ext) = paths.split_extension(src.basename)
    this_module = capitalize_initial_char(this_module)
    this_owner  = src.owner

    # if type(ctx.attr._ns_resolver) == "list":
    #     ns_resolver = ctx.attr._ns_resolver[0][OcamlNsResolverProvider]
    # else:
    #     ns_resolver = ctx.attr._ns_resolver[OcamlNsResolverProvider]

    result = False

    submods = []
    for lbl_string in submodules:
        submod = Label(lbl_string + ".ml")
        (submod_path, submod_name) = submodule_from_label_string(lbl_string)
        if this_module == submod_name:
            if this_owner.package == submod.package:
                result = True

    return result

###########################
def file_to_lib_name(file):
    if file.extension == "so":
        libname = file.basename[:-3]
        if libname.startswith("lib"):
            libname = libname[3:]
        else:
            fail("Found '.so' file without 'lib' prefix: %s" % file)
        return libname
    elif file.extension == "dylib":
        libname = file.basename[:-6]
        if libname.startswith("lib"):
            libname = libname[3:]
        else:
            fail("Found '.so' file without 'lib' prefix: %s" % file)
        return libname
    elif file.extension == "a":
        libname = file.basename[:-2]
        if libname.startswith("lib"):
            libname = libname[3:]
        else:
            fail("Found '.a' file without 'lib' prefix: %s" % file)
        return libname

################################
def normalize_module_label(lbl):
    """Normalize module label: remove leading path segs, extension and prefixed underscores, capitalize first char."""
    # print("NORMALIZING LBL: %s" % lbl.label.name)
    (segs, sep, basename) = lbl.rpartition(":")
    (basename, ext) = paths.split_extension(basename)
    basename = basename.strip("_")
    result = basename[:1].capitalize() + basename[1:]
    # print("Normalized: %s" % result)
    return result

###############################
def normalize_module_name(s):
    """Normalize module name: remove leading path segs, extension and prefixed underscores, capitalize first char."""

    (segs, sep, basename) = s.rpartition("/")
    (basename, ext) = paths.split_extension(basename)

    basename = basename.strip("_")

    result = basename[:1].capitalize() + basename[1:]

    return result

###################################
## FIXME: we don't need this for executables (including test rules)
# if this is a submodule, add the prefix
# otherwise, if ppx, rename
# derive module name from ns prefixes
def get_module_name (ctx, src):
    # print("get_module_name: %s" % src)
    ## src: for modules, ctx.file.struct, for sigs, ctx.file.src
    debug = False

    # we get prefix list from ns_resolver module. they're also in the
    # config state (@ocaml//ns:prefixes), which is how ns_resolver
    # gets them. they are also available in hidden _ns_prefixes for
    # all *_ns_* rules, but those could be changed by transitions.
    # only the ones in the ns_resolver module are reliable.(?)

    # _ns_resolver for modules, sigs has out transition, which forces this
    # to a list:

    ns_resolver = False
    prefix = False
    bottomup = False
    if hasattr(ctx.attr, "ns"):
        # print("HAS ctx.attr.ns")
        if ctx.attr.ns:
            # print("BOTTOMUP")
            bottomup = True
            ns_resolver = ctx.attr.ns
            prefix = ns_resolver.label.name
        # else:
            # if type(ctx.attr._ns_resolver) == "list":
            #     ns_resolver = ctx.attr._ns_resolver[0]
            #     # print("NSR: %s" % ns_resolver)
            # else:
            # ns_resolver = ctx.attr._ns_resolver
    # else:
        # if type(ctx.attr._ns_resolver) == "list":
        #     ns_resolver = ctx.attr._ns_resolver[0]
        #     # print("NSR: %s" % ns_resolver)
        # else:
            # ns_resolver = ctx.attr._ns_resolver

    # if ns_resolver:
    #     # print("RENAME ns_resolver: %s" % ns_resolver)
    #     if OcamlNsResolverProvider in ns_resolver:
    #         ns_resolver = ns_resolver[OcamlNsResolverProvider]
    #     else:
    #         print("MISSING OcamlNsResolverProvider")

    if debug:
        print("ns_resolver: %s" % ns_resolver)

    ns     = None
    # module_sep = "__"

    (this_module, extension) = paths.split_extension(src.basename)
    this_module = capitalize_initial_char(this_module)
    # if ctx.label.name == "Char_cmi":
    #     print("this_module: %s" % this_module)

    fs_prefix = prefix

    if bottomup:
        out_module = prefix + module_sep + this_module
    elif hasattr(ns_resolver, "prefixes"): # "prefix"):
        ns_prefixes = ns_resolver.prefixes # .prefix
        if len(ns_prefixes) == 0:
            out_module = this_module
        elif this_module == ns_prefixes[-1]:
            # this is a main ns module
            out_module = this_module
        else:
            if len(ns_resolver.submodules) > 0:
                if bottomup:
                    # print("sm: %s" % ns_resolver.submodules)
                    # print("this_module: %s" % this_module)
                    if this_module in ns_resolver.submodules:
                        fs_prefix = module_sep.join(ns_prefixes) + "__"
                        out_module = fs_prefix + this_module
                    # else:
                else:
                    if _this_module_in_submod_list(ctx,
                                                   src,
                                                   ns_resolver.submodules):
                        # if ctx.attr._ns_strategy[BuildSettingInfo].value == "fs":
                        #     fs_prefix = get_fs_prefix(str(ctx.label)) + "__"
                        # else:
                        fs_prefix = module_sep.join(ns_prefixes) + "__"
                        out_module = fs_prefix + this_module
                    else:
                        out_module = this_module
            else:
                out_module = this_module
    else: ## not a submodule
        out_module = this_module

    if ctx.label.name == "Std_exit":
        out_module = "std_exit"
    # if ctx.label.name == "Stdlib":
    #     out_module = "stdlib"

    return this_module, fs_prefix, out_module

#######################
def get_fs_prefix(lbl_string):
    # print("GET_FS_PREFIX: %s" % lbl_string)
    ## lbl_string is a string, not a label

    # if ctx.workspace_name == "__main__": # default, if not explicitly named
    #     ws = ctx.workspace_name
    # else:
    #     ws = ctx.label.workspace_name
    # print("WS: %s" % ws)
    # ws = capitalize_initial_char(ws) if ws else ""

    lbl = Label(lbl_string)
    if lbl_string.startswith("@"):
        ws  = capitalize_initial_char(lbl.workspace_name) + "_"
    else:
        ws  = ""
    # print(" FS WS: %s" % ws)
    pathsegs = [x.replace("-", "_").capitalize() for x in lbl.package.split('/')]
    # ns_prefix = ws + ctx.attr.sep + ctx.attr.sep.join(pathsegs)

    prefix = ws + "_".join(pathsegs)
    # print("FS PREFIX: %s" % prefix)

    return prefix

###############################
def capitalize_initial_char(s):
  """Starlark's capitalize fn downcases everything but the first char.  This fn only affects first char."""
  # first = s[:1]
  # rest  = s[1:]
  # return first.capitalize() + rest
  return s[:1].capitalize() + s[1:]

#####################################################
def get_src_root(ctx, root_file_names = ["main.ml"]):
  if (ctx.file.src_root != None):
    return ctx.file.src_root
  elif (len(ctx.files.srcs) == 1):
    return ctx.files.srcs[0]
  else:
    for src in ctx.files.srcs:
      if src.basename in root_file_names:
        return src
  fail("No %s source file found." % " or ".join(root_file_names), "srcs")

#############################
def strip_ml_extension(path): #FIXME: use paths.split_extension()
  if path.endswith(".ml"):
    return path[:-3]
  else:
    return path

###################
# def get_opamroot():
#     return Label("@ocaml_sdk//opamroot").workspace_root + "/" + Label("@ocaml_sdk//opamroot").package

######################
def get_projroot(ctx):
    return ctx.attr._projroot[BuildSettingInfo].value

#####################
# def get_sdkpath(ctx):
#   sdkpath = ctx.attr._sdkpath[BuildSettingInfo].value + "/bin"
#   return sdkpath + ":/usr/bin:/bin:/usr/sbin:/sbin"

#####################
def split_srcs(srcs):
  intfs = []
  impls = []
  for s in srcs:
    if s.extension == "ml":
      impls.append(s)
    else:
      intfs.append(s)
  return intfs, impls

################################################################
################################################################
def rename_srcfile(ctx, src, dest):
    """Rename src file.  Copies input src to output dest"""
    # print("**** RENAME SRC {s} => {d} ****".format(s=src, d=dest))

    inputs  = [src]

    scope = tmpdir

    outfile = ctx.actions.declare_file(scope + dest)

    destdir = paths.normalize(outfile.dirname)

    cmd = ""
    destpath = outfile.path
    cmd = cmd + "mkdir -p {destdir} && cp {src} {dest} && ".format(
      src = src.path,
      destdir = destdir,
      dest = destpath
    )

    cmd = cmd + " true;"

    ctx.actions.run_shell(
      command = cmd,
      inputs = inputs,
      outputs = [outfile],
      mnemonic = (ctx.attr._rule + "_rename_src").replace("_", ""),
      progress_message = "{rule}: rename_src {src}".format(
          rule =  ctx.attr._rule,
          # ctx.label.name,
          src  = src
      )
    )
    return outfile
