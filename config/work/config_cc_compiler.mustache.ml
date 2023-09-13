let ccomp_type = {|{{ccomptype}}|}

let c_compiler = {|{{compiler}}|}

let c_output_obj = {|{{outputobj}} |}

let ocamlc_cflags = {|{{#c_compile_cmd_line}} {{{.}}}{{/c_compile_cmd_line}}|}

let ocamlc_cppflags = {|{{#preprocess_assemble_cmd_line}}{{{.}}}{{/preprocess_assemble_cmd_line}}|}

let ocamlopt_cflags = {|{{#c_compile_cmd_line}} {{{.}}}{{/c_compile_cmd_line}}|}

let ocamlopt_cppflags = {|{{#preprocess_assemble_cmd_line}}{{{.}}}{{/preprocess_assemble_cmd_line}}|}

(* whether the C compiler supports -fdebug-prefix-map (feature test) *)
let c_has_debug_prefix_map = {{cc_has_debug_prefix_map}}

let as_has_debug_prefix_map = {{as_has_debug_prefix_map}}

let asm = {|{{compiler}} {{#assemble_cmd_line}} {{{.}}}{{/assemble_cmd_line}}|}
(*
  upcase: used as #define
  dncase: Config fld
  let asm_cfi_supported = @asm_cfi_supported@
 *)

let bytecomp_c_compiler =
  c_compiler ^ " " ^ ocamlc_cflags ^ " " ^ ocamlc_cppflags
let native_c_compiler =
  c_compiler ^ " " ^ ocamlopt_cflags ^ " " ^ ocamlopt_cppflags

let ar = {|{{ar_executable}}|}

(* libunwind: only when tsan available *)
LIBUNWIND_AVAILABLE = "@libunwind_available@"
LIBUNWIND_INCLUDE_FLAGS = "@libunwind_include_flags@"

