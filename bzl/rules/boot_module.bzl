load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     "DepsAggregator",
     "new_deps_aggregator",

     "CompilationModeSettingProvider",

     "OcamlArchiveProvider",
     "OcamlLibraryMarker",
     "OcamlNsMarker",
     "OcamlNsResolverProvider",
     "OcamlSignatureProvider")


load("//bzl:functions.bzl",
     "capitalize_initial_char",
     # "compile_mode_in_transition",
     # "compile_mode_out_transition",
     # "ocamlc_out_transition",
     "get_fs_prefix",
     "get_module_name",
     # "get_sdkpath",
     "normalize_module_label",
     "rename_srcfile",
     "file_to_lib_name")

load(":options.bzl",
     "get_options")
     # "options",
     # "options_module")
     # "options_ns_opts")

# load(":impl_module.bzl", "impl_module")

load(":impl_common.bzl",
     "dsorder",
     "opam_lib_prefix",
     "tmpdir"
     )

load(":DEPS.bzl",
     "aggregate_deps",
     "merge_depsets",
     "COMPILE", "LINK", "COMPILE_LINK")

# sigdeps_closure = None
# sig_linkargs = None
# sig_paths = None

################################################################
def _compile_deps_out_transition_impl(settings, attr):
    # print("compile_deps_out_transition: %s" % attr.name)
    # for m in dir(attr):
    #     print("item: %s" % m)

    if attr.name in settings["//config:manifest"]:
        manifest = settings["//config:manifest"]
    else:
        manifest = []

    return {
            "//config:manifest": manifest
    }

compile_deps_out_transition = transition(
    implementation = _compile_deps_out_transition_impl,
    inputs = [
        "//config:manifest"
    ],
    outputs = [
        "//config:manifest"
    ]
)

