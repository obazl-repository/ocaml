#!/bin/sh

## usage:  ./runtime/primitives.gen_json.sh > runtime/primitives.json

## Use this to generate primitives.json. Not used in build process;
## only needed when primitives change. The primitives.json file should
## be under version control.

# Not portable - uses GNU sed to uppercase macro names

# #8985: the meaning of character range a-z depends on the locale, so force C
#        locale throughout.
export LC_ALL=C
echo "{"
echo "  \"primitives\":"
echo "     ["
(
  for prim in \
      alloc array compare extern floats gc_ctrl hash intern interp ints.original io \
      lexing md5 meta memprof obj parsing signals str sys callback weak \
      finalise domain platform fiber memory startup_aux runtime_events sync \
      dynlink backtrace_byt backtrace afl \
      bigarray prng
  do
      sed -n -e "s/^CAMLprim value caml_\([a-z0-9_][a-z0-9_]*\).*/        {\"prim\": \"\1\", \"src\": \"$prim.c\"}/p" \
          "runtime/$prim.c";

  done
) | sort | uniq | sed '$!s/$/,/'
echo "     ],"
echo "    \"int64\": ["
  sed -n -e "s/^CAMLprim_int64_[0-9](\([a-z0-9_][a-z0-9_]*\)).*/        {\"prim\": \"\1\", \"src\": \"ints.c\"}/p" runtime/ints.original.c \
 | sort | uniq | sed '$!s/$/,/'
echo "     ]"
echo "}"

#    | gsed -n -e "s/#\([^#]*\)#/\"macro\": \"\U\1\"/p" \

  # sed -n -e "s/^CAMLprim_int64_[0-9](\([a-z0-9_][a-z0-9_]*\)).*/        {\"prim\": \"\1\", \"src\": \"ints.c\"}\n        {\"prim\": \"int64_\1_native\", \"src\": \"ints.c\" }/p" runtime/ints.c
