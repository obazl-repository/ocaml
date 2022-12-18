load("//bzl/rules:run_tool.bzl", _run_tool = "run_tool")
load("//bzl/rules:run_repl.bzl", _run_repl = "run_repl")

load("//bzl/rules:tool_module.bzl",  _tool_module  = "tool_module")
load("//bzl/rules:tool_signature.bzl", _tool_signature = "tool_signature")

load("//bzl/rules:cc_assemble.bzl", _cc_assemble = "cc_assemble")

load("//bzl/rules:build_tool.bzl", _build_tool = "build_tool")
load("//bzl/rules:ocaml_tool.bzl",
     _ocaml_tool = "ocaml_tool",
     _ocaml_tool_vm = "ocaml_tool_vm",
     _ocaml_tool_sys = "ocaml_tool_sys",
     )
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

load("//bzl/rules:ocaml_compiler.bzl",
     _ocamlc_byte = "ocamlc_byte",
     _ocaml_compiler = "ocaml_compiler",
     _ocaml_compilers = "ocaml_compilers")

load("//bzl/rules:compiler_module.bzl", _compiler_module = "compiler_module")
load("//bzl/rules:compiler_signature.bzl", _compiler_signature = "compiler_signature")

load("//bzl/rules:bootstrap_repl.bzl", _bootstrap_repl = "bootstrap_repl")


# load("//bzl/rules:baseline_compiler.bzl", _baseline_compiler = "baseline_compiler")


# load("//bzl/rules:ocamlc_fixpoint.bzl", _ocamlc_fixpoint = "ocamlc_fixpoint")
# load("//bzl/rules:ocamlc_runtime.bzl", _ocamlc_runtime = "ocamlc_runtime")

# mustache    = _mustache
cc_assemble = _cc_assemble
build_module      = _build_module
ocaml_module      = _build_module ### TEMPORARY until //testsuite cleanup

build_tool      = _build_tool
boot_import_vm_executable      = _boot_import_vm_executable

boot_config      = _boot_config
boot_archive      = _boot_archive

# boot_executable      = _boot_executable
# baseline_executable      = _baseline_executable
ocaml_library  = _boot_library
boot_library  = _boot_library
boot_module      = _boot_module
compiler_module      = _compiler_module
# bootstrap_ns = _bootstrap_ns
# bootstrap_preprocess  = _bootstrap_preprocess
# boot_lexer = _boot_lexer

bootstrap_repl   = _bootstrap_repl
boot_signature   = _boot_signature
compiler_signature   = _compiler_signature

# boot_compiler    = _boot_compiler
ocaml_compiler    = _ocaml_compiler
ocaml_compilers    = _ocaml_compilers
ocamlc_byte       = _ocamlc_byte
ocaml_tool         = _ocaml_tool
ocaml_tool_vm      = _ocaml_tool_vm
ocaml_tool_sys     = _ocaml_tool_sys

# ocamlc_runtime    = _ocamlc_runtime
# ocamlc_fixpoint    = _ocamlc_fixpoint

run_repl = _run_repl
run_tool = _run_tool
tool_module  = _tool_module
tool_signature = _tool_signature