###############################
def _impl_boot_module(ctx):

    debug = False
    # if ctx.label.name in ["Stdlib"]:
    #     print("this: %s" % ctx.label) #.package + "/" + ctx.label.name)
    #     print("manifest: %s" % ctx.attr._manifest[BuildSettingInfo].value)
    #     debug = True
        # fail("x")

    tc = ctx.toolchains["//toolchain/type:bootstrap"]

    if tc.target_host in ["boot", "dev", "vm"]:
        # tool = tc.tool_runner
        ext = ".cmo"
    else:
        # tool = tc.compiler
        ext = ".cmx"

    ################################################################
    ################  OUTPUTS  ################

    pack_ns = False
    if hasattr(ctx.attr, "_pack_ns"):
        if ctx.attr._pack_ns:
            if ctx.attr._pack_ns[BuildSettingInfo].value:
                pack_ns = ctx.attr._pack_ns[BuildSettingInfo].value
                # print("GOT PACK NS: %s" % pack_ns)

    ################
    includes   = []
    # default_outputs    = [] # just the cmx/cmo files, for efaultInfo
    action_outputs   = [] # .cmx, .cmi, .o
    # direct_linkargs = []
    # old_cmi = None

    ## module name is derived from sigfile name, so start with sig
    # if we have an input cmi, we will pass it on as Provider output,
    # but it is not an output of this action- do NOT add incoming cmi
    # to action outputs.

    # WARNING: When both .mli and .ml are inputs, '-o' is unavailable:
    # ocaml will write the output to the directory containing the
    # source files. This will NOT be the directory for output files
    # made with declare_file. There is no way that I know of to tell
    # the compiler to write outputs to some other directory. So if
    # both .mli and .ml are inputs, we need to copy/move/link the
    # output files to the correct (Bazel) output dir. Sadly, the
    # compile action will fail before we can do that, since it's
    # outputs will be in the wrong place.

    module_name = None
    mlifile = None
    cmifile = None
    sig_src = None

    ## get_module_name decides if this module is in a namespace
    ## and if so adds ns prefix
    (from_name, ns, module_name) = get_module_name(ctx, ctx.file.struct)
    # print("module_name: %s" % module_name)
    # print("ns: %s" % ns)

    sig_inputs = []
    if ctx.attr.sig:
        if ctx.file.sig.is_source:
            # need to symlink .mli, to match symlink of .ml
            sig_src = ctx.actions.declare_file(
                tmpdir + module_name + ".mli"
            )
            sig_inputs.append(sig_src)
            ctx.actions.symlink(output = sig_src,
                                target_file = ctx.file.sig)

            action_output_cmi = ctx.actions.declare_file(tmpdir + module_name + ".cmi")
            action_outputs.append(action_output_cmi)
            provider_output_cmi = action_output_cmi
            mli_dir = None
        elif OcamlSignatureProvider in ctx.attr.sig:
            sigProvider = ctx.attr.sig[OcamlSignatureProvider]
            provider_output_cmi = sigProvider.cmi
            provider_output_mli = sigProvider.mli
            sig_inputs.append(provider_output_cmi)
            sig_inputs.append(provider_output_mli)
            mli_dir = paths.dirname(provider_output_mli.short_path)
        else:
            fail("ctx.file.sig without OcamlSignatureProvider")

    else: ## no sig, compiler will generate .cmi
        action_output_cmi = ctx.actions.declare_file(tmpdir + module_name + ".cmi")
        action_outputs.append(action_output_cmi)
        provider_output_cmi = action_output_cmi
        mli_dir = None

    ## struct: put in same dir as mli/cmi, rename if namespaced
    if from_name == module_name:  ## not namespaced
        # if ctx.label.name == "CamlinternalFormatBasics":
            # print("NOT NAMESPACED")
            # print("cmi is_source? %s" % provider_output_cmi.is_source)
        if ctx.file.struct.is_source:
            # structfile in src dir, make sure in same dir as sig
            if ctx.file.sig:
                if ctx.file.sig.is_source:
                    in_structfile = ctx.actions.declare_file(tmpdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                else: # sig file is compiled .cmo
                    in_structfile = ctx.actions.declare_file(tmpdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
            else: # no sig
                in_structfile = ctx.file.struct
        else: # structfile is generated, e.g. by ocamllex or a genrule.
            # make sure it's in same dir as mli/cmi IF we have ctx.file.sig
            if ctx.file.sig:
                if paths.dirname(ctx.file.struct.short_path) != mli_dir:
                    in_structfile = ctx.actions.declare_file(
                        tmpdir + module_name + ".ml") # ctx.file.struct.basename)
                    ctx.actions.symlink(
                        output = in_structfile,
                        target_file = ctx.file.struct)
                    if debug:
                        print("symlinked {src} => {dst}".format(
                            src = ctx.file.struct, dst = in_structfile))
                else:
                    if debug:
                        print("not symlinking src: {src}".format(
                            src = ctx.file.struct.path))
                    in_structfile = ctx.file.struct
            else:  ## no sig file
                in_structfile = ctx.file.struct
    else:  ## namespaced
        in_structfile = ctx.actions.declare_file(tmpdir + module_name + ".ml")
        ctx.actions.symlink(
            output = in_structfile, target_file = ctx.file.struct
        )

    # if ctx.label.name == "CamlinternalFormatBasics":
    #     fail("X")

    out_cm_ = ctx.actions.declare_file(tmpdir + module_name + ext)
    # sibling = new_cmi) # fname)
    if debug:
        print("OUT_CM_: %s" % out_cm_.path)
    action_outputs.append(out_cm_)
    # direct_linkargs.append(out_cm_)
    # default_outputs.append(out_cm_)

    if not tc.target_host:
        # if not ctx.attr._rule.startswith("bootstrap"):
        out_o = ctx.actions.declare_file(tmpdir + module_name + ".o",
                                         sibling = out_cm_)
        action_outputs.append(out_o)
        # direct_linkargs.append(out_o)

    ################################################################
    ################  DEPS  ################
    depsets = new_deps_aggregator()

    # if ctx.attr._manifest[BuildSettingInfo].value:
    #     manifest = ctx.attr._manifest[BuildSettingInfo].value
    # else:
    manifest = []

    # if ctx.label.name == "Stdlib":
    #     print("Stdlib manifest: %s" % manifest)
        # fail("X")

    if ctx.attr.sig: #FIXME
        if not ctx.file.sig.is_source:
            depsets = aggregate_deps(ctx, ctx.attr.sig, depsets, manifest)
        else:
            depsets.deps.mli.append(ctx.file.sig)

    for dep in ctx.attr.deps:
        depsets = aggregate_deps(ctx, dep, depsets, manifest)
        ## Now what if this module is to be archived, and this dep is
        ## a sibling submodule? If it is a sibling it goes in
        ## archived_cmx, or if it is a cmo we drop it since it will be
        ## archived. If it is not a sibling it goes in cli_link_deps.

    ## The problem is we do not know where whether this module is to
    ## be archived. It is the boot_archive rule that must decide how
    ## to distribute its deps. Which means we have no way of knowing
    ## if this module should go in cli_link_deps.

    ## So we do not include this module in its own BootInfo, only in
    ## DefaultInfo. Clients decide what to do with it. An archive will
    ## put it but not its cli_link_deps on the archive cmd line. An
    ## executable will put it and its cli_link_deps on the cmd line.

    ## An archive must also filter this module's cli_link_deps to
    ## remove sibling submodules that it archives beside this module.

    ## So this module should put the cli_link_deps of all of its deps
    ## into its own BootInfo.cli_link_deps, and leave it to client
    ## archives and execs to sort them out.

    ## And since clients filter cli_link_deps, we can add this module
    ## to its own BootInfo.cli_link_deps.

    ## It would be better to avoid filtering, but that does not seem
    ## possible, since a sibling dependency could be indirect. The
    ## only way to avoid filtering would be to mark sibling deps in
    ## some way.

    ## We could put a transition on the archive rule and have it
    ## record its manifest in the configuration. Then each module
    ## could check the manifest to decide if it is being archived.

    # if ctx.label.name == "Stdlib":
    #     print("depsets: %s" % depsets)
    #     fail("x")

    ## build depsets here, use for OcamlProvider and OutputGroupInfo
    sigs_depset = depset(
        order=dsorder,
        direct = [provider_output_cmi],
        transitive = [merge_depsets(depsets, "sigs")])

    cli_link_deps_depset = depset(
        order = dsorder,
        direct = [out_cm_],
        transitive = [merge_depsets(depsets, "cli_link_deps")]
    )

    afiles_depset  = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "afiles")]
    )

    archived_cmx_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "archived_cmx")]
    )

    paths_depset  = depset(
        order = dsorder,
        direct = [out_cm_.dirname],
        transitive = [merge_depsets(depsets, "paths")]
    )

    ################################################################
    ################
    # indirect_ppx_codep_depsets      = []
    # indirect_ppx_codep_path_depsets = []
    indirect_cc_deps  = {}

    ns_resolver = False
    ns_resolver_files = []
    if ctx.attr.ns:
        ns_resolver = ctx.attr.ns
        ns_resolver_files = ctx.files.ns
    # print("NS_RESOLVER: %s" % ns_resolver)

    # paths_direct = [out_cm_.dirname] # d.dirname for d in direct_linkargs]
    # if ns_resolver:
    #     paths_direct.extend([f.dirname for f in ns_resolver_files])
    # print("RESOLVER PATHS: %s" % paths_direct)

    #########################
    args = ctx.actions.args()

    if tc.target_host in ["boot", "vm"]:
        # if stage == bootstrap:
        args.add_all(["-use-prims", tc.primitives])

    if not ctx.attr.nocopts:
        args.add_all(tc.copts)

    _options = get_options(ctx.attr._rule, ctx)
    args.add_all(_options)

    ################ Direct Deps ################

    includes.extend(paths_depset.to_list())

    # if hasattr(ctx.attr._ns_resolver[OcamlNsResolverProvider], "resolver"):
    if ns_resolver:
        args.add("-no-alias-deps")
        args.add("-open", ns)

    inputs_depset = depset(
        order = dsorder,
        direct = []
        + sig_inputs
        + [in_structfile]
        + depsets.deps.mli
        ,
        transitive = []
        + [merge_depsets(depsets, "sigs"),
           merge_depsets(depsets, "cli_link_deps")]
        + [archived_cmx_depset]
        # + ns_deps
        # + bottomup_ns_inputs
    )
    # if ctx.label.name == "Misc":
    #     print("inputs_depset: %s" % inputs_depset)

    if pack_ns:
        args.add("-for-pack", pack_ns)

    if sig_src:
        includes.append(sig_src.dirname)

    args.add_all(includes, before_each="-I", uniquify = True)

    args.add("-c")

    if sig_src:
        args.add(sig_src)
        args.add(in_structfile) # structfile)
    else:
        args.add("-impl", in_structfile) # structfile)
        args.add("-o", out_cm_)

    ################
    ctx.actions.run(
        # env = env,
        executable = tc.compiler[DefaultInfo].files_to_run,
        # executable = tool,
        arguments = [args],
        inputs    = inputs_depset,
        outputs   = action_outputs,
        tools = [tc.compiler[DefaultInfo].files_to_run],
        # tools = [tc.tool_runner, tc.compiler],
        # tools = [tool] + tool_args,
        mnemonic = "CompileBootstrapModule",
        progress_message = "{mode} compiling {rule}: {ws}//{pkg}:{tgt}".format(
            mode = tc.build_host + ">" + tc.target_host,
            rule=ctx.attr._rule,
            ws  = ctx.label.workspace_name if ctx.label.workspace_name else "", ## ctx.workspace_name,
            pkg = ctx.label.package,
            tgt=ctx.label.name,
        )
    )

    #############################################
    ################  PROVIDERS  ################

    default_depset = depset(
        order = dsorder,
        direct = [out_cm_], ## default_outputs,
        # transitive = [depset(direct=default_outputs)]
        # transitive = bottomup_ns_files + [depset(direct=default_outputs)]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )

    moduleInfo_depset = depset([provider_output_cmi, out_cm_])
    moduleInfo = ModuleInfo(
        sig    = provider_output_cmi,
        struct = out_cm_
    )

    bootProvider = BootInfo(
        sigs     = sigs_depset,
        cli_link_deps = cli_link_deps_depset,
        afiles   = afiles_depset,
        archived_cmx  = archived_cmx_depset,
        paths    = paths_depset,
    )

    providers = [
        defaultInfo,
        bootProvider,
        moduleInfo
    ]

    if ns_resolver:
        nsResolverProvider = OcamlNsResolverProvider(
            files = ctx.files.ns,
            paths = depset([d.dirname for d in ctx.attr.ns.files.to_list()])
        )
        # print("RESOLVER PROVIDER: %s" % nsResolverProvider)
        providers.append(nsResolverProvider)

    ################
    outputGroupInfo = OutputGroupInfo(
        cmi        = depset(direct=[provider_output_cmi]),
        module     = moduleInfo_depset
    )
    providers.append(outputGroupInfo)

    return providers

################################################################
################################
# rule_options = options("ocaml") ## we don't want global config defaults
# rule_options = options_module("ocaml")
# FIXME: no need for ppx support here
# rule_options.update(options_ppx)
## FIXME: bootstrap ns are bottomup, no need for this:
# rule_options.update(options_ns_opts("ocaml"))

####################
boot_module = rule(
    implementation = _impl_boot_module,
    doc = """Compiles an OCaml module. Provides: [ModuleInfo](providers_ocaml.md#ocamlmoduleprovider).

**CONFIGURABLE DEFAULTS** for rule `ocaml_module`

In addition to the [OCaml configurable defaults](#configdefs) that apply to all
`ocaml_*` rules, the following apply to this rule:

    """,
    attrs = dict(

        # _boot       = attr.label(
        #     default = "//bzl/toolchain:boot",
        # ),

        primitives = attr.label(
            allow_single_file = True,
        ),

        # _toolchain = attr.label(
        #     default = "//bzl/toolchain:tc"
        # ),

        _stage = attr.label(
            doc = "bootstrap stage",
            default = "//bzl:stage"
        ),

        opts = attr.string_list(
            doc = "List of OCaml options. Will override configurable default options."
        ),

        nocopts = attr.bool(
            doc = "to disable use toolchain's copts"
        ),

        ns = attr.label(
            doc = "Bottom-up namespacing",
            allow_single_file = True,
            mandatory = False
        ),

        struct = attr.label(
            doc = "A single module (struct) source file label.",
            mandatory = False, # pack libs may not need a src file
            allow_single_file = True # no constraints on extension
        ),

        _pack_ns = attr.label(
            doc = """Namepace name for use with -for-pack. Set by transition function.
""",
            # default = "//config/pack:ns"
        ),

        sig = attr.label(
            doc = "Single label of a target producing OcamlSignatureProvider (i.e. rule 'ocaml_signature'). Optional.",
            # cfg = compile_mode_out_transition,
            allow_single_file = True, # [".cmi"],
            ## only allow compiled sigs
            # providers = [[OcamlSignatureProvider]],
        ),

        ################
        deps = attr.label_list(
            doc = "List of OCaml dependencies.",
            providers = [[OcamlArchiveProvider],
                         [OcamlLibraryMarker],
                         [ModuleInfo],
                         [OcamlNsMarker],
                         [OcamlSignatureProvider],
                         [CcInfo]],
            # transition undoes changes that may have been made by ns_lib
            # cfg = compile_deps_out_transition,
        ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),

        deps_runtime = attr.label_list(
            doc = "Deps needed at runtime, but not build time. E.g. .cmxs plugins.",
            allow_files = True,
        ),

        data = attr.label_list(
            allow_files = True,
            doc = "Runtime dependencies: list of labels of data files needed by this module at runtime."
        ),

        _manifest = attr.label(
            default = "//config:manifest"
        ),

        ################
        cc_deps = attr.label_keyed_string_dict(
            doc = """Dictionary specifying C/C++ library dependencies. Key: a target label; value: a linkmode string, which determines which file to link. Valid linkmodes: 'default', 'static', 'dynamic', 'shared' (synonym for 'dynamic'). For more information see [CC Dependencies: Linkmode](../ug/cc_deps.md#linkmode).
            """,
            # providers = since this is a dictionary depset, no providers
            ## but the keys must have CcInfo providers, check at build time
            # cfg = ocaml_module_cc_deps_out_transition
        ),

        _verbose = attr.label(default = "//config:verbose"),

        # _sdkpath = attr.label(
        #     default = Label("@ocaml//:sdkpath") # ppx also uses this
        # ),

        ## FIXME: don't need this for bootstrapping
        # _ns_resolver = attr.label(
        #     doc = "Experimental",
        #     providers = [OcamlNsResolverProvider],
        #     default = "@ocaml//bootstrap/ns:resolver",
        # ),

        # _warnings = attr.label(
        # ),

        _rule = attr.string( default = "boot_module" ),
        # _allowlist_function_transition = attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        # ),
    ),
    # cfg = compile_mode_in_transition,
    provides = [BootInfo,ModuleInfo],
    executable = False,
    fragments = ["platform", "cpp"],
    host_fragments = ["platform",  "cpp"],
    incompatible_use_toolchain_transition = True,
    toolchains = ["//toolchain/type:bootstrap",
                  # "//toolchain/type:profile",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
