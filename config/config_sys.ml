(* config/config_sys.ml.  Generated from config_sys.ml.in by configure. *)
#2 "utils/config.generated.ml.in"
(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

let bindir = {|/usr/local/bin|}

let standard_library_default = {|/usr/local/lib/ocaml|}

let default_rpath = {||}
let mksharedlibrpath = {||}
let ar = {|ar|}
let supports_shared_libraries = true
let mkdll, mkexe, mkmaindll =
  if Sys.win32 || Sys.cygwin && supports_shared_libraries then
    let flexlink =
      let flexlink =
        Option.value ~default:"flexlink" (Sys.getenv_opt "OCAML_FLEXLINK")
      in
      let f i =
        let c = flexlink.[i] in
        if c = '/' && Sys.win32 then '\\' else c
      in
      String.init (String.length flexlink) f
    in
    let flexdll_chain = {||} in
    let flexlink_flags = {||} in
    let flags = " -chain " ^ flexdll_chain ^ " " ^ flexlink_flags in
    flexlink ^ flags ^ {| |},
    flexlink ^ " -exe" ^ flags
      ^ {| |} ^ {|-Wl,-no_compact_unwind |},
    flexlink ^ " -maindll" ^ flags ^ {| |}
  else
    {|gcc -shared -undefined dynamic_lookup -Wl,-no_compact_unwind -Wl,-w  |},
    {|gcc -O2 -fno-strict-aliasing -fwrapv -pthread  -Wl,-no_compact_unwind |},
    {|gcc -shared -undefined dynamic_lookup -Wl,-no_compact_unwind -Wl,-w|}

let flambda = false
let with_flambda_invariants = false
let with_cmm_invariants = false
let windows_unicode = 0 != 0
let force_instrumented_runtime = false

let flat_float_array = true

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

let flexdll_dirs = []
