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

# load("//bzl/rules:bootstrap_ns_resolver.bzl",
#      _bootstrap_ns_resolver = "bootstrap_ns_resolver")

# load("//bzl/rules:bootstrap_preprocess.bzl",
#      _bootstrap_preprocess = "bootstrap_preprocess")

load("//bzl/rules:ocamlc_fixpoint.bzl",
     _ocamlc_fixpoint = "ocamlc_fixpoint")

load("//bzl/rules:ocamlc_runtime.bzl",
     _ocamlc_runtime = "ocamlc_runtime")

load("//bzl/rules:bootstrap_ocamllex.bzl",
     _bootstrap_ocamllex = "bootstrap_ocamllex")

load("//bzl/rules:bootstrap_ocamlyacc.bzl",
     _bootstrap_ocamlyacc = "bootstrap_ocamlyacc")

load("//bzl/rules:bootstrap_signature.bzl",
     _bootstrap_signature = "bootstrap_signature")


ocamlrun = _ocamlrun
promote  = _promote

bootstrap_archive      = _bootstrap_archive
bootstrap_executable      = _bootstrap_executable
bootstrap_library  = _bootstrap_library
bootstrap_module      = _bootstrap_module
# bootstrap_ns_resolver = _bootstrap_ns_resolver
# bootstrap_preprocess  = _bootstrap_preprocess
ocamlc_runtime    = _ocamlc_runtime
ocamlc_fixpoint    = _ocamlc_fixpoint
bootstrap_ocamllex    = _bootstrap_ocamllex
bootstrap_ocamlyacc   = _bootstrap_ocamlyacc
bootstrap_signature   = _bootstrap_signature
