load("//bzl/rules:mustache.bzl", _mustache = "mustache")
load("//bzl/rules:cc_assemble.bzl", _cc_assemble = "cc_assemble")

load("//bzl/rules:build_tool.bzl", _build_tool = "build_tool")
load("//bzl/rules:ocaml_tool.bzl", _ocaml_tool = "ocaml_tool")
load("//bzl/rules:build_module.bzl", _build_module = "build_module")

load("//bzl/rules:boot_import_tool.bzl", _boot_import_tool = "boot_import_tool")

load("//bzl/rules:boot_coldstart.bzl",
     _boot_coldstart = "boot_coldstart")

load("//bzl/rules:boot_config.bzl",
     _boot_config = "boot_config")

load("//bzl/rules:boot_archive.bzl",
     _boot_archive = "boot_archive")

load("//bzl/rules:boot_camlheaders.bzl",
     _boot_camlheaders = "boot_camlheaders")

load("//bzl/rules:boot_executable.bzl",
     _boot_executable = "boot_executable")

# load("//bzl/rules:baseline_executable.bzl",
#      _baseline_executable = "baseline_executable")

load("//bzl/rules:boot_module.bzl", _boot_module = "boot_module")

load("//bzl/rules:compiler_module.bzl", _compiler_module = "compiler_module")

load("//bzl/rules:boot_library.bzl",
     _boot_library = "boot_library")

# load("//bzl/rules:bootstrap_ns.bzl",
#      _bootstrap_ns = "bootstrap_ns")

# load("//bzl/rules:bootstrap_preprocess.bzl",
#      _bootstrap_preprocess = "bootstrap_preprocess")

load("//bzl/rules:boot_lexer.bzl", _boot_lexer = "boot_lexer")

# load("//bzl/rules:bootstrap_repl.bzl",
#      _bootstrap_repl = "bootstrap_repl")

load("//bzl/rules:boot_signature.bzl", _boot_signature = "boot_signature")
load("//bzl/rules:compiler_signature.bzl", _compiler_signature = "compiler_signature")

# load("//bzl/rules:baseline_test.bzl",
#      _baseline_test = "baseline_test")

load("//bzl/rules:boot_compiler.bzl", _boot_compiler = "boot_compiler")

# load("//bzl/rules:baseline_compiler.bzl", _baseline_compiler = "baseline_compiler")


# load("//bzl/rules:ocamlc_fixpoint.bzl", _ocamlc_fixpoint = "ocamlc_fixpoint")
# load("//bzl/rules:ocamlc_runtime.bzl", _ocamlc_runtime = "ocamlc_runtime")

mustache    = _mustache
cc_assemble = _cc_assemble
ocaml_tool      = _ocaml_tool
build_module      = _build_module
build_tool      = _build_tool
boot_import_tool      = _boot_import_tool
boot_coldstart      = _boot_coldstart
boot_config      = _boot_config
boot_archive      = _boot_archive
boot_camlheaders      = _boot_camlheaders
boot_executable      = _boot_executable
# baseline_executable      = _baseline_executable
boot_library  = _boot_library
boot_module      = _boot_module
compiler_module      = _compiler_module
# bootstrap_ns = _bootstrap_ns
# bootstrap_preprocess  = _bootstrap_preprocess
boot_lexer = _boot_lexer

# bootstrap_repl   = _bootstrap_repl
boot_signature   = _boot_signature
compiler_signature   = _compiler_signature
# baseline_test   = _baseline_test

boot_compiler    = _boot_compiler
# baseline_compiler    = _baseline_compiler
# ocamlc_runtime    = _ocamlc_runtime
# ocamlc_fixpoint    = _ocamlc_fixpoint
