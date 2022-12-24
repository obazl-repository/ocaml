load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:collections.bzl", "collections")

load("@bazel_skylib//lib:paths.bzl", "paths")

load("//bzl:providers.bzl",
     "BootInfo", "DumpInfo", "ModuleInfo", "NsResolverInfo",
     "new_deps_aggregator", "OcamlSignatureProvider")

load("//bzl:functions.bzl", "get_module_name")

load("//bzl/rules/common:DEPS.bzl", "aggregate_deps", "merge_depsets")
load("//bzl/rules/common:impl_common.bzl", "dsorder")
load("//bzl/rules/common:options.bzl", "get_options")

load("//bzl/attrs:module_attrs.bzl", "module_attrs")
load("//bzl/actions:module_impl.bzl", "module_impl")

load("//bzl/actions:BUILD.bzl", "progress_msg", "get_build_executor")

######################
def _compile_fail_test(ctx):

    (this, extension) = paths.split_extension(ctx.file.struct.basename)
    module_name = this[:1].capitalize() + this[1:]

    basename = ctx.label.name
    from_name = basename[:1].capitalize() + basename[1:]

    debug = False
    debug_bootstrap = False

    # if ctx.label.name in ["Stdlib"]:
    #     print("this: %s" % ctx.label) #.package + "/" + ctx.label.name)
    #     print("manifest: %s" % ctx.attr._manifest[BuildSettingInfo].value)
    #     debug = True
        # fail("x")

    # tc = ctx.exec_groups[ctx.attr._stage].toolchains[
    #     "//toolchain/type:{}".format(ctx.attr._stage)
    # ]
    # tc = ctx.exec_groups["boot"].toolchains["//toolchain/type:ocaml"]

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    # workdir = tc.workdir
    # (target_executor, target_emitter,
    #  config_executor, config_emitter,
    #  workdir) = get_workdir(ctx, tc)

    # if target_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

    if tc.config_executor[BuildSettingInfo].value in ["boot", "baseline", "vm"]:
        ext = ".cmo"
    else:
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
    default_outputs    = [] # .cmo or .cmx+.o, for DefaultInfo
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

    mlifile = None
    cmifile = None
    sig_src = None

    sig_inputs = []
    if ctx.attr.sig:
        if ctx.file.sig.is_source:
            # need to symlink .mli, to match symlink of .ml
            sig_src = ctx.actions.declare_file(
                tc.workdir + module_name + ".mli"
            )
            sig_inputs.append(sig_src)
            ctx.actions.symlink(output = sig_src,
                                target_file = ctx.file.sig)

            # action_output_cmi = ctx.actions.declare_file(tc.workdir + module_name + ".cmi")
            action_output_cmi = tc.workdir + module_name + ".cmi"
            action_outputs.append(action_output_cmi)
            provider_output_cmi = action_output_cmi
            mli_dir = None
        elif OcamlSignatureProvider in ctx.attr.sig:
            # in case sig was compiled into a tmp dir (e.g. _build) to avoid nameclash,
            # symlink here
            sigProvider = ctx.attr.sig[OcamlSignatureProvider]
            provider_output_cmi = sigProvider.cmi
            provider_output_mli = sigProvider.mli
            sig_inputs.append(provider_output_cmi)
            sig_inputs.append(provider_output_mli)
            mli_dir = paths.dirname(provider_output_mli.short_path)
            ## force module name to match compiled cmi
            extlen = len(ctx.file.sig.extension)
            module_name = ctx.file.sig.basename[:-(extlen + 1)]
        else:
            # generated sigfile, e.g. by cp, rename, link
            # need to symlink .mli, to match symlink of .ml
            # sig_src = ctx.actions.declare_file(
            sig_src = tc.workdir + module_name + ".mli"
            sig_inputs.append(sig_src)
            ctx.actions.symlink(output = sig_src,
                                target_file = ctx.file.sig)

            # action_output_cmi = ctx.actions.declare_file(tc.workdir + module_name + ".cmi")
            action_output_cmi = tc.workdir + module_name + ".cmi"
            action_outputs.append(action_output_cmi)
            provider_output_cmi = action_output_cmi
            mli_dir = None
    else: ## no sig
        # compiler will generate .cmi
        # put src in tc.workdir as well
        # action_output_cmi = ctx.actions.declare_file(tc.workdir + module_name + ".cmi")
        action_output_cmi = tc.workdir + module_name + ".cmi"
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
                    in_structfile = ctx.actions.declare_file(tc.workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                elif OcamlSignatureProvider in ctx.attr.sig:
                    # sig file is compiled .cmo
                    # force name of module to match compiled sig
                    extlen = len(ctx.file.sig.extension)
                    module_name = ctx.file.sig.basename[:-(extlen + 1)]
                    in_structfile = ctx.actions.declare_file(tc.workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                    # print("lbl: %s" % ctx.label)
                    # print("IN STRUCTFILE: %s" % in_structfile)
                else:
                    # generated sigfile
                    in_structfile = ctx.actions.declare_file(tc.workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
            else: # no sig - cmi will be generated, put both in tc.workdir
                # in_structfile = ctx.file.struct
                in_structfile = ctx.actions.declare_file(tc.workdir + ctx.file.struct.basename)
                ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)

        else: # structfile is generated, e.g. by ocamllex or a genrule.
            # make sure it's in same dir as mli/cmi IF we have ctx.file.sig
            if ctx.file.sig:
                if ctx.file.sig.is_source:
                    in_structfile = ctx.actions.declare_file(tc.workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                    if paths.dirname(ctx.file.struct.short_path) != mli_dir:
                        in_structfile = ctx.actions.declare_file(
                            tc.workdir + module_name + ".ml") # ctx.file.struct.basename)
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
                else: # sig file is compiled .cmo
                    # print("xxxxxxxxxxxxxxxx %s" % ctx.label)
                    # force name of module to match compiled sig
                    extlen = len(ctx.file.sig.extension)
                    module_name = ctx.file.sig.basename[:-(extlen + 1)]
                    in_structfile = ctx.actions.declare_file(tc.workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                    # print("lbl: %s" % ctx.label)
                    # print("IN STRUCTFILE: %s" % in_structfile)
            else:  ## no sig file, will emit cmi, put both in tc.workdir
                in_structfile = ctx.actions.declare_file(tc.workdir + module_name + ".ml")
                ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
    else:  ## namespaced
        in_structfile = ctx.actions.declare_file(tc.workdir + module_name + ".ml")
        ctx.actions.symlink(
            output = in_structfile, target_file = ctx.file.struct
        )

    direct_inputs = [in_structfile]

    # out_cm_ = ctx.actions.declare_file(tc.workdir + module_name + ext)
    out_cm_ = tc.workdir + module_name + ext
    # sibling = new_cmi) # fname)
    if debug:
        print("OUT_CM_: %s" % out_cm_.path)
    action_outputs.append(out_cm_)
    # direct_linkargs.append(out_cm_)
    default_outputs.append(out_cm_)

    (_options, cancel_opts) = get_options(ctx.attr._rule, ctx)
    if ("-bin-annot" in _options):
        _options.remove("-bin-annot")
         # or ("-bin-annot" in tc.copts) ):

        # out_cmt = ctx.actions.declare_file(tc.workdir + module_name + ".cmt")
        # out_cmt = tc.workdir + module_name + ".cmt"
        # action_outputs.append(out_cmt)
        # default_outputs.append(out_cmt)
    else:
        out_cmt = None

    moduleInfo_ofile = None
    if ext == ".cmx":
        # if not ctx.attr._rule.startswith("bootstrap"):
        # out_o = ctx.actions.declare_file(tc.workdir + module_name + ".o")
        out_o = tc.workdir + module_name + ".o"
                                         # sibling = out_cm_)
        action_outputs.append(out_o)
        default_outputs.append(out_o)
        moduleInfo_ofile = out_o
        # print("OUT_O: %s" % out_o)
        # direct_linkargs.append(out_o)

    if ((hasattr(ctx.attr, "dump") and len(ctx.attr.dump) > 0)
        or hasattr(ctx.attr, "_lambda_expect_test")):

        out_dump = ctx.actions.declare_file(
            out_cm_.basename + ".dump",
            sibling = out_cm_,
        )
        action_outputs.append(out_dump)

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
        if OcamlSignatureProvider in ctx.attr.sig:
            depsets = aggregate_deps(ctx, ctx.attr.sig, depsets, manifest)
        else:
            # either is_source or generated
            depsets.deps.mli.append(ctx.file.sig)
            # FIXME: add cmi to depsets
            if provider_output_cmi:
                depsets.deps.cmi.append(provider_output_cmi)

    for dep in ctx.attr.deps:
        depsets = aggregate_deps(ctx, dep, depsets, manifest)
        ## Now what if this module is to be archived, and this dep is
        ## a sibling submodule? If it is a sibling it goes in
        ## archived_cmx, or if it is a cmo we drop it since it will be
        ## archived. If it is not a sibling it goes in cli_link_deps.

    #FIXME: add this path (see below)

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
        # direct = [provider_output_cmi],
        transitive = [merge_depsets(depsets, "sigs")])

    cli_link_deps_depset = depset(
        order = dsorder,
        # direct = [out_cm_],
        transitive = [merge_depsets(depsets, "cli_link_deps")]
    )

    afiles_depset  = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "afiles")]
    )

    if ext == ".cmx":
        ofiles_depset  = depset(
            order=dsorder,
            # direct = [out_o],
            transitive = [merge_depsets(depsets, "ofiles")]
        )
    else:
        ofiles_depset  = depset(
            order=dsorder,
            transitive = [merge_depsets(depsets, "ofiles")]
        )

    archived_cmx_depset = depset(
        order=dsorder,
        transitive = [merge_depsets(depsets, "archived_cmx")]
    )

    paths_depset  = depset(
        order = dsorder,
        # direct = [out_cm_.dirname],
        transitive = [merge_depsets(depsets, "paths")]
    )

    ################################################################
    ################
    # indirect_ppx_codep_depsets      = []
    # indirect_ppx_codep_path_depsets = []
    indirect_cc_deps  = {}

    #########################
    args = [] ## ctx.actions.args()

    # args.append("echo PWD: $PWD;")

    executable = None
    if tc.protocol == "dev":
        ocamlrun = None
        effective_compiler = tc.compiler
    else:
        ocamlrun = tc.compiler[DefaultInfo].default_runfiles.files.to_list()[0]
        effective_compiler = tc.compiler[DefaultInfo].files_to_run.executable

    build_executor = get_build_executor(tc)

    runfiles = []

    if build_executor == "vm":
        executable = ocamlrun
        args.append(executable)
        args.append(effective_compiler.short_path)
        runfiles.extend([executable, effective_compiler])
    else:
        executable = effective_compiler
        args.append(executable.short_path)
        runfiles.extend([executable])

    # ocamlrun = tc.compiler[DefaultInfo].default_runfiles.files.to_list()[0]
    # effective_compiler = tc.compiler[DefaultInfo].files_to_run.executable

    # if (target_executor == "unspecified"):
    #     if (config_executor == "sys"):
    #         if config_emitter == "sys":
    #             # ss built from ocamlopt.byte
    #             executable = ocamlrun
    #             args.append(effective_compiler.path)
    #         else:
    #             # sv built from ocamlopt.opt
    #             executable = effective_compiler
    #     else:
    #         executable = ocamlrun
    #         args.append(effective_compiler.path)

    # elif target_executor in ["boot", "vm"]:
    #         executable = ocamlrun
    #         args.append(effective_compiler.path)

    # elif (target_executor == "sys" and target_emitter == "sys"):
    #     ## ss always built by vs (ocamlopt.byte)
    #     executable = ocamlrun
    #     args.append(effective_compiler.path)

    # elif (target_executor == "sys" and target_emitter == "vm"):
    #     ## sv built by ss
    #     executable = effective_compiler

    # if ctx.label.name == "CamlinternalFormatBasics":
    #     print("lbl: %s" % ctx.label)
    #     print("ocamlrun: %s" % ocamlrun)
    #     print("effective_compiler: %s" % effective_compiler.path)
    #     print("executable: %s" % executable.path)

    ## FIXME: -use-prims not needed for compilation?
    # if ext == ".cmo":
    #     if ctx.attr.use_prims == True:
    #         args.append_all(["-use-prims", ctx.file._primitives.path])
    #     else:
    #         if ctx.attr._rule in ["stdlib_module", "stdlib_signature"]:
    #             args.append_all(["-use-prims", ctx.file._primitives.path])
    #         else:
    #             if ctx.attr._use_prims[BuildSettingInfo].value:
    #                 if not "-no-use-prims" in ctx.attr.opts:
    #                     args.append_all(["-use-prims", ctx.file._primitives.path])
    #             else:
    #                 if  "-use-prims" in ctx.attr.opts:
    #                     args.append_all(["-use-prims", ctx.file._primitives.path])

    resolver = None
    resolver_deps = []
    if hasattr(ctx.attr, "_resolver"):
        resolver = ctx.attr._resolver[ModuleInfo]
        resolver_deps.append(resolver.sig)
        resolver_deps.append(resolver.struct)
        nsname = resolver.struct.basename[:-4]
        args.extend(["-open", nsname])

    if hasattr(ctx.attr, "stdlib_primitives"): # test rules
        if ctx.attr.stdlib_primitives:
            includes.append("stdlib/_dev_boot")
            includes.append(ctx.attr._stdlib[BootInfo].sigs.to_list()[0].dirname)
            # direct_inputs.append(ctx.attr._stdlib[ModuleInfo].sig)
            # direct_inputs.append(ctx.attr._stdlib[ModuleInfo].struct)

    if hasattr(ctx.attr, "_opts"):
        args.extend(ctx.attr._opts)

    # if not ctx.attr.nocopts:
    #     args.extend(tc.copts)

    args.extend(tc.structopts)

    args.extend(tc.warnings[BuildSettingInfo].value)

    for w in ctx.attr.warnings:
        args.extend(["-w",
                      w if w.startswith("-")
                      else "-" + w])

    for dep in ctx.attr.deps:
        if hasattr(ctx.attr, "stdlib_primitives"): # test rules
            if dep.label.package == "stdlib":
                if "-nopervasives" in _options:
                    _options.remove("-nopervasives")
    args.extend(_options)

    #FIXME: make a function for the dump stuff
    if hasattr(ctx.attr, "_lambda_expect_test"):
        for arg in ctx.attr._lambda_expect_test:
            args.append(arg)

    elif hasattr(ctx.attr, "dump"): # test rules w/explicit dump attr
        if len(ctx.attr.dump) > 0:
            args.append("-dump-into-file")
        for d in ctx.attr.dump:
            if d == "source":
                args.append("-dsource")
            if d == "parsetree":
                args.append("-dparsetree")
            if d == "typedtree":
                args.append("-dtypedtree")
            if d == "shape":
                args.append("-dshape")
            if d == "rawlambda":
                args.append("-drawlambda")
            if d == "lambda":
                args.append("-dlambda")
            if d == "rawclambda":
                args.append("-drawclambda")
            if d == "rawflambda":
                args.append("-drawflambda")
            if d == "flambda":
                args.append("-dflambda")
            if d == "flambda-let":
                args.append("-dflambda-let")
            if d == "flambda-verbose":
                args.append("-dflambda-verbose")

            if d == "instruction-selection":
                args.append("-dsel")

            if ext == ".cmo":
                if d == "instr":
                    args.append("-dinstr")

            if ext == ".cmx":
                if d == "clambda":
                    args.append("-dclambda")
                if d == "cmm":
                    args.append("-dcmm")

    merged_input_depsets = [merge_depsets(depsets, "sigs")]
    if ext == ".cmx":
        merged_input_depsets.append(merge_depsets(depsets, "cli_link_deps"))
        merged_input_depsets.append(archived_cmx_depset)

    # OCaml srcs use two namespaces, Stdlib and Dynlink_compilerlibs
    if hasattr(ctx.attr, "_resolver"):
        includes.append(ctx.attr._resolver[ModuleInfo].sig.dirname)

    ################ Direct Deps ################

    #NB: this will (may?) put stdlib in search path, even if target
    # does not depend on stdlib. that's ok because target may depend
    # on primitives that are exported by //stdlib:Stdlib
    includes.extend(paths_depset.to_list())

    inputs_depset = depset(
        order = dsorder,
        direct = []
        + sig_inputs
        + direct_inputs
        + depsets.deps.mli
        + resolver_deps
        + [effective_compiler]
        ,
        transitive = []
        + merged_input_depsets
        # + ns_deps
        # + bottomup_ns_inputs
    )
    # if ctx.label.name == "Misc":
    #     print("inputs_depset: %s" % inputs_depset)

    if pack_ns:
        args.append("-for-pack", pack_ns)

    if sig_src:
        includes.append(sig_src.dirname)

    for inc in collections.uniq(includes):
        args.extend(["-I", inc])

    args.append("-c")

    if sig_src:
        args.append(sig_src)
        args.append(in_structfile.path) # structfile)
    else:
        args.extend(["-impl", ctx.file.struct.short_path])
                     ## in_structfile.short_path]) # structfile)
        args.extend(["-o", out_cm_])

    dump = ctx.file.struct.basename + ".dump"

    args.extend([">", dump + ";"])

    ## now diff the output:
    args.extend(["diff", "-w", dump, ctx.file.expect.path])

    script = ctx.actions.declare_file(ctx.attr.name + ".compile.sh")
    ctx.actions.write(
        output = script,
        content = " ".join(args),
        is_executable = True
    )

    ################################################################
    # runfiles = []
    # if ocamlrun:
    #     runfiles = [tc.compiler[DefaultInfo].default_runfiles.files]
    # print("runfiles tc.compiler: %s" % tc.compiler)
    # print("runfiles tc.ocamlrun: %s" % tc.ocamlrun)
    # if tc.protocol == "dev":
    #     runfiles.append(tc.ocamlrun)
    # elif ocamlrun:
    #     runfiles.extend(tc.compiler[DefaultInfo].default_runfiles.files.to_list())

    print("EXE runfiles: %s" % runfiles)

    print("SIGS: %s" % ctx.attr._stdlib[BootInfo].sigs)

    # print("DATA: %s" % ctx.files.data)
    myrunfiles = ctx.runfiles(
        files = [ctx.file.struct, ctx.file.expect],
        transitive_files =  depset(
            transitive = [
                depset(direct=runfiles),
                depset(direct=ctx.files.data),
                ctx.attr._stdlib[BootInfo].sigs,
                ctx.attr._stdlib[BootInfo].cli_link_deps,
            ]
            # direct=compiler_runfiles,
            # transitive = [depset(
            #     # [ctx.file._std_exit, ctx.file._stdlib]
            # )]
        )
    )

    ################################################################
    defaultInfo = DefaultInfo(
        executable = script,
        runfiles   = myrunfiles
    )
    providers = [defaultInfo]

    return providers

####################
compile_fail_test = rule(
    implementation = _compile_fail_test,
    doc = "Compiles a module with the bootstrap compiler.",
    attrs = dict(
        module_attrs(),
        expect = attr.label(
            mandatory = True,
            allow_single_file = True
        ),
        stdlib_primitives = attr.bool(default = True),
        _stdlib = attr.label(
            doc = "The commpiler always opens Stdlib, so everything depends on it.",

            default = "//stdlib"
        ),
        _rule = attr.string( default = "compile_fail_test" ),
    ),
    # cfg = compile_mode_in_transition,
    test = True,
    toolchains = ["//toolchain/type:ocaml",
                  ## //toolchain/type:profile,",
                  "@bazel_tools//tools/cpp:toolchain_type"]
)
