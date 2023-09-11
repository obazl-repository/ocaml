load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

def _ocaml_xcode_impl(repo_ctx):
    result = repo_ctx.execute([repo_ctx.attr._script])

_ocaml_xcode = repository_rule(
    implementation=_ocaml_xcode_impl,
    local = True,
    attrs = {
        "_script" : attr.label(
            allow_single_file = True,
            default = ":xcode.sh"
        )
    }
)

#######################################################
_config = tag_class(attrs = {"version": attr.string()})

#####################
def _cc_config_impl(ctx):
    print("CC_CONFIG EXTENSION")

    # version = ctx.modules[0].tags.config[0].version
    # print("VERSION: %s" % version)

    _ocaml_xcode(name = "ocaml_xcode")

#####
cc_config = module_extension(
    implementation = _cc_config_impl,
    tag_classes = {"config": _config}
)
