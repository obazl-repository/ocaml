load("@bazel_skylib//lib:paths.bzl", "paths")

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

load(":BUILD.bzl", "progress_msg", "add_dump_args")
#, "get_build_executor", "configure_action")

load("//bzl:providers.bzl",
     "BootInfo",
     "ModuleInfo",
     # "SigInfo",
     "StdlibSigMarker",
     "StdSigMarker",
     "new_deps_aggregator",
     "OcamlSignatureProvider")

load("//bzl:functions.bzl", "get_module_name")

load("//bzl/rules/common:options.bzl", "get_options")

load("//bzl/rules/common:impl_common.bzl", "dsorder")

load("//bzl/rules/common:DEPS.bzl", "aggregate_deps", "merge_depsets")

################################################################
## OUTPUTS: cmi, mli, maybe cmti
def construct_outputs(ctx, _options, tc, workdir, ext, module_name):
    debug = False

    if debug:
        print("contruct_outputs: %s" % ctx.label)

    outputs = {
        "cmi": None,
        "cmti": None,
        # "sig_srcfile": None,        # original ctx.attr.src
        # "sig_workfile": None,       # sigfile symlink in workdir
        # "logfile": None, ## FIXME: mv to test_signature
        # "workdir": None,
    }

    # test_signature targets w/non-zero rc do not return std outputs
    # (since compile expected to fail).
    if hasattr(ctx.attr, "rc_expected"):
        if ctx.attr.rc_expected != 0:
            return (outputs, module_name)

    out_cmi = ctx.actions.declare_file(workdir + module_name + ".cmi")
    outputs["cmi"] = out_cmi

    if ( ("-bin-annot" in _options)
         or ("-bin-annot" in tc.copts) ):
        out_cmti = ctx.actions.declare_file(workdir + module_name + ".cmti")
        outputs["cmti"] = out_cmti

    return (outputs, module_name)

################################################################
def merge_deps(ctx, outputs):
    depsets = new_deps_aggregator()

    manifest = []

    #WARNING: always do stdlib_deps first, since others may depend on it
    if hasattr(ctx.attr, "stdlib_deps"):
        if hasattr(ctx.attr, "_stdlib"):
            if ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
                # for dep in ctx.attr._stdlib:
                depsets = aggregate_deps(ctx, ctx.attr._stdlib, depsets, manifest)
            else:
                for dep in ctx.attr.stdlib_deps:
                    depsets = aggregate_deps(ctx, dep, depsets, manifest)
        else:
            for dep in ctx.attr.stdlib_deps:
                depsets = aggregate_deps(ctx, dep, depsets, manifest)

    # compilerlibs deps
    if hasattr(ctx.attr, "libOCaml_deps"):
        if hasattr(ctx.attr, "_libOCaml"):
            if ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
                depsets = aggregate_deps(ctx, ctx.attr._libOCaml, depsets, manifest)
            else:
                for dep in ctx.attr.libOCaml_deps:
                    depsets = aggregate_deps(ctx, dep, depsets, manifest)
        else:
            for dep in ctx.attr.libOCaml_deps:
                depsets = aggregate_deps(ctx, dep, depsets, manifest)

    # if ctx.attr.sig: #FIXME
    #     if OcamlSignatureProvider in ctx.attr.sig:
    #         depsets = aggregate_deps(ctx, ctx.attr.sig, depsets, manifest)
    #     else:
    #         # either is_source or generated
    #         depsets.deps.mli.append(ctx.file.sig)
    #         # FIXME: add cmi to depsets
    #         if outputs["cmi"]:
    #             depsets.deps.sigs.append(depset([outputs["cmi"]]))
    #         # if provider_output_cmi:
    #         #     depsets.deps.sigs.append(depset([provider_output_cmi]))

    # some sig targets may depend on a *_intf module
    # e.g. //otherlibs/dynlink:Dynlink_common_cmi" depends on
    # "//otherlibs/dynlink:Dynlink_platform_intf" module
    if hasattr(ctx.attr, "struct_deps"):
        for dep in ctx.attr.struct_deps:
            depsets = aggregate_deps(ctx, dep, depsets, manifest)

    for dep in ctx.attr.deps:
        depsets = aggregate_deps(ctx, dep, depsets, manifest)

    # for dep in ctx.attr.cc_deps:
    #     depsets = aggregate_deps(ctx, dep, depsets, manifest)

    # if hasattr(ctx.attr, "sig_deps"):
    #     for dep in ctx.attr.sig_deps:
    #         depsets = aggregate_deps(ctx, dep, depsets, manifest)

    ## FIXME: not needed for test_signature?
    # if hasattr(ctx.attr, "ns"):
    #     if ctx.attr.ns:
    #         # for dep in ctx.attr.ns:
    #         depsets = aggregate_deps(ctx, ctx.attr.ns, depsets, manifest)

    return depsets

