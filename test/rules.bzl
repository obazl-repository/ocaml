load("//test/rules:ocaml_test.bzl", _ocaml_test = "ocaml_test")
load("//test/rules:repl_test.bzl", _repl_test = "repl_test")

load("//test/rules:expect_test.bzl",
     _expect_vv_test = "expect_vv_test",
     _expect_vs_test = "expect_vs_test",
     _expect_ss_test = "expect_ss_test",
     _expect_sv_test = "expect_sv_test",
     _expect_test = "expect_test")

# load("//test/rules:expect_vv_test.bzl",
#      _expect_vv_test = "expect_vv_test")
# load("//test/rules:expect_ss_test.bzl",
#      _expect_ss_test = "expect_ss_test")

load("//test/rules:compile_fail_test.bzl",
     _compile_fail_test = "compile_fail_test")

load("//test/rules:inline_expect_test.bzl",
     _inline_expect_test = "inline_expect_test")
load("//test/rules:lambda_expect_test.bzl",
     _lambda_expect_test = "lambda_expect_test")

load("//test/rules:test_archive.bzl", _test_archive = "test_archive")
load("//test/rules:test_executable.bzl",
     _test_executable = "test_executable",
     _vv_test_executable = "vv_test_executable",
     _vs_test_executable = "vs_test_executable",
     _ss_test_executable = "ss_test_executable",
     _sv_test_executable = "sv_test_executable")

load("//test/rules:test_library.bzl", _test_library = "test_library")

load("//test/rules:test_module.bzl",  _test_module  = "test_module")
load("//test/rules:test_signature.bzl", _test_signature = "test_signature")

ocaml_test = _ocaml_test
repl_test = _repl_test

expect_vv_test = _expect_vv_test
expect_vs_test = _expect_vs_test
expect_ss_test = _expect_ss_test
expect_sv_test = _expect_sv_test
expect_test = _expect_test

compile_fail_test = _compile_fail_test

inline_expect_test = _inline_expect_test
lambda_expect_test = _lambda_expect_test
test_archive = _test_archive
test_executable = _test_executable
vv_test_executable = _vv_test_executable
vs_test_executable = _vs_test_executable
ss_test_executable = _ss_test_executable
sv_test_executable = _sv_test_executable
test_library = _test_library
test_module  = _test_module
test_signature = _test_signature
