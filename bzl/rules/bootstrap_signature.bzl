load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:paths.bzl", "paths")

# load("//ocaml/_transitions:ns_transitions.bzl", "nsarchive_in_transition")

load("//bzl/providers:ocaml.bzl",
     "CompilationModeSettingProvider",
     "OcamlArchiveMarker",
     "OcamlLibraryMarker",
     "OcamlModuleMarker",
     "OcamlProvider",
     # "OcamlNsResolverProvider",
     "OcamlSignatureProvider")

load("//bzl:functions.bzl",
     "capitalize_initial_char",
     "get_fs_prefix",
     "get_module_name",
     # "get_sdkpath",
     "normalize_module_label"
)

load(":options.bzl",
     # "options",
     # "options_ns_opts",
     # # "options_ppx",
     # "options_signature",
     "NEGATION_OPTS")

load(":impl_ccdeps.bzl", "link_ccdeps", "dump_CcInfo")

load(":impl_common.bzl",
     "dsorder",
     "opam_lib_prefix",
     "tmpdir")

scope = tmpdir

# def _extract_cmi(ctx):
#     if len(ctx.attr.ns_submodule) > 1:
#         fail("only one ns_submodule supported")
#     (ns, module) = ctx.attr.ns_submodule.items()[0];
#     print("Extracting cmi {cmi} from {ns}".format(
#         cmi = module, ns = ns))
#     # print("NS marker: %s" % ns[OcamlNsMarker])
#     # print("OcamlProvider: %s" % ns[OcamlProvider])

#     in_cmi  = None
#     out_cmi = None
#     # for f in ns[OcamlProvider].inputs.to_list(): # nope
#     # for f in ns[OcamlProvider].linkargs.to_list(): #nope
#     for f in ns[OcamlProvider].linkargs.to_list():
#         print("linkarg: %s" % f)
#         if f.basename.endswith(module + ".cmi"):
#             in_cmi = f

#     if in_cmi == None:
#         print("LBL: %s" % ctx.label)
#         fail("ns_submodule submodule: '{m}' not found".format(m=module))

#     if ctx.attr.as_cmi:
#         if ctx.attr.as_cmi.endswith(".cmi"):
#             as_cmi = ctx.attr.as_cmi
#         else:
#             as_cmi = ctx.attr.as_cmi + ".cmi"
#         out_cmi = ctx.actions.declare_file(as_cmi)

#         ctx.actions.symlink(
#             output = out_cmi,
#             target_file = in_cmi
#         )

#     else:
#         out_cmi = in_cmi

#     default_depset = depset(
#         order = dsorder,
#             direct = [out_cmi],
#     )

#     defaultInfo = DefaultInfo(
#         files = default_depset
#     )

#     sigProvider = OcamlSignatureProvider(
#         # mli = mlifile,
#         cmi = out_cmi
#     )

#     return [defaultInfo, sigProvider]

