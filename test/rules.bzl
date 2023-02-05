load("//test/rules:repl_test.bzl", _repl_test = "repl_test")

load("//test/rules:inline_test.bzl",
     _inline_assertion_vv_test = "inline_assertion_vv_test",
     _inline_assertion_vs_test = "inline_assertion_vs_test",
     _inline_assertion_ss_test = "inline_assertion_ss_test",
     _inline_assertion_sv_test = "inline_assertion_sv_test",
     _inline_assertion_tests = "inline_assertion_tests")

load("//test/rules:batch_test.bzl",
     _batch_vv_test = "batch_vv_test",
     _batch_vs_test = "batch_vs_test",
     _batch_ss_test = "batch_ss_test",
     _batch_sv_test = "batch_sv_test",
     _batch_tests = "batch_tests")

load("//test/rules:compiler_tests.bzl",
     _compile_module_tests    = "compile_module_tests",
     _compile_signature_tests = "compile_signature_tests",)

# load("//test/rules:compile_fail_test.bzl",
#      _compile_fail_test = "compile_fail_test")

load("//test/rules:ocamlcc_diff_test.bzl",
     _ocamlcc_diff_test = "ocamlcc_diff_test",
     _ocamlcc_diff_tests = "ocamlcc_diff_tests")

# load("//test/rules:compile_dump_diff_test.bzl",
#      _compile_dump_diff_test_macro = "compile_dump_diff_test_macro")
     # _compile_dump_diff_test_sys_macro = "compile_dump_diff_test_sys_macro")

# load("//test/rules:inline_expect_test.bzl",
#      _inline_expect_test = "inline_expect_test")
load("//test/rules:inline_expect_module.bzl",
     _inline_expect_module  = "inline_expect_module")

load("//test/rules:test_program.bzl",
     _module_program_tests = "module_program_tests",
     _test_program = "test_program",
     _test_program_outputs = "test_program_outputs",
     _test_vv_executable = "test_vv_executable",
     _test_vs_executable = "test_vs_executable",
     _test_ss_executable = "test_ss_executable",
     _test_sv_executable = "test_sv_executable")

load("//test/rules:test_library.bzl", _test_library = "test_library")

load("//test/rules:test_module.bzl",  _test_module  = "test_module")
load("//test/rules:test_infer_signature.bzl",
     _test_infer_signature  = "test_infer_signature")
load("//test/rules:test_signature.bzl", _test_signature = "test_signature")

repl_test = _repl_test

inline_assertion_vv_test = _inline_assertion_vv_test
inline_assertion_vs_test = _inline_assertion_vs_test
inline_assertion_ss_test = _inline_assertion_ss_test
inline_assertion_sv_test = _inline_assertion_sv_test
inline_assertion_tests = _inline_assertion_tests

batch_vv_test = _batch_vv_test
batch_vs_test = _batch_vs_test
batch_ss_test = _batch_ss_test
batch_sv_test = _batch_sv_test
batch_tests = _batch_tests

# compile_module_testx = _compile_module_testx
# compile_fail_test = _compile_fail_test

# inline_expect_test = _inline_expect_test
inline_expect_module  = _inline_expect_module

compile_module_tests = _compile_module_tests
compile_signature_tests = _compile_signature_tests

# compile_dump_diff_test_macro = _compile_dump_diff_test_macro


ocamlcc_diff_test = _ocamlcc_diff_test
ocamlcc_diff_tests = _ocamlcc_diff_tests

# compile_dump_diff_test_sys_macro = _compile_dump_diff_test_sys_macro
module_program_tests = _module_program_tests
test_program = _test_program
test_program_outputs = _test_program_outputs
test_vv_executable = _test_vv_executable
test_vs_executable = _test_vs_executable
test_ss_executable = _test_ss_executable
test_sv_executable = _test_sv_executable
test_library = _test_library
test_module  = _test_module
test_infer_signature = _test_infer_signature
test_signature = _test_signature
