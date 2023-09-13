## treat required libs as toolchain rather than sys config data

BYTECCLIBS = "@bytecclibs@".split(" ")
VM_LIBDEPS = "@bytecclibs@".split(" ")
# fld in utils:Config - bytecomp_c_libraries = "@bytecclibs@"
NATIVECCLIBS = "@nativecclibs@".split(" ")
SYS_LIBDEPS = "@nativecclibs@".split(" ")
# fld in utils:Config - native_c_libraries = "@nativecclibs@"

(* toolchain or sys config? *)
# supports_shared_libraries true if has dlopen
# i.e. HAS_DLOPEN etc.
# upcase: used by makefiles
# dncase: fld in Config module
SUPPORTS_SHARED_LIBRARIES = "@supports_shared_libraries@" == "true"
supports_shared_libraries = "@supports_shared_libraries@" == "true"
Makefile:
ifeq "$(SUPPORTS_SHARED_LIBRARIES)" "true"
runtime_BYTECODE_STATIC_LIBRARIES += runtime/libcamlrun_pic.$(A)
runtime_BYTECODE_SHARED_LIBRARIES += runtime/libcamlrun_shared.$(SO)
runtime_NATIVE_STATIC_LIBRARIES += runtime/libasmrun_pic.$(A)
runtime_NATIVE_SHARED_LIBRARIES += runtime/libasmrun_shared.$(SO)
endif

LIBUNWIND_LINK_FLAGS = "@libunwind_link_flags@"