########## RULE:  BOOTSTRAP_SIGNATURE  ################
def _bootstrap_signature_impl(ctx):

    debug = False
    # if ctx.label.name in ["Config_cmi"]:
    #     debug = True

    # env = {"PATH": get_sdkpath(ctx)}

    # if ctx.attr.ns_submodule:
    #     return _extract_cmi(ctx)

    # mode = ctx.attr._mode[CompilationModeSettingProvider].value

    mode = "bytecode"

    tc = ctx.toolchains["//bzl/toolchain:bootstrap"]
    # tc = ctx.toolchains["@obazl_rules_ocaml//ocaml:toolchain"]

    # if mode == "native":
    #     exe = tc.ocamlopt.basename
    # else:
    #     exe = tc.ocamlc.basename

    ## FIXME:
    ## if mode == bc, run 'ocamlrun boot/ocamlc',
    ## if native, run 'boot/ocamlc.opt'
    tool = tc.ocamlrun
    tool_args = [tc.ocamlc]

    ################
    indirect_adjunct_depsets      = []
    indirect_adjunct_path_depsets = []
    indirect_cc_deps  = {}

    ################
    includes   = []

    sig_src = ctx.file.src
    if debug:
        print("sig_src: %s" % sig_src)

    # if sig_src.extension == "ml":
    #     # extract mli file from ml file

    # add prefix if namespaced. from_name == normalized module name
    # derived from sig_src; module_name == prefixed if ns else same as
    # from_name.
    if debug:
        print("SIGNATURE sig_src: %s" % sig_src)
    ns = None
    (from_name, ns, module_name) = get_module_name(ctx, sig_src)
    if debug:
        print("From {src} To: {dst}".format(
            src = from_name, dst = module_name))

    # if False: ## ctx.attr.ppx:
    #     ## mlifile output is generated output of ppx processing
    #     mlifile = impl_ppx_transform("ocaml_signature", ctx,
    #                                  sig_src,
    #                                  module_name + ".mli")
    # else:
    if from_name == module_name:
        ## no ns
        if sig_src.is_source:
            mlifile = ctx.actions.declare_file(scope + sig_src.basename)
            ctx.actions.symlink(output = mlifile,
                                target_file = sig_src)
        else:
            ## generated file, already in bazel dir
            mlifile = sig_src

    else:
        # namespaced w/o ppx: symlink sig_src to prefixed name, so
        # that output dir will contain both renamed input mli and
        # output cmi.
        ns_sig_src = module_name + ".mli"
        if debug:
            print("ns_sig_src: %s" % ns_sig_src)
        mlifile = ctx.actions.declare_file(scope + ns_sig_src)
        ctx.actions.symlink(output = mlifile,
                            target_file = sig_src)
        if debug:
            print("mlifile %s" % mlifile)

    if sig_src.extension == "ml":
        out_cmi = ctx.actions.declare_file(scope + sig_src.basename + "i")
    else:
        out_cmi = ctx.actions.declare_file(scope + module_name + ".cmi")

    if debug:
        print("out_cmi %s" % out_cmi)

    #########################
    args = ctx.actions.args()

    args.add_all(tool_args)

    for arg in ctx.attr.opts:
        if arg not in NEGATION_OPTS:
            args.add(arg)

    # if "-for-pack" in _options:
    #     for_pack = True
    #     _options.remove("-for-pack")
    # else:
    #     for_pack = False

    # if ctx.attr.pack:
    #     args.add("-for-pack", ctx.attr.pack)

    # if ctx.attr.pack:
    #     args.add("-linkpkg")


    includes.append(out_cmi.dirname)

    args.add_all(includes, before_each="-I", uniquify = True)

    # paths_direct   = []
    # paths_indirect = []
    # all_deps_list = []
    # direct_deps_list = []
    # archive_deps_list = []
    # archive_inputs_list = [] # not for command line!

    # input_deps_list = []

    #### INDIRECT DEPS first ####
    # these direct deps are "indirect" from the perspective of the consumer
    indirect_inputs_depsets = []
    indirect_linkargs_depsets = []
    indirect_paths_depsets = []

    ccInfo_list = []

    the_deps = ctx.attr.deps # + [ctx.attr._ns_resolver]
    for dep in the_deps:

        if OcamlProvider in dep:
            indirect_inputs_depsets.append(dep[OcamlProvider].inputs)
            indirect_linkargs_depsets.append(dep[OcamlProvider].linkargs)
            indirect_paths_depsets.append(dep[OcamlProvider].paths)


        if CcInfo in dep:
            ccInfo_list.append(dep[CcInfo])

    # print("SIGARCHDL: %s" % archive_deps_list)

    paths_depset  = depset(
        order = dsorder,
        direct = [out_cmi.dirname],
        transitive = indirect_paths_depsets
    )

    args.add_all(paths_depset.to_list(), before_each="-I")

    ## FIXME: do we need the resolver for sigfiles?
    # for f in ctx.files._ns_resolver:
    #     if f.extension == "cmx":
    #         args.add("-I", f.dirname) ## REQUIRED, even if cmx has full path
    #         args.add(f.path)

    ns_resolver_depset = []
    if hasattr(ctx.attr, "ns"):
        # print("HAS ctx.attr.ns")
        if ctx.attr.ns:
            if OcamlProvider in ctx.attr.ns:
                ns_resolver_depset = [ctx.attr.ns[OcamlProvider].inputs]

                for f in ctx.attr.ns[DefaultInfo].files.to_list():
                    args.add("-I", f.dirname)
                    # args.add(f)

            args.add("-no-alias-deps")
            args.add("-open", ns)

    if sig_src.extension == "ml":
        args.add("-i")
        args.add("-o", out_cmi)
    else:
        args.add("-c")
        args.add("-o", out_cmi)

    args.add("-intf", mlifile)

    direct_inputs = [mlifile]
    if ctx.attr.data:
        direct_inputs.extend(ctx.files.data)

    if ctx.attr.ns:
        # print("NS lbl: %s" % ctx.label)
        # print("ns: %s" % ctx.file.ns)
        bottomup_ns_resolver = ctx.attr.ns
        bottomup_ns_files   = [bottomup_ns_resolver[DefaultInfo].files]
        bottomup_ns_inputs  = [bottomup_ns_resolver[OcamlProvider].inputs]
        bottomup_ns_fileset = [bottomup_ns_resolver[OcamlProvider].fileset]
        bottomup_ns_cmi     = [bottomup_ns_resolver[OcamlProvider].cmi]
    else:
        bottomup_ns_resolver = []
        bottomup_ns_files    = []
        bottomup_ns_fileset  = []
        bottomup_ns_inputs   = []
        bottomup_ns_cmi      = []

    # print("bottomup_ns_inputs: %s" % bottomup_ns_inputs)

    inputs_depset = depset(
        order = dsorder,
        direct = direct_inputs, # + ctx.files._ns_resolver,
        transitive = indirect_inputs_depsets + ns_resolver_depset
        + bottomup_ns_inputs
    )

    ################
    ctx.actions.run(
        # env = env,
        executable = tool,
        arguments = [args],
        inputs = inputs_depset,
        outputs = [out_cmi],
        tools = [tool] + tool_args, # tc.ocamlrun, tc.ocamlc],
        mnemonic = "CompileOcamlSignature",
        progress_message = "{mode} compiling bootstrap_signature: {ws}//{pkg}:{tgt}".format(
            mode = mode,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name
        )
    )

    ################
    default_depset = depset(
        order = dsorder,
        direct = [out_cmi] #, mlifile],
        # transitive = bottomup_ns_files
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )

    sigProvider = OcamlSignatureProvider(
        mli = mlifile,
        cmi = out_cmi
    )

    fileset_depset = depset(
        direct= [out_cmi, mlifile],
        transitive = bottomup_ns_fileset
    )

    new_inputs_depset = depset(
        direct = [out_cmi, mlifile],
        transitive = indirect_inputs_depsets
    )
    linkargs_depset = depset(
        # cmi file does not go in linkargs
        transitive = indirect_linkargs_depsets
    )

    ocamlProvider = OcamlProvider(
        fileset  = fileset_depset,
        inputs   = new_inputs_depset,
        linkargs = linkargs_depset,
        paths    = paths_depset,
    )

    providers = [
        defaultInfo,
        ocamlProvider,
        sigProvider,
    ]

    if ccInfo_list:
        providers.append(
            cc_common.merge_cc_infos(cc_infos = ccInfo_list)
        )

    return providers


