load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

load("//toolchain/adapter:BUILD.bzl",
     "tc_compiler", "tc_executable", "tc_tool_arg",
     "tc_build_executor",
     "tc_workdir")

load(":BUILD.bzl", "progress_msg", "get_build_executor")

load("//bzl:providers.bzl",
     "BootInfo", "DumpInfo", "ModuleInfo", "NsResolverInfo",
     "new_deps_aggregator", "OcamlSignatureProvider")

load("//bzl:functions.bzl", "get_module_name") #, "get_workdir")
load("//bzl/rules/common:DEPS.bzl", "aggregate_deps", "merge_depsets")
load("//bzl/rules/common:impl_common.bzl", "dsorder")
load("//bzl/rules/common:options.bzl", "get_options")

##############################################
def gen_compile_script(ctx, executable, args):

    script = ctx.actions.declare_file(ctx.attr.name + ".compile.sh")

    ctx.actions.write(
        output = script,
        content = args,
        is_executable = True
    )

    return script

#####################
def module_impl(ctx, module_name):

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

    cc_toolchain = find_cpp_toolchain(ctx)

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc_workdir(tc)

    # (target_executor, # x
    #  target_emitter,  # x
    #  config_executor, # o
    #  config_emitter,  # x
    #  workdir
    #  ) = get_workdir(ctx, tc)

    # (ocamlrun, # x
    #  executable, # in actions.run
    #  build_executor, # x for setting executable
    #  target_executor # x
    #  ) = configure_action(ctx, tc)

    #########################
    args = ctx.actions.args()

    toolarg = tc_tool_arg(tc)
    if toolarg:
        args.add(toolarg.path)
        toolarg_input = [toolarg]
    else:
        toolarg_input = []

    # executable = None
    # if tc.dev:
    #     ocamlrun = None
    #     effective_compiler = tc.compiler
    # else:
    #     ocamlrun = tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list()[0]
    #     effective_compiler = tc_compiler(tc)[DefaultInfo].files_to_run.executable

    # build_executor = get_build_executor(tc)
    # print("BX: %s" % build_executor)
    # print("TX: %s" % config_executor)
    # print("ef: %s" % effective_compiler)

    # if build_executor == "vm":
    #     executable = ocamlrun
    #     args.add(effective_compiler.path)
    #     if config_executor in ["sys"]:
    #         ext = ".cmx"
    #     else:
    #         ext = ".cmo"
    # else:
    #     executable = effective_compiler
    #     ext = ".cmx"

    if tc.config_executor[BuildSettingInfo].value in ["boot", "baseline", "vm"]:
        ext = ".cmo"
    else:
        ext = ".cmx"
        args.add("-S") # testing - retain asm code

    # if target_executor == "unspecified":
    #     executor = config_executor
    #     emitter  = config_emitter
    # else:
    #     executor = target_executor
    #     emitter  = target_emitter

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
                workdir + module_name + ".mli"
            )
            sig_inputs.append(sig_src)
            ctx.actions.symlink(output = sig_src,
                                target_file = ctx.file.sig)

            action_output_cmi = ctx.actions.declare_file(workdir + module_name + ".cmi")
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
            sig_src = ctx.actions.declare_file(
                workdir + module_name + ".mli"
            )
            sig_inputs.append(sig_src)
            ctx.actions.symlink(output = sig_src,
                                target_file = ctx.file.sig)

            action_output_cmi = ctx.actions.declare_file(workdir + module_name + ".cmi")
            action_outputs.append(action_output_cmi)
            provider_output_cmi = action_output_cmi
            mli_dir = None
    else: ## no sig
        # compiler will generate .cmi
        # put src in workdir as well
        action_output_cmi = ctx.actions.declare_file(workdir + module_name + ".cmi")
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
                    in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                elif OcamlSignatureProvider in ctx.attr.sig:
                    # sig file is compiled .cmo
                    # force name of module to match compiled sig
                    extlen = len(ctx.file.sig.extension)
                    module_name = ctx.file.sig.basename[:-(extlen + 1)]
                    in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                    # print("lbl: %s" % ctx.label)
                    # print("IN STRUCTFILE: %s" % in_structfile)
                else:
                    # generated sigfile
                    in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
            else: # no sig - cmi will be generated, put both in workdir
                # in_structfile = ctx.file.struct
                in_structfile = ctx.actions.declare_file(workdir + ctx.file.struct.basename)
                ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)

        else: # structfile is generated, e.g. by ocamllex or a genrule.
            # make sure it's in same dir as mli/cmi IF we have ctx.file.sig
            if ctx.file.sig:
                if ctx.file.sig.is_source:
                    in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                    if paths.dirname(ctx.file.struct.short_path) != mli_dir:
                        in_structfile = ctx.actions.declare_file(
                            workdir + module_name + ".ml") # ctx.file.struct.basename)
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
                    in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
                    ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
                    # print("lbl: %s" % ctx.label)
                    # print("IN STRUCTFILE: %s" % in_structfile)
            else:  ## no sig file, will emit cmi, put both in workdir
                in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
                ctx.actions.symlink(output = in_structfile, target_file = ctx.file.struct)
    else:  ## namespaced
        in_structfile = ctx.actions.declare_file(workdir + module_name + ".ml")
        ctx.actions.symlink(
            output = in_structfile, target_file = ctx.file.struct
        )

    direct_inputs = [in_structfile]

    out_cm_ = ctx.actions.declare_file(workdir + module_name + ext)
    # sibling = new_cmi) # fname)
    if debug:
        print("OUT_CM_: %s" % out_cm_.path)
    action_outputs.append(out_cm_)
    # direct_linkargs.append(out_cm_)
    default_outputs.append(out_cm_)

    _options = get_options(ctx.attr._rule, ctx)
    if ( ("-bin-annot" in _options)
         or ("-bin-annot" in tc.copts) ):
        out_cmt = ctx.actions.declare_file(workdir + module_name + ".cmt")
        action_outputs.append(out_cmt)
        default_outputs.append(out_cmt)
    else:
        out_cmt = None

    moduleInfo_ofile = None
    if ext == ".cmx":
        # if not ctx.attr._rule.startswith("bootstrap"):
        out_o = ctx.actions.declare_file(workdir + module_name + ".o")
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

    if ext == ".cmx":
        ofiles_depset  = depset(
            order=dsorder,
            direct = [out_o],
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
        direct = [out_cm_.dirname],
        transitive = [merge_depsets(depsets, "paths")]
    )

    ################################################################
    ################
    # indirect_ppx_codep_depsets      = []
    # indirect_ppx_codep_path_depsets = []
    indirect_cc_deps  = {}


    # ocamlrun = tc_compiler(tc)[DefaultInfo].default_runfiles.files.to_list()[0]
    # effective_compiler = tc_compiler(tc)[DefaultInfo].files_to_run.executable

    # if (target_executor == "unspecified"):
    #     if (config_executor == "sys"):
    #         if config_emitter == "sys":
    #             # ss built from ocamlopt.byte
    #             executable = ocamlrun
    #             args.add(effective_compiler.path)
    #         else:
    #             # sv built from ocamlopt.opt
    #             executable = effective_compiler
    #     else:
    #         executable = ocamlrun
    #         args.add(effective_compiler.path)

    # elif target_executor in ["boot", "vm"]:
    #         executable = ocamlrun
    #         args.add(effective_compiler.path)

    # elif (target_executor == "sys" and target_emitter == "sys"):
    #     ## ss always built by vs (ocamlopt.byte)
    #     executable = ocamlrun
    #     args.add(effective_compiler.path)

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
    #         args.add_all(["-use-prims", ctx.file._primitives.path])
    #     else:
    #         if ctx.attr._rule in ["stdlib_module", "stdlib_signature"]:
    #             args.add_all(["-use-prims", ctx.file._primitives.path])
    #         else:
    #             if ctx.attr._use_prims[BuildSettingInfo].value:
    #                 if not "-no-use-prims" in ctx.attr.opts:
    #                     args.add_all(["-use-prims", ctx.file._primitives.path])
    #             else:
    #                 if  "-use-prims" in ctx.attr.opts:
    #                     args.add_all(["-use-prims", ctx.file._primitives.path])

    resolver = None
    resolver_deps = []
    if hasattr(ctx.attr, "ns"):
        if ctx.attr.ns:
            resolver = ctx.attr.ns[ModuleInfo]
            resolver_deps.append(resolver.sig)
            resolver_deps.append(resolver.struct)
            nsname = resolver.struct.basename[:-4]
            args.add_all(["-open", nsname])

    # if hasattr(ctx.attr, "stdlib_primitives"): # test rules
    #     if ctx.attr.stdlib_primitives:
            includes.append(ctx.attr.ns[ModuleInfo].sig.dirname)
            direct_inputs.append(ctx.attr.ns[ModuleInfo].sig)
            direct_inputs.append(ctx.attr.ns[ModuleInfo].struct)

    if hasattr(ctx.attr, "_opts"):
        args.add_all(ctx.attr._opts)

    if not ctx.attr.nocopts:
        # for opt in tc.copts:
        #     if opt not in NEGATION_OPTS:
        #         args.add(opt)
        #     else:
        args.add_all(tc.copts)

    args.add_all(tc.structopts)

    args.add_all(tc.warnings[BuildSettingInfo].value)

    for w in ctx.attr.warnings:
        args.add_all(["-w",
                      w if w.startswith("-")
                      else "-" + w])

    for dep in ctx.attr.deps:
        if hasattr(ctx.attr, "stdlib_primitives"): # test rules
            if dep.label.package == "stdlib":
                if "-nopervasives" in _options:
                    _options.remove("-nopervasives")
    args.add_all(_options)

    #FIXME: make a function for the dump stuff
    if hasattr(ctx.attr, "_lambda_expect_test"):
        for arg in ctx.attr._lambda_expect_test:
            args.add(arg)

    elif hasattr(ctx.attr, "dump"): # test rules w/explicit dump attr
        if len(ctx.attr.dump) > 0:
            args.add("-dump-into-file")
        for d in ctx.attr.dump:
            if d == "source":
                args.add("-dsource")
            if d == "parsetree":
                args.add("-dparsetree")
            if d == "typedtree":
                args.add("-dtypedtree")
            if d == "shape":
                args.add("-dshape")
            if d == "rawlambda":
                args.add("-drawlambda")
            if d == "lambda":
                args.add("-dlambda")
            if d == "rawclambda":
                args.add("-drawclambda")
            if d == "rawflambda":
                args.add("-drawflambda")
            if d == "flambda":
                args.add("-dflambda")
            if d == "flambda-let":
                args.add("-dflambda-let")
            if d == "flambda-verbose":
                args.add("-dflambda-verbose")

            if d == "instruction-selection":
                args.add("-dsel")

            if ext == ".cmo":
                if d == "instr":
                    args.add("-dinstr")

            if ext == ".cmx":
                if d == "clambda":
                    args.add("-dclambda")
                if d == "cmm":
                    args.add("-dcmm")

    merged_input_depsets = [merge_depsets(depsets, "sigs")]
    if ext == ".cmx":
        merged_input_depsets.append(merge_depsets(depsets, "cli_link_deps"))
        merged_input_depsets.append(archived_cmx_depset)

    # OCaml srcs use three namespaces:
    #     Stdlib, Dynlink_compilerlibs, Ocamldebug
    if hasattr(ctx.attr, "ns"):
        if ctx.attr.ns:
            includes.append(ctx.attr.ns[ModuleInfo].sig.dirname)

    ################ Direct Deps ################

    #NB: this will (may?) put stdlib in search path, even if target
    # does not depend on stdlib. that's ok because target may depend
    # on primitives that are exported by //stdlib:Stdlib
    includes.extend(paths_depset.to_list())

    runtime_deps = []
    # print("module: %s" % ctx.label)
    # for x in tc.runtime[CcInfo].linking_context.linker_inputs.to_list():
    #     for lib in x.libraries:
    #         runtime_deps.extend(lib.objects)

    inputs_depset = depset(
        order = dsorder,
        direct = []
        + sig_inputs
        + direct_inputs
        + depsets.deps.mli
        + resolver_deps
        + [tc_executable(tc)]
        + toolarg_input
        + runtime_deps
        ,
        transitive = []
        + merged_input_depsets
        + [tc_compiler(tc)[DefaultInfo].default_runfiles.files]
        # + ns_deps
        # + bottomup_ns_inputs
        ## depend on cc tc - makes bazel stuff accessible to ocaml's
        ## cc driver
        + [cc_toolchain.all_files]
    )
    # if ctx.label.name == "Misc":
    #     print("inputs_depset: %s" % inputs_depset)

    if pack_ns:
        args.add("-for-pack", pack_ns)

    if sig_src:
        includes.append(sig_src.dirname)

    includes.append(tc.runtime[0][DefaultInfo].files.to_list()[0].dirname)

    args.add_all(includes, before_each="-I", uniquify = True)

    args.add("-c")

    if sig_src:
        args.add(sig_src)
        args.add(in_structfile) # structfile)
    else:
        args.add("-impl", in_structfile) # structfile)
        args.add("-o", out_cm_)

    # print("ACTION_OUTPUTS: %s" % action_outputs)

    # if ctx.attr.dlambda:
    #     lambdalog = ctx.actions.declare_file(out_cm_.path + ".dump")
    #     action_outputs.append(lambdalog)

    # if ctx.attr._rule == "compile_fail_test":
    #     script = gen_compile_script(ctx, executable, args)

    ################
    ctx.actions.run(
        env = {"DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer",
               "SDKROOT": "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"},
        executable = tc_executable(tc).path,
        # executable = tc.compiler[DefaultInfo].files_to_run,
        arguments = [args],
        inputs    = inputs_depset,
        outputs   = action_outputs,
        tools = [
            # executable,
        ],
        mnemonic = "CompileBootstrapModule",
        progress_message = progress_msg(workdir, ctx)
    )

    #############################################
    ################  PROVIDERS  ################

    default_depset = depset(
        order = dsorder,
        # only output one file; for cmx, get .o from ModuleInfo
        direct = [out_cm_], # default_outputs,
        # transitive = [depset(direct=default_outputs)]
        # transitive = bottomup_ns_files + [depset(direct=default_outputs)]
    )

    defaultInfo = DefaultInfo(
        files = default_depset
    )
    providers = [defaultInfo]

    moduleInfo_depset = depset(
        ## FIXME: add ofile?
        direct= [provider_output_cmi, out_cm_]
        + [out_cmt] if out_cmt else [],
    )
    moduleInfo = ModuleInfo(
        sig    = provider_output_cmi,
        # sig_src = in_structfile,
        struct = out_cm_,
        struct_src = in_structfile,
        cmt = out_cmt,
        ofile  = moduleInfo_ofile
    )

    providers.append(moduleInfo)

    if hasattr(ctx.attr, "ns"):
        if ctx.attr.ns:
            resolver = ctx.attr.ns[ModuleInfo]
            nsResolverInfo = NsResolverInfo(
                sigs   = depset(
                    direct = [resolver.sig],
                    # transitive = ... depsets.deps.resolvers
                ),
                structs = depset(
                    direct = [resolver.struct],
                    # transitive = ... depsets.deps.resolvers
                )
            )
            providers.append(nsResolverInfo)

    bootProvider = BootInfo(
        sigs     = sigs_depset,
        cli_link_deps = cli_link_deps_depset,
        afiles   = afiles_depset,
        ofiles   = ofiles_depset,
        archived_cmx  = archived_cmx_depset,
        paths    = paths_depset,
    )
    providers.append(bootProvider)

    if ((hasattr(ctx.attr, "dump") and len(ctx.attr.dump) > 0)
        or hasattr(ctx.attr, "_lambda_expect_test")):
        # if len(ctx.attr.dump) > 0:
        d = DumpInfo(dump = out_dump)
        providers.append(d)
        outputGroupInfo = OutputGroupInfo(
            cmi        = depset(direct=[provider_output_cmi]),
            module     = moduleInfo_depset,
            log = depset([out_dump])
        )
    else:
        outputGroupInfo = OutputGroupInfo(
            cmi        = depset(direct=[provider_output_cmi]),
            module     = moduleInfo_depset
        )

    providers.append(outputGroupInfo)

    return providers