#     open_stdlib = False
#     no_alias_deps = False
#     stdlib_module_target  = None
#     stdlib_primitives_target  = None
#     stdlib_library_target = None

#     for dep in ctx.attr.deps:
#         depsets = aggregate_deps(ctx, dep, depsets, manifest)

#     if hasattr(ctx.attr, "struct_deps"):
#         for dep in ctx.attr.struct_deps:
#             depsets = aggregate_deps(ctx, dep, depsets, manifest)
#         # if len(ctx.attr.stdlib_deps) < 1:
#         # if dep.label.package == "stdlib":
#         #     if dep.label.name in ["Primitives", "Stdlib"]:
#         #         open_stdlib = True
#         #         stdlib_module_target = dep
#         #     # elif dep.label.name == "Stdlib":
#         #     #     open_stdlib = True
#         #     elif dep.label.name.startswith("Stdlib"): ## stdlib submodule
#         #         open_stdlib = True
#         #     elif dep.label.name == "stdlib": ## stdlib archive OR library
#         #         open_stdlib = True
#         #         stdlib_library_target = dep

#     if hasattr(ctx.attr, "stdlib_deps"):
#         if len(ctx.attr.stdlib_deps) > 0:
#             no_alias_deps = True
#             if not ctx.label.name == "Stdlib_cmi":
#                 open_stdlib = True
#         for dep in ctx.attr.stdlib_deps:
#             depsets = aggregate_deps(ctx, dep, depsets, manifest)
#             if dep.label.name == "Primitives":
#                 stdlib_primitives_target = dep
#             elif dep.label.name == "Stdlib":  ## Stdlib resolver
#                 stdlib_module_target = dep
#             elif dep.label.name.startswith("Stdlib"): ## stdlib submodule
#                 stdlib_module_target = dep
#             elif dep.label.name == "stdlib": ## stdlib archive OR library
#                 stdlib_library_target = dep
#                 break;

#     if hasattr(ctx.attr, "ns"):
#         if ctx.attr.ns:
#             # for dep in ctx.attr.ns:
#             depsets = aggregate_deps(ctx, ctx.attr.ns, depsets, manifest)

#     ## build depsets here, use for OcamlProvider and OutputGroupInfo
#     sigs_depset = depset(
#         order=dsorder,
#         direct = [out_cmi],
#         transitive = [merge_depsets(depsets, "sigs")])

#     if depsets.deps.cli_link_deps != []:
#         cli_link_deps_depset = depset(
#             order = dsorder,
#             transitive = [merge_depsets(depsets, "cli_link_deps")]
#         )
#     else:
#         cli_link_deps_depset = []

#     afiles_depset  = depset(
#         order=dsorder,
#         transitive = [merge_depsets(depsets, "afiles")]
#     )

#     ofiles_depset  = depset(
#         order=dsorder,
#         transitive = [merge_depsets(depsets, "ofiles")]
#     )

#     archived_cmx_depset = depset(
#         order=dsorder,
#         transitive = [merge_depsets(depsets, "archived_cmx")]
#     )

#     paths_depset  = depset(
#         order = dsorder,
#         direct = [out_cmi.dirname],
#         transitive = [merge_depsets(depsets, "paths")]
#     )

