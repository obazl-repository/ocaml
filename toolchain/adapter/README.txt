######## toolchain adapters ########

## We need several to avoid circularity. Actually we need several
## toolchain types.

## Bootstrap toolchain: a singleton toolchain, whose toolset is
## exogenous: either C code (ocamlrun, ocamlyacc) or precompiled OCaml
## code (ocamlc, ocamllex.

## Baseline toolchains (for lack of a better term) include OCaml tools
## and libs built using the bootstrap toolchain.


## stages:  bootstrap > dev > prod (vm>vm, vm>sys, [sys>vm, sys>sys])

## (or:  bootstrap > kneecap > headcase, or bootstap > shoulderstrap )

