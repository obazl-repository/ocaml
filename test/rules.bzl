load("//test/rules:repl_test.bzl", _repl_test = "repl_test")

load("//test/rules:inline_test.bzl",
     _inline_vv_test = "inline_vv_test",
     _inline_vs_test = "inline_vs_test",
     _inline_ss_test = "inline_ss_test",
     _inline_sv_test = "inline_sv_test",
     _inline_test_macro = "inline_test_macro")

load("//test/rules:batch_test.bzl",
     _batch_vv_test = "batch_vv_test",
     _batch_vs_test = "batch_vs_test",
     _batch_ss_test = "batch_ss_test",
     _batch_sv_test = "batch_sv_test",
     _batch_test_macro = "batch_test_macro")

load("//test/rules:compile_module_test.bzl",
     _compile_module_testx = "compile_module_testx")

load("//test/rules:compile_fail_test.bzl",
     _compile_fail_test = "compile_fail_test")

load("//test/rules:inline_expect_test.bzl",
     _inline_expect_test = "inline_expect_test")
load("//test/rules:lambda_expect_test.bzl",
     _lambda_expect_test = "lambda_expect_test")

load("//test/rules:test_executable.bzl",
     _test_executable_macro = "test_executable_macro",
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

repl_test = _repl_test

inline_vv_test = _inline_vv_test
inline_vs_test = _inline_vs_test
inline_ss_test = _inline_ss_test
inline_sv_test = _inline_sv_test
inline_test_macro = _inline_test_macro

batch_vv_test = _batch_vv_test
batch_vs_test = _batch_vs_test
batch_ss_test = _batch_ss_test
batch_sv_test = _batch_sv_test
batch_test_macro = _batch_test_macro

compile_module_testx = _compile_module_testx
compile_fail_test = _compile_fail_test

inline_expect_test = _inline_expect_test
lambda_expect_test = _lambda_expect_test
test_executable_macro = _test_executable_macro
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