################################################################
def construct_inputs(ctx, tc, ext, workdir,
                     executor, executor_arg,
                     from_name, module_name,
                     depsets,
                     outputs):
    debug = False

    in_files   = []
    in_depsets = []
    in_files.append(executor)
    if executor_arg:
        in_files.append(executor_arg)

    basename = ctx.label.name
    from_name = basename[:1].capitalize() + basename[1:]

    mli_srcfile  = ctx.file.src
    mli_workfile = None

    if from_name == module_name: # no renaming needed
        ## We need to ensure mli file and cmi file are in the same
        ## place. Since Bazel writes output files into its own dirs
        ## (won't write back into src dir), this means we need to
        ## symlink the source mli file into the same output directory,
        ## so that it will be found when it comes time to compile the
        ## .ml file.

        if debug: print("cmi: no renaming")
        if mli_srcfile.is_source:  # i.e. not generated by a preprocessor
            mli_workfile = ctx.actions.declare_file(workdir + module_name + ".mli")
            ctx.actions.symlink(output = mli_workfile,
                                target_file = mli_srcfile)
            if debug:
                print("symlinked {src} => {dst}".format(
                    src = mli_srcfile.path, dst = mli_workfile.path))
        else:
            ## generated file, already in bazel work dir
            if debug:
                print("not symlinking {src}".format(src = mli_srcfile))

            mli_workfile = mli_srcfile

    else: # src filename != tgt label
        if debug: print("cmi: renaming {src} => {dst}".format(
            src = from_name, dst = module_name))
        mli_workfile = ctx.actions.declare_file(workdir + module_name + ".mli")
        ctx.actions.symlink(output = mli_workfile,
                            target_file = mli_srcfile)
        if debug:
            print("symlinked {src} => {dst}".format(
                src = mli_srcfile.path, dst = mli_workfile.path))

    in_files.append(mli_srcfile)
    in_files.append(mli_workfile)

    bootInfo = depsets.deps

    return struct(
        ##FIXME: .mli file cannot be both input and output
        mli = mli_workfile,
        files = in_files,
        bootinfo  = bootInfo)

    ## FIXME: move logic for mli input from construct_outputs to here

    # inputs_depset = depset(
    #     order = dsorder,
    #     direct = []
    #     + direct_inputs # = mlifile, ns resolver, runtime deps (data)
    #     # + ctx.files._ns_resolver,
    #     # + [tc.compiler[DefaultInfo].files_to_run.executable],
    #     # + ctx.files.data if ctx.files.data else [],
    #     # + [effective_compiler]
    #     + toolarg_input # compiler
    #     + resolver
    #     ,
    #     transitive = []## indirect_inputs_depsets
    #     + [merge_depsets(depsets, "sigs"),
    #        merge_depsets(depsets, "cli_link_deps")
    #        ]
    #     # + depsets.deps.structs
    #     # + depsets.deps.sigs
    #     # + depsets.deps.archives
    #     # + ns_resolver_depset
    #     # + [tc.compiler[DefaultInfo].default_runfiles.files]
    # )

def construct_args(ctx, tc, _options, cancel_opts,
                   ext,
                   inputs,
                   outputs,
                   depsets,
                   ):

    includes   = []

    open_stdlib = False
    if hasattr(ctx.attr, "stdlib_deps"):
        # if ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
        #     open_stdlib = True

        if len(ctx.attr.stdlib_deps) > 0:
            if not ctx.label.name == "Stdlib":
                open_stdlib = True
        for dep in ctx.attr.stdlib_deps:
            if (dep.label.name.startswith("Stdlib")
                or dep.label.name == "Primitives"):
                ## dep is either Stdlib resolver or a stdlib submodule
                if ctx.attr._rule == "compile_module_test":
                    # inc = paths.dirname(dep[DefaultInfo].files.to_list()[0].path)
                    inc = dep[DefaultInfo].files.to_list()[0].dirname
                else:
                    inc = dep[DefaultInfo].files.to_list()[0].dirname
                includes.append(inc)

            elif dep.label.name == "stdlib":
                ## dep is stdlib library, possibly archived
                if ctx.attr._compilerlibs_archived[BuildSettingInfo].value:
                    stdlib = ctx.expand_location("$(rootpath //stdlib)",
                                                 targets=[dep])
                    includes.append(paths.dirname(stdlib))
                else:
                    stdlibstr = ctx.expand_location("$(rootpaths //stdlib)",
                                         targets=[dep])
                    stdlibs = stdlibstr.split(" ")
                    includes.append(paths.dirname(stdlibs[0]))

    includes.append(inputs.mli.dirname)

    args = ctx.actions.args()

    toolarg = tc.tool_arg
    # if ctx.label.name == "CamlinternalFormatBasics_cmi":
    #     print("SIG tool_arg: %s" % toolarg)
    if toolarg:
        args.add(toolarg.path)
        toolarg_input = [toolarg]
    else:
        toolarg_input = []

    if "-pervasives" in _options:
        # default is -nopervasives
        cancel_opts.append("-nopervasives")
        _options.remove("-pervasives")

    ##FIXME: ns handling?
    # if hasattr(ctx.attr, "ns"):
    #     if ctx.attr.ns:
    #         resolver.append(ctx.attr.ns[ModuleInfo].sig)
    #         resolver.append(ctx.attr.ns[ModuleInfo].struct)
    #         ns = ctx.attr.ns[ModuleInfo].struct.basename[:-4]
    #         args.add_all(["-open", ns])

    tc_opts = []
    if not ctx.attr.nocopts:  ## FIXME: obsolete?
        if ctx.attr._rule != "inline_expect_module":
            tc_opts.extend(tc.copts)

    tc_opts.extend(tc.structopts)

    # if ctx.label.name.endswith("_expect"):
    #     print("tc opts: %s" % tc_opts)
    #     print("tc warnings: %s" % tc.warnings[BuildSettingInfo].value)
        # fail(ctx.label)

    if not ctx.attr._rule == "inline_expect_runner":
        for opt in tc_opts:
            if opt not in cancel_opts:
                args.add(opt)

    args.add_all(_options)

    if ctx.attr._rule == "test_module":
        # if ctx.attr._werrors:
        # args.add("-w", "@A")
        None
    #     # else:
    #     # args.add("-w", "+A")

    ## ignore tc warnings for testing
    if ctx.attr._rule not in ["inline_expect_module", "test_module"]:
        for w in tc.warnings[BuildSettingInfo].value:
            args.add_all(["-w", w])

    if hasattr(ctx.attr, "alerts"):
        alert_str = "@all"
        for a in ctx.attr.alerts:
            alert_str = alert_str + (a if a.startswith("++")
                                     else a if a.startswith("+")
                                     else a if a.startswith("--")
                                     else a if a.startswith("-")
                                     else a if a.startswith("@")
                                     # default: non-fatal
                                     else "--" + a)
        # args.add("-alert", "@all")
        if len(alert_str) > 0:
            args.add("-alert", alert_str)

    # args.add("-w", "@A")
    # for w in ctx.attr.warnings:
    #     args.add_all(["-w",
    #                   w if w.startswith("+")
    #                   else w if w.startswith("-")
    #                   else w if w.startswith("@")
    #                   else "+" + w])

    for k,v in ctx.attr.warnings.items():
        if k == "disable":
            for w in v:
                args.add("-w", "-" + w)
            # args.add_joined("-w", v,
            #                 format_each = "-%s",
            #                 join_with="",
            #                 uniquify = True)
        if k == "enable":
            args.add_joined("-w", v,
                            format_each = "+%s",
                            join_with="",
                            uniquify = True)
        if k == "fatal":
            args.add_joined("-w", v,
                            format_each = "@%s",
                            join_with="",
                            uniquify = True)

    # if no_alias_deps:
    #     args.add("-no-alias-deps") ##FIXME: control this w/flag?
    if open_stdlib:
        args.add("-no-alias-deps") ##FIXME: control this w/flag?
        args.add("-open", "Stdlib")

    add_dump_args(ctx, ext, args) # -dlambda etc.

    args.add_all(includes,
                 before_each="-I",
                 uniquify = True)

    args.add("-intf", inputs.mli.path)
    args.add("-c")
    args.add("-o", outputs["cmi"])

    return args

