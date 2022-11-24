let bindir = {|/usr/local/bin|}

let standard_library_default = {|/usr/local/lib/ocaml|}

let ccomp_type = {|cc|}
let c_compiler = {|gcc|}
let c_output_obj = {|-o |}
let c_has_debug_prefix_map = true
let as_has_debug_prefix_map = false
let ocamlc_cflags = {|-O2 -fno-strict-aliasing -fwrapv -pthread  |}
let ocamlc_cppflags = {| -D_FILE_OFFSET_BITS=64 |}
(* #7678: ocamlopt uses these only to compile .c files, and the behaviour for
          the two drivers should be identical. *)
let ocamlopt_cflags = {|-O2 -fno-strict-aliasing -fwrapv -pthread  |}
let ocamlopt_cppflags = {| -D_FILE_OFFSET_BITS=64 |}
let bytecomp_c_libraries = {| -lm  -lpthread|}
(* bytecomp_c_compiler and native_c_compiler have been supported for a
   long time and are retained for backwards compatibility.
   For programs that don't need compatibility with older OCaml releases
   the recommended approach is to use the constituent variables
   c_compiler, ocamlc_cflags, ocamlc_cppflags etc., directly.
*)
let bytecomp_c_compiler =
  c_compiler ^ " " ^ ocamlc_cflags ^ " " ^ ocamlc_cppflags
let native_c_compiler =
  c_compiler ^ " " ^ ocamlopt_cflags ^ " " ^ ocamlopt_cppflags
let native_c_libraries = {| -lm  -lpthread|}
let native_pack_linker = {|ld -r -arch x86_64 -o |}
let default_rpath = {||}
let mksharedlibrpath = {||}
let ar = {|ar|}
let supports_shared_libraries = true

(*
  -ffunction-sections controlled by cc_library linkopts, but
  asmcomp/asmlink.ml contains code that is conditional on it:
  if !Clflags.function_sections then ...
  i.e. there's more to it than whether the platform supports it.
  the Cflags.function_sections flag should be set at build time, not
  config time. *)
let function_sections = false

let afl_instrument = false

let architecture = {|amd64|}
let model = {|default|}
let system = {|macosx|}

let asm = {|gcc -c -Wno-trigraphs|}
let asm_cfi_supported = true
let with_frame_pointers = false
let profinfo = false
let profinfo_width = 0

let ext_exe = {||}
let ext_obj = "." ^ {|o|}
let ext_asm = "." ^ {|s|}
let ext_lib = "." ^ {|a|}
let ext_dll = "." ^ {|so|}

let host = {|x86_64-apple-darwin22.1.0|}
let target = {|x86_64-apple-darwin22.1.0|}

let systhread_supported = true
