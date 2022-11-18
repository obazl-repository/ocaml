let ccomp_type = {|cc|}
let c_compiler = {|clang|}
let c_output_obj = {|-o |}
let ocamlc_cflags = {| -D_FORTIFY_SOURCE=1 -fstack-protector -fcolor-diagnostics -Wall -Wthread-safety -Wself-assign -fno-omit-frame-pointer -O0 -DDEBUG DEBUG_PREFIX_MAP_PWD=. -isysroot __BAZEL_XCODE_SDKROOT__ -F__BAZEL_XCODE_SDKROOT__/System/Library/Frameworks -F__BAZEL_XCODE_DEVELOPER_DIR__/Platforms/MacOSX.platform/Developer/Library/Frameworks -no-canonical-prefixes -pthread -no-canonical-prefixes -Wno-builtin-macro-redefined -D__DATE__="redacted" -D__TIMESTAMP__="redacted" -D__TIME__="redacted" -target x86_64-apple-macosx13.0|}
let ocamlc_cppflags = {|-D_FORTIFY_SOURCE=1-fstack-protector-fcolor-diagnostics-Wall-Wthread-safety-Wself-assign-fno-omit-frame-pointer-O0-DDEBUGDEBUG_PREFIX_MAP_PWD=.-isysroot__BAZEL_XCODE_SDKROOT__-F__BAZEL_XCODE_SDKROOT__/System/Library/Frameworks-F__BAZEL_XCODE_DEVELOPER_DIR__/Platforms/MacOSX.platform/Developer/Library/Frameworks-no-canonical-prefixes-pthread-no-canonical-prefixes-Wno-builtin-macro-redefined-D__DATE__="redacted"-D__TIMESTAMP__="redacted"-D__TIME__="redacted"-targetx86_64-apple-macosx13.0|}
let ocamlopt_cflags = {| -D_FORTIFY_SOURCE=1 -fstack-protector -fcolor-diagnostics -Wall -Wthread-safety -Wself-assign -fno-omit-frame-pointer -O0 -DDEBUG DEBUG_PREFIX_MAP_PWD=. -isysroot __BAZEL_XCODE_SDKROOT__ -F__BAZEL_XCODE_SDKROOT__/System/Library/Frameworks -F__BAZEL_XCODE_DEVELOPER_DIR__/Platforms/MacOSX.platform/Developer/Library/Frameworks -no-canonical-prefixes -pthread -no-canonical-prefixes -Wno-builtin-macro-redefined -D__DATE__="redacted" -D__TIMESTAMP__="redacted" -D__TIME__="redacted" -target x86_64-apple-macosx13.0|}
let ocamlopt_cppflags = {|-D_FORTIFY_SOURCE=1-fstack-protector-fcolor-diagnostics-Wall-Wthread-safety-Wself-assign-fno-omit-frame-pointer-O0-DDEBUGDEBUG_PREFIX_MAP_PWD=.-isysroot__BAZEL_XCODE_SDKROOT__-F__BAZEL_XCODE_SDKROOT__/System/Library/Frameworks-F__BAZEL_XCODE_DEVELOPER_DIR__/Platforms/MacOSX.platform/Developer/Library/Frameworks-no-canonical-prefixes-pthread-no-canonical-prefixes-Wno-builtin-macro-redefined-D__DATE__="redacted"-D__TIMESTAMP__="redacted"-D__TIME__="redacted"-targetx86_64-apple-macosx13.0|}
let asm = {|clang  -D_FORTIFY_SOURCE=1 -fstack-protector -fcolor-diagnostics -Wall -Wthread-safety -Wself-assign -fno-omit-frame-pointer -O0 -DDEBUG DEBUG_PREFIX_MAP_PWD=. -isysroot __BAZEL_XCODE_SDKROOT__ -F__BAZEL_XCODE_SDKROOT__/System/Library/Frameworks -F__BAZEL_XCODE_DEVELOPER_DIR__/Platforms/MacOSX.platform/Developer/Library/Frameworks -no-canonical-prefixes -pthread -no-canonical-prefixes -Wno-builtin-macro-redefined -D__DATE__="redacted" -D__TIMESTAMP__="redacted" -D__TIME__="redacted" -target x86_64-apple-macosx13.0 -Wno-trigraphs|}

let bytecomp_c_compiler =
  c_compiler ^ " " ^ ocamlc_cflags ^ " " ^ ocamlc_cppflags
let native_c_compiler =
  c_compiler ^ " " ^ ocamlopt_cflags ^ " " ^ ocamlopt_cppflags

let ar = {|external/local_config_cc/libtool|}

let architecture = {|amd64|}
let model = {|default|}
let system = {|macosx|}

