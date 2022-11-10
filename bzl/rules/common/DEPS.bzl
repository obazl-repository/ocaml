load("//bzl:providers.bzl",
     "BootInfo", "DepsAggregator",
     "ModuleInfo", "OcamlSignatureProvider")

load("//bzl/rules/common:impl_ccdeps.bzl",
     "cc_shared_lib_to_ccinfo",
     "normalize_ccinfo",
     "extract_cclibs", "dump_CcInfo")

COMPILE      = 0
LINK         = 1
COMPILE_LINK = 2

################################################################
def aggregate_deps(ctx,
                   target, # a Target
                   depsets, # a struct
                   archive_manifest = []): # target will be added to archive

    # archive manifest tells us where to put a cm[o|x] file.
    # if file is in manifest, it is archive, so it goes into archived_cmx
    # otherwise it goes in cli_link_args.

    archiving = len(archive_manifest) > 0
    this = ctx.label.package + "/" + ctx.label.name

    debug = False
    # if target.label.name == "Ppxlib_driver":
    #     debug = True
    if debug:
        print("aggregate_deps: %s" % target)
        print("manifest: %s" % archive_manifest)
        for m in archive_manifest:
            print("m: %s" % m)
            print("m=this %s" % (m == this))

        if this in archive_manifest:
            print("IN MANIFEST: %s" % ctx.label)
            # fail("X")

    if BootInfo not in target:
        fail("BootInfo not in target: %s" % target)

    if OcamlSignatureProvider in target:
        depsets.deps.mli.append(target[OcamlSignatureProvider].mli)

    provider = target[BootInfo]

    # if target not in archive_manifest:
    #     if hasattr(provider, "cli_link_deps"):
    #         # if target.label.name == "Easy":
    #         #     fail("CLI LINKDEPS: %s" % provider)
    #         depsets.deps.cli_link_deps.append(provider.cli_link_deps)

    # print("provider: %s" % provider)

    depsets.deps.sigs.append(provider.sigs)

    depsets.deps.cli_link_deps.append(provider.cli_link_deps)

    if ModuleInfo in target:
        # if target.label.name == "Common":
            # print("ModuleInfo: %s" % target[ModuleInfo])
            # print("DefaultInfo.files: %s" % target[DefaultInfo].files)
            # print("BootInfo.linkdeps: %s" % target[BootInfo].cli_link_deps)
            # fail("COMMON")
        depsets.deps.sigs.append(
            depset([target[ModuleInfo].sig]))

        if archiving:
            if target not in archive_manifest:
                depsets.deps.cli_link_deps.append(
                    depset([target[ModuleInfo].struct]))
            else:
                depsets.deps.archived_cmx.append(target[ModuleInfo].struct)
        else:
            depsets.deps.cli_link_deps.append(
                depset([target[ModuleInfo].struct]))

    depsets.deps.afiles.append(provider.afiles)
    depsets.deps.archived_cmx.append(provider.archived_cmx)
    depsets.deps.paths.append(provider.paths)

    if CcInfo in target:
        ## if target == vm, and vmruntime = dynamic, then cc_binary
        ## targets producing shared libs will deliver the shared lib
        ## in DefaultInfo, but not in CcInfo. E.g. jsoo
        ## lib/runtime:jsoo_runtime builds a cc_bindary
        ## dlljsoo_runtime_stubs.so or a cc_library
        ## libjsoo_runtime.stubs.a, depending on build context.

        ## to handle this anomlous case we need to detect it and then
        ## construct a CcInfo provider containing the shared lib.

        # (libname, filtered_ccinfo) = filter_ccinfo(dep)
        # if debug_cc:
        #     print("LIBNAME: %s" % libname)
        #     print("FILTERED CCINFO: %s" % filtered_ccinfo)
        # if filtered_ccinfo:
        #     ccinfos.append(filtered_ccinfo)
        #     # ccinfos.append(libname)
        # else:
        #     ## this dep has CcInfo but not BootInfo (i.e. it
        #     ## was not propagated by an ocaml_* rule?); infer it
        #     ## was delivered by cc_binary must be a shared lib
        #     ccfile = dep[DefaultInfo].files.to_list()[0]
        #     ## put the cc file into a CcInfo provider:
        #     cc_info = cc_shared_lib_to_ccinfo(ctx, dep[CcInfo], ccfile)
        #     ccinfos.append(cc_info)
        #     # dump_CcInfo(ctx, dep[CcInfo])

        ccInfo = normalize_ccinfo(ctx, target)
        # if ctx.label.name == "jsoo_runtime":
        #     dump_CcInfo(ctx, ccInfo)
        #     fail("asdf")

        depsets.ccinfos.append(ccInfo)

    return depsets

def merge_depsets(depsets, fld):
    # print("merging %s" % fld)
    # print("unmerged fld: %s" % getattr(depsets.deps, fld))
    merged = depset(transitive = getattr(depsets.deps, fld))
    # print("merged fld {f}: {m}".format(f=fld, m=merged))

    return merged
