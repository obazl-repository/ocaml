load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "OcamlProvider")

load(":options.bzl",
     "options",
     "options_ns_resolver",
     "NEGATION_OPTS")

load("//bzl:providers.bzl",
     # "CompilationModeSettingProvider",
     "OcamlNsResolverProvider")

load(":impl_common.bzl", "tmpdir", "dsorder")

# load("//bzl/rules:impl_ns_resolver.bzl", "impl_ns_resolver")

load("//bzl:functions.bzl", "config_tc")

##############################################
# alas, this won't work: checksums tied to file (module) name
def symlink_submodules(ctx, ns_prefix, scope):

    aliases  = []
    symlinks = []
    includes = []

    for submodule in ctx.attr.submodules:
        print("submodule: %s" % submodule)
        cmo = submodule[DefaultInfo].files.to_list()[0]
        print("cmo: %s" % cmo)
        for f in submodule[OcamlProvider].cmi.to_list():
            if f.extension == "cmi":
                cmi = f
            elif f.extension == "mli":
                mli = f
        print("cmi: %s" % cmi)
        print("mli: %s" % mli)
        cmi = submodule[OcamlProvider].cmi.to_list()[0]
        print("cmi: %s" % cmi)

        (basename, ext) = paths.split_extension(cmo.basename)
        submod_name = basename[:1].capitalize() + basename[1:]

        print("submod rawname: %s" % submod_name)
        print("submod ext: %s" % ext)

        submod_nsname = "{ns}{sep}{mod}".format(
            ns  = ns_prefix,
            sep = "__",
            mod = submod_name,
        )
        print("submod nsname: %s" % submod_nsname)

        cmi_symlink_file = ctx.actions.declare_file(
            scope + submod_nsname + ".cmi"
        )
        ctx.actions.symlink(
            output = cmi_symlink_file,
            target_file = cmi
        )
        symlinks.append(cmi_symlink_file)
        print("cmi_symlink: %s" % cmi_symlink_file.path)

        ################
        mli_symlink_file = ctx.actions.declare_file(
            scope + submod_nsname + ".mli"
        )
        ctx.actions.symlink(
            output = mli_symlink_file,
            target_file = mli
        )
        symlinks.append(mli_symlink_file)
        print("mli_symlink: %s" % mli_symlink_file.path)

        ################
        cmo_symlink_file = ctx.actions.declare_file(
            scope + submod_nsname + ".cmo" # FIXME: or .cmx
        )
        ctx.actions.symlink(
            output = cmo_symlink_file,
            target_file = cmo
        )
        print("cmo_symlink: %s" % cmo_symlink_file.path)
        symlinks.append(cmo_symlink_file)
        includes.append(cmo_symlink_file.dirname)

        # cmi_symlink = "{ns}{sep}{mod}".format(
        #     ns  = ns_prefix,
        #     sep = "__",
        #     mod = submod_name,
        # )
        # print("cmi symlinked name: %s" % cmi_symlink)

        alias = "module {mod} = {submod_nsname}".format(
            mod = submod_name,
            submod_nsname = submod_nsname
        )

        aliases.append(alias)

    return (symlinks, includes, aliases)

