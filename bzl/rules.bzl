load("//bzl/rules:test_archive.bzl", _test_archive = "test_archive")
load("//bzl/rules:test_executable.bzl",
     _test_executable = "test_executable")
load("//bzl/rules:test_library.bzl", _test_library = "test_library")
load("//bzl/rules:test_module.bzl",  _test_module  = "test_module")
load("//bzl/rules:test_signature.bzl", _test_signature = "test_signature")

load("//bzl/rules:cc_assemble.bzl", _cc_assemble = "cc_assemble")

load("//bzl/rules:build_tool.bzl", _build_tool = "build_tool")
load("//bzl/rules:ocaml_tool.bzl", _ocaml_tool = "ocaml_tool")
load("//bzl/rules:build_module.bzl", _build_module = "build_module")

load("//bzl/rules:boot_import_vm_executable.bzl", _boot_import_vm_executable = "boot_import_vm_executable")

load("//bzl/rules:boot_config.bzl",
     _boot_config = "boot_config")

load("//bzl/rules:boot_archive.bzl",
     _boot_archive = "boot_archive")

# load("//bzl/rules:boot_executable.bzl", _boot_executable = "boot_executable")

# load("//bzl/rules:baseline_executable.bzl",
#      _baseline_executable = "baseline_executable")

# load("//bzl/rules:boot_compiler.bzl", _boot_compiler = "boot_compiler")
load("//bzl/rules:boot_module.bzl", _boot_module = "boot_module")
load("//bzl/rules:boot_signature.bzl", _boot_signature = "boot_signature")
load("//bzl/rules:boot_library.bzl", _boot_library = "boot_library")

load("//bzl/rules:ocaml_compiler.bzl", _ocaml_compiler = "ocaml_compiler")
load("//bzl/rules:compiler_module.bzl", _compiler_module = "compiler_module")
load("//bzl/rules:compiler_signature.bzl", _compiler_signature = "compiler_signature")

load("//bzl/rules:bootstrap_repl.bzl", _bootstrap_repl = "bootstrap_repl")


# load("//bzl/rules:baseline_test.bzl",
#      _baseline_test = "baseline_test")

# load("//bzl/rules:baseline_compiler.bzl", _baseline_compiler = "baseline_compiler")


# load("//bzl/rules:ocamlc_fixpoint.bzl", _ocamlc_fixpoint = "ocamlc_fixpoint")
# load("//bzl/rules:ocamlc_runtime.bzl", _ocamlc_runtime = "ocamlc_runtime")

# mustache    = _mustache
cc_assemble = _cc_assemble
build_module      = _build_module
build_tool      = _build_tool
boot_import_vm_executable      = _boot_import_vm_executable

boot_config      = _boot_config
boot_archive      = _boot_archive

# boot_executable      = _boot_executable
# baseline_executable      = _baseline_executable
boot_library  = _boot_library
boot_module      = _boot_module
compiler_module      = _compiler_module
# bootstrap_ns = _bootstrap_ns
# bootstrap_preprocess  = _bootstrap_preprocess
# boot_lexer = _boot_lexer

bootstrap_repl   = _bootstrap_repl
boot_signature   = _boot_signature
compiler_signature   = _compiler_signature
# baseline_test   = _baseline_test

# boot_compiler    = _boot_compiler
ocaml_compiler    = _ocaml_compiler
ocaml_tool      = _ocaml_tool

# ocamlc_runtime    = _ocamlc_runtime
# ocamlc_fixpoint    = _ocamlc_fixpoint

test_archive = _test_archive
test_executable = _test_executable
test_library = _test_library
test_module  = _test_module
test_signature = _test_signature
