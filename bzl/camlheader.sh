#!/bin/bash
echo "CURRENT_TIME $(date +%s)"
## echo "RANDOM_HASH $(cat /proc/sys/kernel/random/uuid)"
echo "STABLE_GIT_COMMIT $(git rev-parse HEAD)"
echo "STABLE_USER_NAME $USER"

## Makefile.config:
# ## Installation directories
prefix=/usr/local
exec_prefix=${prefix}
# ### Where to install the binaries
BINDIR=${exec_prefix}/bin

# extracted from ./configure (configure.ac)
## Test whether #! scripts are supported
echo '#! /bin/cat
exit 69
' >conftest
chmod u+x conftest
(SHELL=/bin/sh; export SHELL; ./conftest >/dev/null 2>&1)
if test $? -ne 69; then
   ac_cv_sys_interpreter=yes
else
   ac_cv_sys_interpreter=no
fi
rm -f conftest
# fi
# { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_sys_interpreter" # >&5
# $as_echo "$ac_cv_sys_interpreter" } #  >&6;
interpval=$ac_cv_sys_interpreter

# echo $interpval

long_shebang=false
if test "x$interpval" = "xyes"; then :
  case $host in #(
  *-cygwin|*-*-mingw32|*-pc-windows) :
    shebangscripts=false ;; #(
  *) :
    shebangscripts=true
       prev_exec_prefix="$exec_prefix"
       if test "x$exec_prefix" = "xNONE"; then :
  exec_prefix="$prefix"
fi
       eval "expanded_bindir=\"$bindir\""
       exec_prefix="$prev_exec_prefix"
       # Assume maximum shebang is 128 chars; less #!, /ocamlrun, an optional
       # 1 char suffix and the \0 leaving 115 characters
       if test "${#expanded_bindir}" -gt 115; then :
  long_shebang=true
fi

     ;;
esac
else
  shebangscripts=false
fi

# echo "shebangscripts: " $shebangscripts
# echo "long_shebang: " $long_shebang
# echo "BINDIR: " $BINDIR

## from make log:
# echo '#!/usr/local/bin/ocamlrun' > camlheader
# echo '#!/usr/local/bin/ocamlrun' > target_camlheader
## \012 == LF (x0A)
# echo '#!' | tr -d '\012' > camlheader_ur
# echo '#!/usr/local/bin/ocamlrund' > camlheaderd
# echo '#!/usr/local/bin/ocamlrund' > target_camlheaderd
# echo '#!/usr/local/bin/ocamlruni' > camlheaderi
# echo '#!/usr/local/bin/ocamlruni' > target_camlheaderi


## stdlib/Makefile:
if test "x$long_shebang" = "xtrue"; then :
	echo "STABLE_CAMLHEADER #!/bin/sh\nexec $(BINDIR)/ocamlrun $$0 $$@"
else
	echo "STABLE_CAMLHEADER #!${BINDIR}/ocamlrun"
	echo "STABLE_TARGET_CAMLHEADER #!${BINDIR}/ocamlrun"
	# echo "STABLE_CAMLHEADER_UR `'#!' | tr -d '\012'`"
	echo "STABLE_CAMLHEADERD #!${BINDIR}/ocamlrund"
	echo "STABLE_TARGET_CAMLHEADERD #!${BINDIR}/ocamlrund"
	echo "STABLE_CAMLHEADERI #!${BINDIR}/ocamlruni"
	echo "STABLE_TARGET_CAMLHEADERI #!${BINDIR}/ocamlruni"
fi