###############################
def _bootstrap_ns(ctx):

    debug = False
    # if ctx.label.name == "":
    #     debug = True

    (mode, tc, tool, tool_args, scope, ext) = config_tc(ctx)

    # return impl_ns_resolver(ctx, mode, tool, tool_args)

    # if mode == "native":
    #     exe = tc.ocamlopt.basename
    # else:
    #     exe = tc.ocamlc.basename

    ################
    default_outputs = [] ## .cmx only
    action_outputs = []  ## .cmx, .cmi, .o
    rule_outputs = [] # excludes .cmi

    out_cm_ = None
    out_cmi = None

    if ctx.attr.ns:
        ns_prefix = [ctx.attr.ns]
    else:
        ns_prefix = ctx.label.name[:1].capitalize() + ctx.label.name[1:]

    print("NS PREFIX: %s" % ns_prefix)

    user_ns_resolver = None

    (symlinks, includes, aliases) = symlink_submodules(ctx, ns_prefix, scope)

    print("symlinks: %s" % symlinks)
    print("aliases: %s" % aliases)

    ################################################################
    ## user-provided resolver
    if ctx.attr.resolver:
        print("User-provided resolver: %s" % ctx.attr.resolver)

        # return [DefaultInfo(),
        #         OcamlNsResolverProvider(ns_name = ns_name)]
        # resolver_module_name = ns_name + resolver_suffix

    ################################################################
    else:
        resolver_module_name = ns_prefix

    # do not generate a resolver module unless we have at least one alias
    # if len(aliases) < 1:
    #     print("NO ALIASES: %s" % ctx.label)
    #     return [DefaultInfo(),
    #             OcamlNsResolverProvider(ns_name = ns_name)]

    resolver_src_filename = resolver_module_name + ".ml"
    resolver_src_file = ctx.actions.declare_file(
        scope + resolver_src_filename
    )

    print("resolver_module_name: %s" % resolver_module_name)
    ## action: generate ns resolver module file with alias content
    ##################
    ctx.actions.write(
        output = resolver_src_file,
        content = "\n".join(aliases) + "\n"
    )
    ##################
    print("RESOLVER srcfile: %s" % resolver_src_file.path)

    ## then compile it:

    out_cmi_fname = resolver_module_name + ".cmi"
    out_cmi = ctx.actions.declare_file(out_cmi_fname)
    action_outputs.append(out_cmi)

    if mode == "native":
        obj_o_fname = resolver_module_name + ".o"
        obj_o = ctx.actions.declare_file(obj_o_fname)
        action_outputs.append(obj_o)
        # rule_outputs.append(obj_o)
        out_cm__fname = resolver_module_name + ".cmx"
    else:
        out_cm__fname = resolver_module_name + ".cmo"

    out_cm_ = ctx.actions.declare_file(out_cm__fname)
    action_outputs.append(out_cm_)
    default_outputs.append(out_cm_)
    # rule_outputs.append(out_cm_)

    ################################
    args = ctx.actions.args()

    args.add_all(tool_args)

    # _options = get_options(ctx.attr._rule, ctx)
    # args.add_all(_options)
    for arg in ctx.attr.opts:
        if arg not in NEGATION_OPTS:
            args.add(arg)

    # if ctx.attr._warnings:
    #     args.add_all(ctx.attr._warnings[BuildSettingInfo].value, before_each="-w", uniquify=True)

    includes.append(resolver_src_file.dirname)
    action_inputs = []

    action_inputs.append(resolver_src_file)

    ## -no-alias-deps is REQUIRED for ns modules;
    ## see https://caml.inria.fr/pub/docs/manual-ocaml/modulealias.html

    args.add_all(includes, before_each = "-I", uniquify = True)

    args.add("-no-alias-deps")

    args.add("-c")

    args.add("-o", out_cm_)

    args.add("-impl")
    args.add(resolver_src_file.path)

    inputs_depset = depset(
        direct = action_inputs,
        transitive = [depset(symlinks)]
    )

    ctx.actions.run(
        # env = env,
        executable = tool,
        arguments = [args],
        inputs = inputs_depset,
        outputs = action_outputs,
        tools = [tool] + tool_args,
        mnemonic = "OcamlNsResolverAction" if ctx.attr._rule == "ocaml_ns" else "PpxNsResolverAction",
        progress_message = "{mode} compiling {rule}: {ws}//{pkg}:{tgt}".format(
            mode = mode,
            rule=ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name,
        )
    )

    defaultInfo = DefaultInfo(
        files = depset(
            order  = dsorder,
            direct = action_outputs + symlinks
        )
    )

    nsResolverProvider = OcamlNsResolverProvider(
        # provide src for output group, for easy reference
        # resolver_file = resolver_src_file,
        # submodules = submodules,
        # resolver = resolver_module_name,
        # prefixes   = ns_prefixes,
        # ns_name    = ns_name
    )

    linkset    = depset(direct = [out_cm_])

    fileset_depset = depset(direct=action_outputs)

    closure_depset = depset(
        direct = action_outputs
    )

    ocamlProvider = OcamlProvider(
        cmi      = depset(direct = [out_cmi]),
        fileset  = fileset_depset,
        linkargs = linkset,
        inputs   = closure_depset, ## inputs_depset,
        paths    = depset(direct = [out_cmi.dirname]),
    )

    outputGroupInfo = OutputGroupInfo(
        cmi        = depset(direct=[out_cmi]),
        fileset    = fileset_depset,
        # linkset    = linkset,
        inputs = inputs_depset,
        # all = depset(
        #     order = dsorder,
        #     transitive=[
        #         default_depset,
        #         ocamlProvider_files_depset,
        #         ppx_codeps_depset,
        #         # depset(action_inputs_ccdep_filelist)
        #     ]
        # )
    )

    # print("resolver provider: %s" % ocamlProvider)

    return [
        defaultInfo,
        nsResolverProvider,
        ocamlProvider,
        outputGroupInfo
    ]

#########################
# rule_options = options("ocaml")
# rule_options.update(options_ns_resolver("ocaml"))

bootstrap_ns = rule(
  implementation = _bootstrap_ns,
    doc = "NS Resolver for bootstrapping the OCaml compiler",
    attrs = dict(
        # rule_options,

        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),

        _toolchain = attr.label(
            default = "//bzl/toolchain:tc"
        ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        ocamlc = attr.label(
            # cfg = ocamlc_out_transition,
            allow_single_file = True,
            default = "//bzl/toolchain:ocamlc"
        ),

        ns = attr.string(),

        resolver = attr.label(
            doc = "User-provided resolver module."
        ),

        submodules = attr.label_list(
            doc = "",
            allow_files = True,
            mandatory = True
        ),

        # _ns_prefixes   = attr.label(
        #     doc = "Experimental",
        #     default = ws + "//ns:prefixes"
        # ),
        # _ns_strategy = attr.label(
        #     doc = "Experimental",
        #     default = "@ocaml//ns:strategy"
        # ),

        # _mode       = attr.label(
        #     default = "//mode",
        # ),

        mode       = attr.string(
            doc     = "Overrides mode build setting.",
            # default = ""
        ),

        # _warnings  = attr.label(default = "@ocaml//ns:warnings"),

        _rule = attr.string(default = "bootstrap_ns")
    ),
    provides = [OcamlNsResolverProvider],
    executable = False,
    toolchains = [
        "//toolchain/type:bootstrap",
    ],
)
