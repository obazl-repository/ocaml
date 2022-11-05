load("//bzl/rules:ocamlrun.bzl", _ocamlrun = "ocamlrun")

load("//bzl/rules:promote.bzl", _promote = "promote")

load("//bzl/rules:bootstrap_archive.bzl",
     _bootstrap_archive = "bootstrap_archive")

load("//bzl/rules:bootstrap_executable.bzl",
     _bootstrap_executable = "bootstrap_executable")

load("//bzl/rules:bootstrap_module.bzl",
     _bootstrap_module = "bootstrap_module")

load("//bzl/rules:bootstrap_library.bzl",
     _bootstrap_library = "bootstrap_library")

load("//bzl/rules:bootstrap_ns.bzl",
     _bootstrap_ns = "bootstrap_ns")

# load("//bzl/rules:bootstrap_preprocess.bzl",
#      _bootstrap_preprocess = "bootstrap_preprocess")

load("//bzl/rules:bootstrap_ocamllex.bzl",
     _bootstrap_ocamllex = "bootstrap_ocamllex")

load("//bzl/rules:bootstrap_ocamlyacc.bzl",
     _bootstrap_ocamlyacc = "bootstrap_ocamlyacc")

load("//bzl/rules:bootstrap_repl.bzl",
     _bootstrap_repl = "bootstrap_repl")

load("//bzl/rules:bootstrap_signature.bzl",
     _bootstrap_signature = "bootstrap_signature")

load("//bzl/rules:bootstrap_test.bzl",
     _bootstrap_test = "bootstrap_test")

load("//bzl/rules:boot_compiler.bzl", _boot_compiler = "boot_compiler")
load("//bzl/rules:ocamlc_fixpoint.bzl", _ocamlc_fixpoint = "ocamlc_fixpoint")
# load("//bzl/rules:ocamlc_runtime.bzl", _ocamlc_runtime = "ocamlc_runtime")

ocamlrun = _ocamlrun
promote  = _promote

bootstrap_archive      = _bootstrap_archive
bootstrap_executable      = _bootstrap_executable
bootstrap_library  = _bootstrap_library
bootstrap_module      = _bootstrap_module
bootstrap_ns = _bootstrap_ns
# bootstrap_preprocess  = _bootstrap_preprocess
bootstrap_ocamllex    = _bootstrap_ocamllex
bootstrap_ocamlyacc   = _bootstrap_ocamlyacc
bootstrap_repl   = _bootstrap_repl
bootstrap_signature   = _bootstrap_signature
bootstrap_test   = _bootstrap_test

boot_compiler    = _boot_compiler
# ocamlc_runtime    = _ocamlc_runtime
ocamlc_fixpoint    = _ocamlc_fixpoint
