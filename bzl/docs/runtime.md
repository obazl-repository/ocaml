## BUILD.bazel notes

Make targets mapping:

ld.conf: $(ROOTDIR)/Makefile.config
	echo "$(STUBLIBDIR)" > $@
	echo "$(LIBDIR)" >> $@

primitives >  genrule: primitives_dat
prims.c >  genrule: prims_c

caml/opnames.h :
caml/jumptbl.h :
caml/version.h :

sak$(EXE) >    cc_binary: sak.exe
sak.$(O) >   none (included in sak.exe target)
build_config.h >  genrule: build_config_h

NB: variant builds are controlled by build settings, not variant targets

ocamlrun$(EXE) >     cc_binary: ocamlrun
ocamlruns$(EXE) :
libcamlrun.$(A) >    cc_library: camlrun
libcamlrun_non_shared.$(A) >  camlrun (no separate target)
ocamlrund$(EXE) >      camlrun (no separate target)
libcamlrund.$(A) >     camlrun (no separate target)
ocamlruni$(EXE) :
libcamlruni.$(A) :
libcamlrun_pic.$(A) :
libcamlrun_shared.$(SO) :
libasmrun.$(A) >    cc_library:  asmrun
libasmrund.$(A) :
libasmruni.$(A) :
libasmrun_pic.$(A) :
libasmrun_shared.$(SO) :

# Compilation of assembly files
%.o: %.S
	$(ASPP) $(ASPPFLAGS) -o $@ $<

%_libasmrunpic.o :
domain_state64.inc :
domain_state32.inc :
amd64nt.obj :
i386nt.obj :
%_libasmrunpic.obj :