################################################################
## MAIN ENTRY
def construct_signature_compile_config(ctx, module_name):
    debug = False
    debug_bootstrap = False
    debug_ccdeps = False

    basename = ctx.label.name
    from_name = basename[:1].capitalize() + basename[1:]

    tc = ctx.toolchains["//toolchain/type:ocaml"]

    workdir = tc.workdir

    if ctx.attr._rule == "inline_expect_module":
        compiler = ctx.file._expect_compiler
    else:
        compiler = tc.compiler[DefaultInfo].files_to_run.executable

    if ctx.attr._rule == "inline_expect_runner":
        executor = tc.ocamlrun
        executor_arg = ctx.file._tool
    elif ctx.attr._rule == "inline_expect_module":
        executor = tc.ocamlrun
        executor_arg = ctx.file._expect_compiler
    elif compiler.extension in ["byte", "boot"]:
        executor = tc.ocamlrun
        executor_arg = compiler
    else:
        executor = compiler
        executor_arg = None

    ext = ".cmi"

    (_options, cancel_opts) = get_options(ctx.attr._rule, ctx)

    ################################################################
    ################  ACTION_OUTPUTS: .cmi, maybe .cmti  ################
    (action_outputs, module_name) = construct_outputs(ctx, _options, tc,
                                               workdir, ext,
                                               module_name)
    # print("ACTION_OUTPUTS: %s" % action_outputs)

    ################################################################
    ################  DEPS  ################
    # > unmerged aggregated deps excluding current action outs
    depsets = merge_deps(ctx, action_outputs)

    # print("DEPSETS: %s" % depsets)

    ################################################################
    #### ACTION_INPUTS: .mli, cmi deps, ns_resolver? no non-cmi deps?
    action_inputs = construct_inputs(ctx, tc, ext, workdir,
                              executor, executor_arg,
                              from_name, module_name,
                              depsets,
                              action_outputs)

    # print("ACTION_INPUTS: %s" % action_inputs)

    ################################################################
    ################  CMD LINE  ################
    args = construct_args(ctx, tc,
                          _options, cancel_opts,
                          ext,
                          action_inputs,
                          action_outputs,
                          depsets)

    return (action_inputs,  # => struct, flds: files, depsets
            action_outputs,
            executor,
            executor_arg,
            workdir,
            args)
