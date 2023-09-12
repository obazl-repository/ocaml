load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")


################################
def _ocaml_config_impl(repo_ctx):
    # print("OCAML_CONFIG EXTENSION")

    result = repo_ctx.execute(["uname", "-m"])
    hwarch = result.stdout.strip()
    result = repo_ctx.execute(["uname", "-r"])
    revision = result.stdout.strip()
    result = repo_ctx.execute(["uname", "-s"])
    os = result.stdout.strip()

    repo_ctx.file(
        "BUILD.bazel",
        content = """
"""
    )
    repo_ctx.file(
        "BUILD.bzl",
        content = """
OS = "{os}"
OSREV = "{rev}"
HWARCH = "{hw}"
        """.format(os = os, rev = revision, hw = hwarch)
    )

    # print("repo_ctx.os.arch: %s" % repo_ctx.os.arch)
    # for k,v in repo_ctx.os.environ.items():
    #     print("ENV {k} : {v}".format(k=k,v=v))
    # print("repo_ctx.os.name: %s" % repo_ctx.os.name)

    xcrun = repo_ctx.which("xcrun")
    # print("XCRUN: %s" % xcrun)
    # print("XCODE VERSION: %s" % repo_ctx.attr.xcode_version)

    # if repo_ctx.os.name == "mac os x": ## is this reliable?
    if xcrun != None:
        result = repo_ctx.execute(["xcrun",
                                   "--show-sdk-version",
                                   "--sdk", "macosx"])
        if result.return_code == 0:
            SDKVERSION = result.stdout.strip()
        else:
            fail("xcrun fail: %s" % result.stderr)
        # print("SDK_VERSION: %s" % SDKVERSION)

        ##TODO: also support driverkit, iphoneos, someday?

        result = repo_ctx.execute(["xcode-select", "-p"])
        if result.return_code == 0:
            DEVELOPER_DIR = result.stdout.strip()
        else:
            fail("xcrun fail: %s" % result.stderr)
        # print("DEVELOPER_DIR: %s" % DEVELOPER_DIR)

        result = repo_ctx.execute(["xcrun", "--show-sdk-path"])
        if result.return_code == 0:
            SDKROOT = result.stdout.strip()
        else:
            fail("xcrun fail: %s" % result.stderr)
        # print("SDKROOT: %s" % SDKROOT)

        repo_ctx.file(
            "xcode/BUILD.bazel",
            content = """
load("@bazel_skylib//rules:common_settings.bzl",
        "string_setting")

string_setting(
        name = "macosx_sdk_version",
        build_setting_default = "{sdkv}",
        visibility = ["//visibility:public"]
)
string_setting(
        name = "developer_dir",
        build_setting_default = "{dd}",
        visibility = ["//visibility:public"]
)

string_setting(
        name = "sdkroot",
        build_setting_default = "{sdk}",
        visibility = ["//visibility:public"]
)
            """.format(dd = DEVELOPER_DIR,
                       sdk = SDKROOT,
                       sdkv = SDKVERSION)
        )

################################
_ocaml_config = repository_rule(
    implementation=_ocaml_config_impl,
    local = True,
    attrs = {
        "_script" : attr.label(
            allow_single_file = True,
            default = ":xcode.sh"
        ),
        "xcode_version": attr.string()
    }
)

#######################################################
_xcode = tag_class(attrs = {"version": attr.string()})

#####################
def _config_impl(ctx):
    # print("CONFIG EXTENSION")

    if ctx.modules[0].tags.xcode:
        version = ctx.modules[0].tags.xcode[0].version
    else:
        version = None

    _ocaml_config(name = "ocaml_config",
                  xcode_version = version)


#####
config = module_extension(
    implementation = _config_impl,
    tag_classes = {"xcode": _xcode}
)
