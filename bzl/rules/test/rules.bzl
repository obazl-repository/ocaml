load("//bzl/rules/test:ocaml_test.bzl", _ocaml_test = "ocaml_test")
load("//bzl/rules/test:repl_test.bzl", _repl_test = "repl_test")

load("//bzl/rules/test:expect_test.bzl",
     _expect_test = "expect_test")

# load("//bzl/rules/test:expect_vv_test.bzl",
#      _expect_vv_test = "expect_vv_test")
# load("//bzl/rules/test:expect_ss_test.bzl",
#      _expect_ss_test = "expect_ss_test")

load("//bzl/rules/test:compile_fail_test.bzl",
     _compile_fail_test = "compile_fail_test")

load("//bzl/rules/test:inline_expect_test.bzl",
     _inline_expect_test = "inline_expect_test")
load("//bzl/rules/test:lambda_expect_test.bzl",
     _lambda_expect_test = "lambda_expect_test")

load("//bzl/rules/test:test_archive.bzl", _test_archive = "test_archive")
load("//bzl/rules/test:test_executable.bzl",
     _test_executable = "test_executable")
load("//bzl/rules/test:test_library.bzl", _test_library = "test_library")

load("//bzl/rules/test:test_module.bzl",  _test_module  = "test_module")
load("//bzl/rules/test:test_signature.bzl", _test_signature = "test_signature")

# load("//bzl/rules/test:baseline_test.bzl",
#      _baseline_test = "baseline_test")

# baseline_test   = _baseline_test

ocaml_test = _ocaml_test
repl_test = _repl_test

# expect_vv_test = _expect_vv_test
# expect_ss_test = _expect_ss_test
expect_test = _expect_test

compile_fail_test = _compile_fail_test

inline_expect_test = _inline_expect_test
lambda_expect_test = _lambda_expect_test
test_archive = _test_archive
test_executable = _test_executable
test_library = _test_library
test_module  = _test_module
test_signature = _test_signature
