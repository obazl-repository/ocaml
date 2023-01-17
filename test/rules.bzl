load("//test/rules:ocaml_test.bzl", _ocaml_test = "ocaml_test")
load("//test/rules:repl_test.bzl", _repl_test = "repl_test")

load("//test/rules:batch_expect_test.bzl",
     _expect_vv_test = "expect_vv_test",
     _expect_vs_test = "expect_vs_test",
     _expect_ss_test = "expect_ss_test",
     _expect_sv_test = "expect_sv_test",
     _batch_expect_test = "batch_expect_test")

# load("//test/rules:expect_vv_test.bzl",
#      _expect_vv_test = "expect_vv_test")
# load("//test/rules:expect_ss_test.bzl",
#      _expect_ss_test = "expect_ss_test")

load("//test/rules:compile_module_test.bzl",
     _compile_module_test = "compile_module_test")

load("//test/rules:compile_fail_test.bzl",
     _compile_fail_test = "compile_fail_test")

load("//test/rules:inline_expect_test.bzl",
     _inline_expect_test = "inline_expect_test")
load("//test/rules:lambda_expect_test.bzl",
     _lambda_expect_test = "lambda_expect_test")

load("//test/rules:test_executable.bzl",
     _test_executable = "test_executable",
     _test_vv_executable = "test_vv_executable",
     _test_vs_executable = "test_vs_executable",
     _test_ss_executable = "test_ss_executable",
     _test_sv_executable = "test_sv_executable")

load("//test/rules:test_library.bzl", _test_library = "test_library")

load("//test/rules:test_module.bzl",  _test_module  = "test_module")
load("//test/rules:inline_expect_module.bzl",
     _inline_expect_module  = "inline_expect_module")
load("//test/rules:test_infer_signature.bzl",
     _test_infer_signature  = "test_infer_signature")
load("//test/rules:test_signature.bzl", _test_signature = "test_signature")

ocaml_test = _ocaml_test
repl_test = _repl_test

expect_vv_test = _expect_vv_test
expect_vs_test = _expect_vs_test
expect_ss_test = _expect_ss_test
expect_sv_test = _expect_sv_test
batch_expect_test = _batch_expect_test

compile_module_test = _compile_module_test
compile_fail_test = _compile_fail_test

inline_expect_test = _inline_expect_test
lambda_expect_test = _lambda_expect_test
test_executable = _test_executable
test_vv_executable = _test_vv_executable
test_vs_executable = _test_vs_executable
test_ss_executable = _test_ss_executable
test_sv_executable = _test_sv_executable
test_library = _test_library
test_module  = _test_module
inline_expect_module  = _inline_expect_module
test_infer_signature = _test_infer_signature
test_signature = _test_signature
