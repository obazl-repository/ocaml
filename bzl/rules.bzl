load("//bzl/rules:boot_archive.bzl",
     _boot_archive = "boot_archive")

load("//bzl/rules:boot_executable.bzl",
     _boot_executable = "boot_executable")

load("//bzl/rules:boot_module.bzl",
     _boot_module = "boot_module")

load("//bzl/rules:boot_library.bzl",
     _boot_library = "boot_library")

# load("//bzl/rules:bootstrap_ns.bzl",
#      _bootstrap_ns = "bootstrap_ns")

# load("//bzl/rules:bootstrap_preprocess.bzl",
#      _bootstrap_preprocess = "bootstrap_preprocess")

load("//bzl/rules:boot_lexer.bzl",
     _boot_lexer = "boot_lexer")

load("//bzl/rules:boot_yacc.bzl",
     _boot_yacc = "boot_yacc")

# load("//bzl/rules:bootstrap_repl.bzl",
#      _bootstrap_repl = "bootstrap_repl")

load("//bzl/rules:boot_signature.bzl",
     _boot_signature = "boot_signature")

load("//bzl/rules:kick_test.bzl",
     _kick_test = "kick_test")

load("//bzl/rules:boot_compiler.bzl", _boot_compiler = "boot_compiler")
# load("//bzl/rules:ocamlc_fixpoint.bzl", _ocamlc_fixpoint = "ocamlc_fixpoint")
# load("//bzl/rules:ocamlc_runtime.bzl", _ocamlc_runtime = "ocamlc_runtime")

boot_archive      = _boot_archive
boot_executable      = _boot_executable
boot_library  = _boot_library
boot_module      = _boot_module
# bootstrap_ns = _bootstrap_ns
# bootstrap_preprocess  = _bootstrap_preprocess
boot_lexer    = _boot_lexer
boot_yacc   = _boot_yacc
# bootstrap_repl   = _bootstrap_repl
boot_signature   = _boot_signature
kick_test   = _kick_test

boot_compiler    = _boot_compiler
# ocamlc_runtime    = _ocamlc_runtime
# ocamlc_fixpoint    = _ocamlc_fixpoint