################################################################
################################################################

################################
# rule_options = options("ocaml")
# rule_options.update(options_signature)
# rule_options.update(options_ns_opts("ocaml"))
# rule_options.update(options_ppx)

# rule_options = options("ocaml")
# rule_options.update(options_ns_opts("ocaml"))

#######################
bootstrap_signature = rule(
    implementation = _bootstrap_signature_impl,
    doc = "Sig rule for bootstrapping ocaml compilers",
    attrs = dict(
        # rule_options,
        opts             = attr.string_list(
            doc          = "List of OCaml options. Will override configurable default options."
        ),
        ## GLOBAL CONFIGURABLE DEFAULTS (all ppx_* rules)
        # _debug           = attr.label(default = "@ocaml//debug"),
        # _cmt             = attr.label(default = "@ocaml//cmt"),
        # _keep_locs       = attr.label(default = "@ocaml//keep-locs"),
        # _noassert        = attr.label(default = "@ocaml//noassert"),
        # _opaque          = attr.label(default = "@ocaml//opaque"),
        # _short_paths     = attr.label(default = "@ocaml//short-paths"),
        # _strict_formats  = attr.label(default = "@ocaml//strict-formats"),
        # _strict_sequence = attr.label(default = "@ocaml//strict-sequence"),
        # _verbose         = attr.label(default = "@ocaml//verbose"),

        # _mode       = attr.label(
        #     default = "@ocaml//mode",
        # ),
        mode       = attr.string(
            doc     = "Compile mode, bytecode or native.",
            default = "bytecode"
        ),

        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath") # ppx also uses this
        # ),

        src = attr.label(
            doc = "A single .mli source file label",
            allow_single_file = [".mli", ".ml"] #, ".cmi"]
        ),

        ns = attr.label(
            doc = "Bottom-up namespacing",
            allow_single_file = True,
            mandatory = False
        ),

        pack = attr.string(
            doc = "Experimental",
        ),

        deps = attr.label_list(
            doc = "List of OCaml dependencies. Use this for compiling a .mli source file with deps. See [Dependencies](#deps) for details.",
            providers = [
                [OcamlProvider],
                [OcamlArchiveMarker],
                # [OcamlImportMarker],
                [OcamlLibraryMarker],
                [OcamlModuleMarker],
                # [OcamlSigMarker],
                # [OcamlNsMarker],
            ],
            # cfg = ocaml_signature_deps_out_transition
        ),

        data = attr.label_list(
            allow_files = True
        ),

        ################################################################
        # _ns_resolver = attr.label(
        #     doc = "Experimental",
        #     providers = [OcamlNsResolverProvider],
        #     # default = "@ocaml//ns:bootstrap",
        #     default = "@ocaml//bootstrap/ns:resolver",
        # ),

        # _ns_submodules = attr.label( # _list(
        #     doc = "Experimental.  May be set by ocaml_ns_library containing this module as a submodule.",
        #     default = "@ocaml//ns:submodules", ## NB: ppx modules use ocaml_signature
        # ),

        ################################################################


        # opts = attr.string_list(doc = "List of OCaml options."),

        # mode       = attr.string(
        #     doc     = "Compilation mode, 'bytecode' or 'native'",
        #     default = "bytecode"
        # ),

        # _debug           = attr.label(default = "@ocaml//debug"),

        ## RULE DEFAULTS
        # _linkall     = attr.label(default = "@ocaml//signature/linkall"), # FIXME: call it alwayslink?
        # _threads     = attr.label(default = "@ocaml//signature/threads"),
        # _warnings  = attr.label(default = "@ocaml//signature:warnings"),

        #### end options ####

        # src = attr.label(
        #     doc = "A single .mli source file label",
        #     allow_single_file = [".mli", ".ml"] #, ".cmi"]
        # ),

        # ns_submodule = attr.label_keyed_string_dict(
        #     doc = "Extract cmi file from namespaced module",
        #     providers = [
        #         [OcamlNsMarker, OcamlArchiveMarker],
        #     ]
        # ),

        # as_cmi = attr.string(
        #     doc = "For use with ns_module only. Creates a symlink from the extracted cmi file."
        # ),

        # pack = attr.string(
        #     doc = "Experimental",
        # ),

        # deps = attr.label_list(
        #     doc = "List of OCaml dependencies. Use this for compiling a .mli source file with deps. See [Dependencies](#deps) for details.",
        #     providers = [
        #         [OcamlProvider],
        #         [OcamlArchiveMarker],
        #         [OcamlImportMarker],
        #         [OcamlLibraryMarker],
        #         [OcamlModuleMarker],
        #         [OcamlNsMarker],
        #     ],
        #     # cfg = ocaml_signature_deps_out_transition
        # ),

        # data = attr.label_list(
        #     allow_files = True
        # ),

        # ################################################################
        # _ns_resolver = attr.label(
        #     doc = "Experimental",
        #     providers = [OcamlNsResolverProvider],
        #     # default = "@ocaml//ns:bootstrap",
        #     default = "@ocaml//bootstrap/ns:resolver",
        # ),

        # _ns_submodules = attr.label( # _list(
        #     doc = "Experimental.  May be set by ocaml_ns_library containing this module as a submodule.",
        #     default = "@ocaml//ns:submodules", ## NB: ppx modules use ocaml_signature
        # ),
        # _ns_strategy = attr.label(
        #     doc = "Experimental",
        #     default = "@ocaml//ns:strategy"
        # ),
        # _mode       = attr.label(
        #     default = "@ocaml//mode",
        # ),
        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath")
        # ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        _rule = attr.string( default = "ocaml_signature" ),
    ),
    incompatible_use_toolchain_transition = True,
    provides = [OcamlSignatureProvider],
    executable = False,
    toolchains = ["//bzl/toolchain:bootstrap"],
)
