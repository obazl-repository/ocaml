These are user-controlled features, not feature-test outputs, and
should be set via CLI config flags rather than ./configure

let bytecomp_c_libraries = {@QS@|@bytecclibs@|@QS@}
(* bytecomp_c_compiler and native_c_compiler have been supported for a
   long time and are retained for backwards compatibility.
   For programs that don't need compatibility with older OCaml releases
   the recommended approach is to use the constituent variables
   c_compiler, ocamlc_cflags, ocamlc_cppflags etc., directly.
*)

(*
  -ffunction-sections controlled by cc_library linkopts, but
  asmcomp/asmlink.ml contains code that is conditional on it:
  if !Clflags.function_sections then ...
  i.e. there's more to it than whether the platform supports it.
  the Cflags.function_sections flag should be set at build time, not
  config time. *)
let function_sections = false
FUNCTION_SECTIONS = "@function_sections@" == "true"

let afl_instrument = false
AFL_INSTRUMENT = "@afl@" == "true"
afl_instrument = "@afl@" == "true"

# upcase: used as #define macro
# dncase: fld in Config module
FLAT_FLOAT_ARRAY = "@flat_float_array@" == "true"
flat_float_array = "@flat_float_array@" == "true"

let with_frame_pointers = @frame_pointers@
let profinfo = @profinfo@
let profinfo_width = @profinfo_width@

# Compile-time option to $(CC) to add a directory to be searched
# at run-time for shared libraries
RPATH = "@rpath@"
let default_rpath = {@QS@|@rpath@|@QS@}

let ext_exe = {||}
let ext_obj = "." ^ {|o|}
let ext_asm = "." ^ {|s|}
let ext_lib = "." ^ {|a|}
let ext_dll = "." ^ {|so|}

let host = {|x86_64-apple-darwin22.1.0|}
let target = {|x86_64-apple-darwin22.1.0|}

let host = {@QS@|@host@|@QS@}
let target = {@QS@|@target@|@QS@}

let systhread_supported = @systhread_support@

let flexdll_dirs = [@flexdll_dir@]

### Which libraries to compile and install
# Currently available:
#       dynlink           Dynamic linking (bytecode and native)
#       (win32)unix       Unix system calls
#       str               Regular expressions and high-level string processing
#       systhreads        Same as threads, requires POSIX threads
OTHERLIBRARIES = "@otherlibraries@"

FLAMBDA = "@flambda@" == "true"
WITH_FLAMBDA_INVARIANTS = "@flambda_invariants@" == "true"
flambda = "@flambda@" == "true"
with_flambda_invariants = "@flambda_invariants@" == "true"

WITH_CMM_INVARIANTS = "@cmm_invariants@" == "true"
with_cmm_invariants = "@cmm_invariants@" == "true"

FORCE_INSTRUMENTED_RUNTIME = "@force_instrumented_runtime@" == "true"
force_instrumented_runtime = "@force_instrumented_runtime@" == "true"

FORCE_SAFE_STRING = True
DEFAULT_SAFE_STRING = True

