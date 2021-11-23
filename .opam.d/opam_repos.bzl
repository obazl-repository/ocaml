load("@obazl_rules_ocaml//ocaml/_repo_rules:new_local_pkg_repository.bzl",
     "new_local_pkg_repository")

def fetch():
    new_local_pkg_repository(
        name       = "ppx_fixed_literal",
        build_file = "@//.opam.d/buildfiles/ppx_fixed_literal:BUILD.bazel",
        path       = "ppx_fixed_literal",
    )

    new_local_pkg_repository(
        name       = "conduit-lwt-unix",
        build_file = "@//.opam.d/buildfiles/conduit-lwt-unix:BUILD.bazel",
        path       = "conduit-lwt-unix",
    )

    new_local_pkg_repository(
        name       = "time_now",
        build_file = "@//.opam.d/buildfiles/time_now:BUILD.bazel",
        path       = "time_now",
    )

    new_local_pkg_repository(
        name       = "cstruct-sexp",
        build_file = "@//.opam.d/buildfiles/cstruct-sexp:BUILD.bazel",
        path       = "cstruct-sexp",
    )

    new_local_pkg_repository(
        name       = "bheap",
        build_file = "@//.opam.d/buildfiles/bheap:BUILD.bazel",
        path       = "bheap",
    )

    new_local_pkg_repository(
        name       = "metrics",
        build_file = "@//.opam.d/buildfiles/metrics:BUILD.bazel",
        path       = "metrics",
    )

    new_local_pkg_repository(
        name       = "bigarray-compat",
        build_file = "@//.opam.d/buildfiles/bigarray-compat:BUILD.bazel",
        path       = "bigarray-compat",
    )

    new_local_pkg_repository(
        name       = "ppx_string",
        build_file = "@//.opam.d/buildfiles/ppx_string:BUILD.bazel",
        path       = "ppx_string",
    )

    new_local_pkg_repository(
        name       = "magic-mime",
        build_file = "@//.opam.d/buildfiles/magic-mime:BUILD.bazel",
        path       = "magic-mime",
    )

    new_local_pkg_repository(
        name       = "asn1-combinators",
        build_file = "@//.opam.d/buildfiles/asn1-combinators:BUILD.bazel",
        path       = "asn1-combinators",
    )

    new_local_pkg_repository(
        name       = "uri-sexp",
        build_file = "@//.opam.d/buildfiles/uri-sexp:BUILD.bazel",
        path       = "uri-sexp",
    )

    new_local_pkg_repository(
        name       = "pprint",
        build_file = "@//.opam.d/buildfiles/pprint:BUILD.bazel",
        path       = "pprint",
    )

    new_local_pkg_repository(
        name       = "mirage-crypto-rng",
        build_file = "@//.opam.d/buildfiles/mirage-crypto-rng:BUILD.bazel",
        path       = "mirage-crypto-rng",
        subpackages = {
            "@//.opam.d/buildfiles/mirage-crypto-rng/lwt:BUILD.bazel":
            "lwt mirage-crypto-rng/lwt",

            "@//.opam.d/buildfiles/mirage-crypto-rng/unix:BUILD.bazel":
            "unix mirage-crypto-rng/unix",

        }
    )

    new_local_pkg_repository(
        name       = "ctypes",
        build_file = "@//.opam.d/buildfiles/ctypes:BUILD.bazel",
        path       = "ctypes",
        subpackages = {
            "@//.opam.d/buildfiles/ctypes/top:BUILD.bazel":
            "top ctypes",

            "@//.opam.d/buildfiles/ctypes/stubs:BUILD.bazel":
            "stubs ctypes",

            "@//.opam.d/buildfiles/ctypes/foreign:BUILD.bazel":
            "foreign ctypes",

        }
    )

    new_local_pkg_repository(
        name       = "ocb-stubblr",
        build_file = "@//.opam.d/buildfiles/ocb-stubblr:BUILD.bazel",
        path       = "ocb-stubblr",
        subpackages = {
            "@//.opam.d/buildfiles/ocb-stubblr/topkg:BUILD.bazel":
            "topkg ocb-stubblr",

        }
    )

    new_local_pkg_repository(
        name       = "cmdliner",
        build_file = "@//.opam.d/buildfiles/cmdliner:BUILD.bazel",
        path       = "cmdliner",
    )

    new_local_pkg_repository(
        name       = "eqaf",
        build_file = "@//.opam.d/buildfiles/eqaf:BUILD.bazel",
        path       = "eqaf",
        subpackages = {
            "@//.opam.d/buildfiles/eqaf/bigstring:BUILD.bazel":
            "bigstring eqaf/bigstring",

            "@//.opam.d/buildfiles/eqaf/cstruct:BUILD.bazel":
            "cstruct eqaf/cstruct",

        }
    )

    new_local_pkg_repository(
        name       = "ipaddr-sexp",
        build_file = "@//.opam.d/buildfiles/ipaddr-sexp:BUILD.bazel",
        path       = "ipaddr-sexp",
    )

    new_local_pkg_repository(
        name       = "afl-persistent",
        build_file = "@//.opam.d/buildfiles/afl-persistent:BUILD.bazel",
        path       = "afl-persistent",
    )

    new_local_pkg_repository(
        name       = "ppx_sexp_value",
        build_file = "@//.opam.d/buildfiles/ppx_sexp_value:BUILD.bazel",
        path       = "ppx_sexp_value",
    )

    new_local_pkg_repository(
        name       = "sexplib",
        build_file = "@//.opam.d/buildfiles/sexplib:BUILD.bazel",
        path       = "sexplib",
        subpackages = {
            "@//.opam.d/buildfiles/sexplib/num:BUILD.bazel":
            "num sexplib/num",

            "@//.opam.d/buildfiles/sexplib/unix:BUILD.bazel":
            "unix sexplib/unix",

        }
    )

    new_local_pkg_repository(
        name       = "topkg",
        build_file = "@//.opam.d/buildfiles/topkg:BUILD.bazel",
        path       = "topkg",
        subpackages = {
            "@//.opam.d/buildfiles/topkg/care:BUILD.bazel":
            "care topkg/../topkg-care",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_let",
        build_file = "@//.opam.d/buildfiles/ppx_let:BUILD.bazel",
        path       = "ppx_let",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_let/expander:BUILD.bazel":
            "expander ppx_let/expander",

        }
    )

    new_local_pkg_repository(
        name       = "ezjsonm",
        build_file = "@//.opam.d/buildfiles/ezjsonm:BUILD.bazel",
        path       = "ezjsonm",
    )

    new_local_pkg_repository(
        name       = "either",
        build_file = "@//.opam.d/buildfiles/either:BUILD.bazel",
        path       = "either",
    )

    new_local_pkg_repository(
        name       = "ppx_optcomp",
        build_file = "@//.opam.d/buildfiles/ppx_optcomp:BUILD.bazel",
        path       = "ppx_optcomp",
    )

    new_local_pkg_repository(
        name       = "csexp",
        build_file = "@//.opam.d/buildfiles/csexp:BUILD.bazel",
        path       = "csexp",
    )

    new_local_pkg_repository(
        name       = "digestif",
        build_file = "@//.opam.d/buildfiles/digestif:BUILD.bazel",
        path       = "digestif",
        subpackages = {
            "@//.opam.d/buildfiles/digestif/c:BUILD.bazel":
            "c digestif/c",

            "@//.opam.d/buildfiles/digestif/ocaml:BUILD.bazel":
            "ocaml digestif/ocaml",

            "@//.opam.d/buildfiles/digestif/rakia:BUILD.bazel":
            "rakia digestif/rakia",

        }
    )

    new_local_pkg_repository(
        name       = "result",
        build_file = "@//.opam.d/buildfiles/result:BUILD.bazel",
        path       = "result",
    )

    new_local_pkg_repository(
        name       = "bigstringaf",
        build_file = "@//.opam.d/buildfiles/bigstringaf:BUILD.bazel",
        path       = "bigstringaf",
    )

    new_local_pkg_repository(
        name       = "uuidm",
        build_file = "@//.opam.d/buildfiles/uuidm:BUILD.bazel",
        path       = "uuidm",
    )

    new_local_pkg_repository(
        name       = "cstruct",
        build_file = "@//.opam.d/buildfiles/cstruct:BUILD.bazel",
        path       = "cstruct",
    )

    new_local_pkg_repository(
        name       = "ppx_irmin",
        build_file = "@//.opam.d/buildfiles/ppx_irmin:BUILD.bazel",
        path       = "ppx_irmin",
    )

    new_local_pkg_repository(
        name       = "extlib",
        build_file = "@//.opam.d/buildfiles/extlib:BUILD.bazel",
        path       = "extlib",
    )

    new_local_pkg_repository(
        name       = "timezone",
        build_file = "@//.opam.d/buildfiles/timezone:BUILD.bazel",
        path       = "timezone",
    )

    new_local_pkg_repository(
        name       = "core",
        build_file = "@//.opam.d/buildfiles/core:BUILD.bazel",
        path       = "core",
        subpackages = {
            "@//.opam.d/buildfiles/core/bigbuffer_blocking:BUILD.bazel":
            "bigbuffer_blocking core/bigbuffer_blocking",

            "@//.opam.d/buildfiles/core/bigstring_unix:BUILD.bazel":
            "bigstring_unix core/bigstring_unix",

            "@//.opam.d/buildfiles/core/daemon:BUILD.bazel":
            "daemon core/daemon",

            "@//.opam.d/buildfiles/core/error_checking_mutex:BUILD.bazel":
            "error_checking_mutex core/error_checking_mutex",

            "@//.opam.d/buildfiles/core/iobuf_unix:BUILD.bazel":
            "iobuf_unix core/iobuf_unix",

            "@//.opam.d/buildfiles/core/linux_ext:BUILD.bazel":
            "linux_ext core/linux_ext",

            "@//.opam.d/buildfiles/core/lock_file_blocking:BUILD.bazel":
            "lock_file_blocking core/lock_file_blocking",

            "@//.opam.d/buildfiles/core/nano_mutex:BUILD.bazel":
            "nano_mutex core/nano_mutex",

            "@//.opam.d/buildfiles/core/process_env:BUILD.bazel":
            "process_env core/process_env",

            "@//.opam.d/buildfiles/core/squeue:BUILD.bazel":
            "squeue core/squeue",

            "@//.opam.d/buildfiles/core/syslog:BUILD.bazel":
            "syslog core/syslog",

            "@//.opam.d/buildfiles/core/time_stamp_counter:BUILD.bazel":
            "time_stamp_counter core/time_stamp_counter",

            "@//.opam.d/buildfiles/core/top:BUILD.bazel":
            "top core/top",

            "@//.opam.d/buildfiles/core/uuid:BUILD.bazel":
            "uuid core/uuid",


        }
    )

    new_local_pkg_repository(
        name       = "ptime",
        build_file = "@//.opam.d/buildfiles/ptime:BUILD.bazel",
        path       = "ptime",
        subpackages = {
            "@//.opam.d/buildfiles/ptime/top:BUILD.bazel":
            "top ptime",

            "@//.opam.d/buildfiles/ptime/clock:BUILD.bazel":
            "clock ptime",

            "@//.opam.d/buildfiles/ptime/clock/os:BUILD.bazel":
            "clock/os ptime/os",

            "@//.opam.d/buildfiles/ptime/clock/os/top:BUILD.bazel":
            "clock/os/top ptime/os",

            "@//.opam.d/buildfiles/ptime/clock/jsoo:BUILD.bazel":
            "clock/jsoo ptime/jsoo",

        }
    )

    new_local_pkg_repository(
        name       = "ounit2",
        build_file = "@//.opam.d/buildfiles/ounit2:BUILD.bazel",
        path       = "ounit2",
        subpackages = {
            "@//.opam.d/buildfiles/ounit2/advanced:BUILD.bazel":
            "advanced ounit2/advanced",

            "@//.opam.d/buildfiles/ounit2/threads:BUILD.bazel":
            "threads ounit2/threads",

        }
    )

    new_local_pkg_repository(
        name       = "hex",
        build_file = "@//.opam.d/buildfiles/hex:BUILD.bazel",
        path       = "hex",
    )

    new_local_pkg_repository(
        name       = "yojson",
        build_file = "@//.opam.d/buildfiles/yojson:BUILD.bazel",
        path       = "yojson",
        subpackages = {
            "@//.opam.d/buildfiles/yojson/biniou:BUILD.bazel":
            "biniou yojson",

        }
    )

    new_local_pkg_repository(
        name       = "conduit",
        build_file = "@//.opam.d/buildfiles/conduit:BUILD.bazel",
        path       = "conduit",
    )

    new_local_pkg_repository(
        name       = "progress",
        build_file = "@//.opam.d/buildfiles/progress:BUILD.bazel",
        path       = "progress",
        subpackages = {
            "@//.opam.d/buildfiles/progress/unix:BUILD.bazel":
            "unix progress/unix",

        }
    )

    new_local_pkg_repository(
        name       = "raw_spacetime",
        build_file = "@//.opam.d/buildfiles/raw_spacetime:BUILD.bazel",
        path       = "raw_spacetime",
    )

    new_local_pkg_repository(
        name       = "bytes",
        build_file = "@//.opam.d/buildfiles/bytes:BUILD.bazel",
        path       = "bytes",
    )

    new_local_pkg_repository(
        name       = "pyml",
        build_file = "@//.opam.d/buildfiles/pyml:BUILD.bazel",
        path       = "pyml",
    )

    new_local_pkg_repository(
        name       = "ppx_expect",
        build_file = "@//.opam.d/buildfiles/ppx_expect:BUILD.bazel",
        path       = "ppx_expect",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_expect/collector:BUILD.bazel":
            "collector ppx_expect/collector",

            "@//.opam.d/buildfiles/ppx_expect/common:BUILD.bazel":
            "common ppx_expect/common",

            "@//.opam.d/buildfiles/ppx_expect/config:BUILD.bazel":
            "config ppx_expect/config",

            "@//.opam.d/buildfiles/ppx_expect/config_types:BUILD.bazel":
            "config_types ppx_expect/config_types",

            "@//.opam.d/buildfiles/ppx_expect/evaluator:BUILD.bazel":
            "evaluator ppx_expect/evaluator",

            "@//.opam.d/buildfiles/ppx_expect/matcher:BUILD.bazel":
            "matcher ppx_expect/matcher",

            "@//.opam.d/buildfiles/ppx_expect/payload:BUILD.bazel":
            "payload ppx_expect/payload",

        }
    )

    new_local_pkg_repository(
        name       = "mmap",
        build_file = "@//.opam.d/buildfiles/mmap:BUILD.bazel",
        path       = "mmap",
    )

    new_local_pkg_repository(
        name       = "cohttp-lwt",
        build_file = "@//.opam.d/buildfiles/cohttp-lwt:BUILD.bazel",
        path       = "cohttp-lwt",
    )

    new_local_pkg_repository(
        name       = "js_of_ocaml",
        build_file = "@//.opam.d/buildfiles/js_of_ocaml:BUILD.bazel",
        path       = "js_of_ocaml",
        subpackages = {
            "@//.opam.d/buildfiles/js_of_ocaml/deriving:BUILD.bazel":
            "deriving js_of_ocaml/deriving",

        }
    )

    new_local_pkg_repository(
        name       = "dune",
        build_file = "@//.opam.d/buildfiles/dune:BUILD.bazel",
        path       = "dune",
        subpackages = {
            "@//.opam.d/buildfiles/dune/configurator:BUILD.bazel":
            "configurator dune/configurator",

        }
    )

    new_local_pkg_repository(
        name       = "json-data-encoding-bson",
        build_file = "@//.opam.d/buildfiles/json-data-encoding-bson:BUILD.bazel",
        path       = "json-data-encoding-bson",
    )

    new_local_pkg_repository(
        name       = "camlzip",
        build_file = "@//.opam.d/buildfiles/camlzip:BUILD.bazel",
        path       = "camlzip",
    )

    new_local_pkg_repository(
        name       = "qcheck-core",
        build_file = "@//.opam.d/buildfiles/qcheck-core:BUILD.bazel",
        path       = "qcheck-core",
        subpackages = {
            "@//.opam.d/buildfiles/qcheck-core/runner:BUILD.bazel":
            "runner qcheck-core/runner",

        }
    )

    new_local_pkg_repository(
        name       = "cohttp-lwt-unix",
        build_file = "@//.opam.d/buildfiles/cohttp-lwt-unix:BUILD.bazel",
        path       = "cohttp-lwt-unix",
    )

    new_local_pkg_repository(
        name       = "ppx_cold",
        build_file = "@//.opam.d/buildfiles/ppx_cold:BUILD.bazel",
        path       = "ppx_cold",
    )

    new_local_pkg_repository(
        name       = "ipaddr",
        build_file = "@//.opam.d/buildfiles/ipaddr:BUILD.bazel",
        path       = "ipaddr",
        subpackages = {
            "@//.opam.d/buildfiles/ipaddr/top:BUILD.bazel":
            "top ipaddr/top",

            "@//.opam.d/buildfiles/ipaddr/unix:BUILD.bazel":
            "unix ipaddr/unix",

        }
    )

    new_local_pkg_repository(
        name       = "fmt",
        build_file = "@//.opam.d/buildfiles/fmt:BUILD.bazel",
        path       = "fmt",
        subpackages = {
            "@//.opam.d/buildfiles/fmt/tty:BUILD.bazel":
            "tty fmt",

            "@//.opam.d/buildfiles/fmt/cli:BUILD.bazel":
            "cli fmt",

            "@//.opam.d/buildfiles/fmt/top:BUILD.bazel":
            "top fmt",

        }
    )

    new_local_pkg_repository(
        name       = "menhirLib",
        build_file = "@//.opam.d/buildfiles/menhirLib:BUILD.bazel",
        path       = "menhirLib",
    )

    new_local_pkg_repository(
        name       = "splittable_random",
        build_file = "@//.opam.d/buildfiles/splittable_random:BUILD.bazel",
        path       = "splittable_random",
    )

    new_local_pkg_repository(
        name       = "bigstring",
        build_file = "@//.opam.d/buildfiles/bigstring:BUILD.bazel",
        path       = "bigstring",
    )

    new_local_pkg_repository(
        name       = "ocplib-ocamlres",
        build_file = "@//.opam.d/buildfiles/ocplib-ocamlres:BUILD.bazel",
        path       = "ocplib-ocamlres",
        subpackages = {
            "@//.opam.d/buildfiles/ocplib-ocamlres/runtime:BUILD.bazel":
            "runtime ocplib-ocamlres",

        }
    )

    new_local_pkg_repository(
        name       = "uecc",
        build_file = "@//.opam.d/buildfiles/uecc:BUILD.bazel",
        path       = "uecc",
    )

    new_local_pkg_repository(
        name       = "base_bigstring",
        build_file = "@//.opam.d/buildfiles/base_bigstring:BUILD.bazel",
        path       = "base_bigstring",
    )

    new_local_pkg_repository(
        name       = "cudf",
        build_file = "@//.opam.d/buildfiles/cudf:BUILD.bazel",
        path       = "cudf",
    )

    new_local_pkg_repository(
        name       = "seq",
        build_file = "@//.opam.d/buildfiles/seq:BUILD.bazel",
        path       = "seq",
    )

    new_local_pkg_repository(
        name       = "ppx_base",
        build_file = "@//.opam.d/buildfiles/ppx_base:BUILD.bazel",
        path       = "ppx_base",
    )

    new_local_pkg_repository(
        name       = "resto-cohttp-server",
        build_file = "@//.opam.d/buildfiles/resto-cohttp-server:BUILD.bazel",
        path       = "resto-cohttp-server",
    )

    new_local_pkg_repository(
        name       = "integers",
        build_file = "@//.opam.d/buildfiles/integers:BUILD.bazel",
        path       = "integers",
        subpackages = {
            "@//.opam.d/buildfiles/integers/top:BUILD.bazel":
            "top integers/top",

        }
    )

    new_local_pkg_repository(
        name       = "menhirSdk",
        build_file = "@//.opam.d/buildfiles/menhirSdk:BUILD.bazel",
        path       = "menhirSdk",
    )

    new_local_pkg_repository(
        name       = "domain-name",
        build_file = "@//.opam.d/buildfiles/domain-name:BUILD.bazel",
        path       = "domain-name",
    )

    new_local_pkg_repository(
        name       = "ppx_deriving",
        build_file = "@//.opam.d/buildfiles/ppx_deriving:BUILD.bazel",
        path       = "ppx_deriving",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_deriving/api:BUILD.bazel":
            "api ppx_deriving/api",

            "@//.opam.d/buildfiles/ppx_deriving/create:BUILD.bazel":
            "create ppx_deriving/create",

            "@//.opam.d/buildfiles/ppx_deriving/enum:BUILD.bazel":
            "enum ppx_deriving/enum",

            "@//.opam.d/buildfiles/ppx_deriving/eq:BUILD.bazel":
            "eq ppx_deriving/eq",

            "@//.opam.d/buildfiles/ppx_deriving/fold:BUILD.bazel":
            "fold ppx_deriving/fold",

            "@//.opam.d/buildfiles/ppx_deriving/iter:BUILD.bazel":
            "iter ppx_deriving/iter",

            "@//.opam.d/buildfiles/ppx_deriving/make:BUILD.bazel":
            "make ppx_deriving/make",

            "@//.opam.d/buildfiles/ppx_deriving/map:BUILD.bazel":
            "map ppx_deriving/map",

            "@//.opam.d/buildfiles/ppx_deriving/ord:BUILD.bazel":
            "ord ppx_deriving/ord",

            "@//.opam.d/buildfiles/ppx_deriving/runtime:BUILD.bazel":
            "runtime ppx_deriving/runtime",

            "@//.opam.d/buildfiles/ppx_deriving/show:BUILD.bazel":
            "show ppx_deriving/show",

            "@//.opam.d/buildfiles/ppx_deriving/std:BUILD.bazel":
            "std ppx_deriving/std",

        }
    )

    new_local_pkg_repository(
        name       = "nonstd",
        build_file = "@//.opam.d/buildfiles/nonstd:BUILD.bazel",
        path       = "nonstd",
    )

    new_local_pkg_repository(
        name       = "cpuid",
        build_file = "@//.opam.d/buildfiles/cpuid:BUILD.bazel",
        path       = "cpuid",
    )

    new_local_pkg_repository(
        name       = "ppx_bin_prot",
        build_file = "@//.opam.d/buildfiles/ppx_bin_prot:BUILD.bazel",
        path       = "ppx_bin_prot",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_bin_prot/shape-expander:BUILD.bazel":
            "shape-expander ppx_bin_prot/shape-expander",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_repr",
        build_file = "@//.opam.d/buildfiles/ppx_repr:BUILD.bazel",
        path       = "ppx_repr",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_repr/lib:BUILD.bazel":
            "lib ppx_repr/lib",

        }
    )

    new_local_pkg_repository(
        name       = "alcotest-lwt",
        build_file = "@//.opam.d/buildfiles/alcotest-lwt:BUILD.bazel",
        path       = "alcotest-lwt",
    )

    new_local_pkg_repository(
        name       = "lwt-canceler",
        build_file = "@//.opam.d/buildfiles/lwt-canceler:BUILD.bazel",
        path       = "lwt-canceler",
    )

    new_local_pkg_repository(
        name       = "rresult",
        build_file = "@//.opam.d/buildfiles/rresult:BUILD.bazel",
        path       = "rresult",
        subpackages = {
            "@//.opam.d/buildfiles/rresult/top:BUILD.bazel":
            "top rresult",

        }
    )

    new_local_pkg_repository(
        name       = "base64",
        build_file = "@//.opam.d/buildfiles/base64:BUILD.bazel",
        path       = "base64",
        subpackages = {
            "@//.opam.d/buildfiles/base64/rfc2045:BUILD.bazel":
            "rfc2045 base64/rfc2045",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_optional",
        build_file = "@//.opam.d/buildfiles/ppx_optional:BUILD.bazel",
        path       = "ppx_optional",
    )

    new_local_pkg_repository(
        name       = "ocamlbuild",
        build_file = "@//.opam.d/buildfiles/ocamlbuild:BUILD.bazel",
        path       = "ocamlbuild",
    )

    new_local_pkg_repository(
        name       = "findlib",
        build_file = "@//.opam.d/buildfiles/findlib:BUILD.bazel",
        path       = "findlib",
        subpackages = {
            "@//.opam.d/buildfiles/findlib/internal:BUILD.bazel":
            "internal findlib",

            "@//.opam.d/buildfiles/findlib/dynload:BUILD.bazel":
            "dynload findlib",

            "@//.opam.d/buildfiles/findlib/top:BUILD.bazel":
            "top findlib",

        }
    )

    new_local_pkg_repository(
        name       = "resto-directory",
        build_file = "@//.opam.d/buildfiles/resto-directory:BUILD.bazel",
        path       = "resto-directory",
    )

    new_local_pkg_repository(
        name       = "biniou",
        build_file = "@//.opam.d/buildfiles/biniou:BUILD.bazel",
        path       = "biniou",
    )

    new_local_pkg_repository(
        name       = "decompress",
        build_file = "@//.opam.d/buildfiles/decompress:BUILD.bazel",
        path       = "decompress",
        subpackages = {
            "@//.opam.d/buildfiles/decompress/de:BUILD.bazel":
            "de decompress/de",

            "@//.opam.d/buildfiles/decompress/gz:BUILD.bazel":
            "gz decompress/gz",

            "@//.opam.d/buildfiles/decompress/lz:BUILD.bazel":
            "lz decompress/lz",

            "@//.opam.d/buildfiles/decompress/lzo:BUILD.bazel":
            "lzo decompress/lzo",

            "@//.opam.d/buildfiles/decompress/zl:BUILD.bazel":
            "zl decompress/zl",

        }
    )

    new_local_pkg_repository(
        name       = "terminal",
        build_file = "@//.opam.d/buildfiles/terminal:BUILD.bazel",
        path       = "terminal",
    )

    new_local_pkg_repository(
        name       = "num",
        build_file = "@//.opam.d/buildfiles/num:BUILD.bazel",
        path       = "num",
        subpackages = {
            "@//.opam.d/buildfiles/num/core:BUILD.bazel":
            "core num/^",

        }
    )

    new_local_pkg_repository(
        name       = "hacl",
        build_file = "@//.opam.d/buildfiles/hacl:BUILD.bazel",
        path       = "hacl",
    )

    new_local_pkg_repository(
        name       = "ppx_custom_printf",
        build_file = "@//.opam.d/buildfiles/ppx_custom_printf:BUILD.bazel",
        path       = "ppx_custom_printf",
    )

    new_local_pkg_repository(
        name       = "jane-street-headers",
        build_file = "@//.opam.d/buildfiles/jane-street-headers:BUILD.bazel",
        path       = "jane-street-headers",
    )

    new_local_pkg_repository(
        name       = "pbkdf",
        build_file = "@//.opam.d/buildfiles/pbkdf:BUILD.bazel",
        path       = "pbkdf",
    )

    new_local_pkg_repository(
        name       = "dum",
        build_file = "@//.opam.d/buildfiles/dum:BUILD.bazel",
        path       = "dum",
    )

    new_local_pkg_repository(
        name       = "ppxlib",
        build_file = "@//.opam.d/buildfiles/ppxlib:BUILD.bazel",
        path       = "ppxlib",
        subpackages = {
            "@//.opam.d/buildfiles/ppxlib/ast:BUILD.bazel":
            "ast ppxlib/ast",

            "@//.opam.d/buildfiles/ppxlib/metaquot:BUILD.bazel":
            "metaquot ppxlib/metaquot",

            "@//.opam.d/buildfiles/ppxlib/metaquot_lifters:BUILD.bazel":
            "metaquot_lifters ppxlib/metaquot_lifters",

            "@//.opam.d/buildfiles/ppxlib/print_diff:BUILD.bazel":
            "print_diff ppxlib/print_diff",

            "@//.opam.d/buildfiles/ppxlib/runner:BUILD.bazel":
            "runner ppxlib/runner",

            "@//.opam.d/buildfiles/ppxlib/runner_as_ppx:BUILD.bazel":
            "runner_as_ppx ppxlib/runner_as_ppx",

            "@//.opam.d/buildfiles/ppxlib/stdppx:BUILD.bazel":
            "stdppx ppxlib/stdppx",

            "@//.opam.d/buildfiles/ppxlib/traverse:BUILD.bazel":
            "traverse ppxlib/traverse",

            "@//.opam.d/buildfiles/ppxlib/traverse_builtins:BUILD.bazel":
            "traverse_builtins ppxlib/traverse_builtins",

        }
    )

    new_local_pkg_repository(
        name       = "base_quickcheck",
        build_file = "@//.opam.d/buildfiles/base_quickcheck:BUILD.bazel",
        path       = "base_quickcheck",
        subpackages = {
            "@//.opam.d/buildfiles/base_quickcheck/ppx_quickcheck:BUILD.bazel":
            "ppx_quickcheck base_quickcheck/ppx_quickcheck",

            "@//.opam.d/buildfiles/base_quickcheck/ppx_quickcheck/expander:BUILD.bazel":
            "ppx_quickcheck/expander base_quickcheck/ppx_quickcheck/expander",

        }
    )

    new_local_pkg_repository(
        name       = "oUnit",
        build_file = "@//.opam.d/buildfiles/oUnit:BUILD.bazel",
        path       = "oUnit",
        subpackages = {
            "@//.opam.d/buildfiles/oUnit/threads:BUILD.bazel":
            "threads oUnit",

            "@//.opam.d/buildfiles/oUnit/advanced:BUILD.bazel":
            "advanced oUnit",

        }
    )

    new_local_pkg_repository(
        name       = "secp256k1-internal",
        build_file = "@//.opam.d/buildfiles/secp256k1-internal:BUILD.bazel",
        path       = "secp256k1-internal",
    )

    new_local_pkg_repository(
        name       = "gmap",
        build_file = "@//.opam.d/buildfiles/gmap:BUILD.bazel",
        path       = "gmap",
    )

    new_local_pkg_repository(
        name       = "resto",
        build_file = "@//.opam.d/buildfiles/resto:BUILD.bazel",
        path       = "resto",
    )

    new_local_pkg_repository(
        name       = "ppx_tools_versioned",
        build_file = "@//.opam.d/buildfiles/ppx_tools_versioned:BUILD.bazel",
        path       = "ppx_tools_versioned",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_402:BUILD.bazel":
            "metaquot_402 ppx_tools_versioned/metaquot_402",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_403:BUILD.bazel":
            "metaquot_403 ppx_tools_versioned/metaquot_403",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_404:BUILD.bazel":
            "metaquot_404 ppx_tools_versioned/metaquot_404",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_405:BUILD.bazel":
            "metaquot_405 ppx_tools_versioned/metaquot_405",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_406:BUILD.bazel":
            "metaquot_406 ppx_tools_versioned/metaquot_406",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_407:BUILD.bazel":
            "metaquot_407 ppx_tools_versioned/metaquot_407",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_408:BUILD.bazel":
            "metaquot_408 ppx_tools_versioned/metaquot_408",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_409:BUILD.bazel":
            "metaquot_409 ppx_tools_versioned/metaquot_409",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_410:BUILD.bazel":
            "metaquot_410 ppx_tools_versioned/metaquot_410",

            "@//.opam.d/buildfiles/ppx_tools_versioned/metaquot_411:BUILD.bazel":
            "metaquot_411 ppx_tools_versioned/metaquot_411",

        }
    )

    new_local_pkg_repository(
        name       = "spdx_licenses",
        build_file = "@//.opam.d/buildfiles/spdx_licenses:BUILD.bazel",
        path       = "spdx_licenses",
    )

    new_local_pkg_repository(
        name       = "ppx_jane",
        build_file = "@//.opam.d/buildfiles/ppx_jane:BUILD.bazel",
        path       = "ppx_jane",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_jane/kernel:BUILD.bazel":
            "kernel ppx_jane/kernel",

        }
    )

    new_local_pkg_repository(
        name       = "astring",
        build_file = "@//.opam.d/buildfiles/astring:BUILD.bazel",
        path       = "astring",
        subpackages = {
            "@//.opam.d/buildfiles/astring/top:BUILD.bazel":
            "top astring",

        }
    )

    new_local_pkg_repository(
        name       = "lwt-exit",
        build_file = "@//.opam.d/buildfiles/lwt-exit:BUILD.bazel",
        path       = "lwt-exit",
    )

    new_local_pkg_repository(
        name       = "metrics-influx",
        build_file = "@//.opam.d/buildfiles/metrics-influx:BUILD.bazel",
        path       = "metrics-influx",
    )

    new_local_pkg_repository(
        name       = "num-top",
        build_file = "@//.opam.d/buildfiles/num-top:BUILD.bazel",
        path       = "num-top",
    )

    new_local_pkg_repository(
        name       = "resto-cohttp",
        build_file = "@//.opam.d/buildfiles/resto-cohttp:BUILD.bazel",
        path       = "resto-cohttp",
    )

    new_local_pkg_repository(
        name       = "ringo-lwt",
        build_file = "@//.opam.d/buildfiles/ringo-lwt:BUILD.bazel",
        path       = "ringo-lwt",
    )

    new_local_pkg_repository(
        name       = "resto-acl",
        build_file = "@//.opam.d/buildfiles/resto-acl:BUILD.bazel",
        path       = "resto-acl",
    )

    new_local_pkg_repository(
        name       = "ppx_compare",
        build_file = "@//.opam.d/buildfiles/ppx_compare:BUILD.bazel",
        path       = "ppx_compare",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_compare/expander:BUILD.bazel":
            "expander ppx_compare/expander",

            "@//.opam.d/buildfiles/ppx_compare/runtime-lib:BUILD.bazel":
            "runtime-lib ppx_compare/runtime-lib",

        }
    )

    new_local_pkg_repository(
        name       = "bin_prot",
        build_file = "@//.opam.d/buildfiles/bin_prot:BUILD.bazel",
        path       = "bin_prot",
        subpackages = {
            "@//.opam.d/buildfiles/bin_prot/shape:BUILD.bazel":
            "shape bin_prot/shape",

            "@//.opam.d/buildfiles/bin_prot/xen:BUILD.bazel":
            "xen bin_prot/xen",

        }
    )

    new_local_pkg_repository(
        name       = "typerep",
        build_file = "@//.opam.d/buildfiles/typerep:BUILD.bazel",
        path       = "typerep",
    )

    new_local_pkg_repository(
        name       = "dose3",
        build_file = "@//.opam.d/buildfiles/dose3:BUILD.bazel",
        path       = "dose3",
        subpackages = {
            "@//.opam.d/buildfiles/dose3/common:BUILD.bazel":
            "common dose3",

            "@//.opam.d/buildfiles/dose3/algo:BUILD.bazel":
            "algo dose3",

            "@//.opam.d/buildfiles/dose3/versioning:BUILD.bazel":
            "versioning dose3",

            "@//.opam.d/buildfiles/dose3/debian:BUILD.bazel":
            "debian dose3",

            "@//.opam.d/buildfiles/dose3/opam:BUILD.bazel":
            "opam dose3",

            "@//.opam.d/buildfiles/dose3/pef:BUILD.bazel":
            "pef dose3",

            "@//.opam.d/buildfiles/dose3/csw:BUILD.bazel":
            "csw dose3",

            "@//.opam.d/buildfiles/dose3/rpm:BUILD.bazel":
            "rpm dose3",

            "@//.opam.d/buildfiles/dose3/doseparse:BUILD.bazel":
            "doseparse dose3",

            "@//.opam.d/buildfiles/dose3/doseparseNoRpm:BUILD.bazel":
            "doseparseNoRpm dose3",

            "@//.opam.d/buildfiles/dose3/npm:BUILD.bazel":
            "npm dose3",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_inline_test",
        build_file = "@//.opam.d/buildfiles/ppx_inline_test:BUILD.bazel",
        path       = "ppx_inline_test",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_inline_test/config:BUILD.bazel":
            "config ppx_inline_test/config",

            "@//.opam.d/buildfiles/ppx_inline_test/drop:BUILD.bazel":
            "drop ppx_inline_test/drop",

            "@//.opam.d/buildfiles/ppx_inline_test/libname:BUILD.bazel":
            "libname ppx_inline_test/libname",

            "@//.opam.d/buildfiles/ppx_inline_test/runner:BUILD.bazel":
            "runner ppx_inline_test/runner",

            "@//.opam.d/buildfiles/ppx_inline_test/runner/lib:BUILD.bazel":
            "runner/lib ppx_inline_test/runner/lib",

            "@//.opam.d/buildfiles/ppx_inline_test/runtime-lib:BUILD.bazel":
            "runtime-lib ppx_inline_test/runtime-lib",

        }
    )

    new_local_pkg_repository(
        name       = "hkdf",
        build_file = "@//.opam.d/buildfiles/hkdf:BUILD.bazel",
        path       = "hkdf",
    )

    new_local_pkg_repository(
        name       = "qcheck-alcotest",
        build_file = "@//.opam.d/buildfiles/qcheck-alcotest:BUILD.bazel",
        path       = "qcheck-alcotest",
    )

    new_local_pkg_repository(
        name       = "ppx_variants_conv",
        build_file = "@//.opam.d/buildfiles/ppx_variants_conv:BUILD.bazel",
        path       = "ppx_variants_conv",
    )

    new_local_pkg_repository(
        name       = "ppx_module_timer",
        build_file = "@//.opam.d/buildfiles/ppx_module_timer:BUILD.bazel",
        path       = "ppx_module_timer",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_module_timer/runtime:BUILD.bazel":
            "runtime ppx_module_timer/runtime",

        }
    )

    new_local_pkg_repository(
        name       = "x509",
        build_file = "@//.opam.d/buildfiles/x509:BUILD.bazel",
        path       = "x509",
    )

    new_local_pkg_repository(
        name       = "bigarray",
        build_file = "@//.opam.d/buildfiles/bigarray:BUILD.bazel",
        path       = "bigarray",
    )

    new_local_pkg_repository(
        name       = "zip",
        build_file = "@//.opam.d/buildfiles/zip:BUILD.bazel",
        path       = "zip",
    )

    new_local_pkg_repository(
        name       = "semaphore-compat",
        build_file = "@//.opam.d/buildfiles/semaphore-compat:BUILD.bazel",
        path       = "semaphore-compat",
    )

    new_local_pkg_repository(
        name       = "bls12-381-gen",
        build_file = "@//.opam.d/buildfiles/bls12-381-gen:BUILD.bazel",
        path       = "bls12-381-gen",
    )

    new_local_pkg_repository(
        name       = "stdlib-shims",
        build_file = "@//.opam.d/buildfiles/stdlib-shims:BUILD.bazel",
        path       = "stdlib-shims",
    )

    new_local_pkg_repository(
        name       = "unix",
        build_file = "@//.opam.d/buildfiles/unix:BUILD.bazel",
        path       = "unix",
    )

    new_local_pkg_repository(
        name       = "ppx_typerep_conv",
        build_file = "@//.opam.d/buildfiles/ppx_typerep_conv:BUILD.bazel",
        path       = "ppx_typerep_conv",
    )

    new_local_pkg_repository(
        name       = "lwt",
        build_file = "@//.opam.d/buildfiles/lwt:BUILD.bazel",
        path       = "lwt",
        subpackages = {
            "@//.opam.d/buildfiles/lwt/unix:BUILD.bazel":
            "unix lwt/unix",

        }
    )

    new_local_pkg_repository(
        name       = "json-data-encoding",
        build_file = "@//.opam.d/buildfiles/json-data-encoding:BUILD.bazel",
        path       = "json-data-encoding",
    )

    new_local_pkg_repository(
        name       = "stdio",
        build_file = "@//.opam.d/buildfiles/stdio:BUILD.bazel",
        path       = "stdio",
    )

    new_local_pkg_repository(
        name       = "checkseum",
        build_file = "@//.opam.d/buildfiles/checkseum:BUILD.bazel",
        path       = "checkseum",
        subpackages = {
            "@//.opam.d/buildfiles/checkseum/c:BUILD.bazel":
            "c checkseum/c",

            "@//.opam.d/buildfiles/checkseum/ocaml:BUILD.bazel":
            "ocaml checkseum/ocaml",

        }
    )

    new_local_pkg_repository(
        name       = "opam-file-format",
        build_file = "@//.opam.d/buildfiles/opam-file-format:BUILD.bazel",
        path       = "opam-file-format",
    )

    new_local_pkg_repository(
        name       = "logs",
        build_file = "@//.opam.d/buildfiles/logs:BUILD.bazel",
        path       = "logs",
        subpackages = {
            "@//.opam.d/buildfiles/logs/fmt:BUILD.bazel":
            "fmt logs",

            "@//.opam.d/buildfiles/logs/browser:BUILD.bazel":
            "browser logs",

            "@//.opam.d/buildfiles/logs/cli:BUILD.bazel":
            "cli logs",

            "@//.opam.d/buildfiles/logs/lwt:BUILD.bazel":
            "lwt logs",

            "@//.opam.d/buildfiles/logs/threaded:BUILD.bazel":
            "threaded logs",

            "@//.opam.d/buildfiles/logs/top:BUILD.bazel":
            "top logs",

        }
    )

    new_local_pkg_repository(
        name       = "tls",
        build_file = "@//.opam.d/buildfiles/tls:BUILD.bazel",
        path       = "tls",
        subpackages = {
            "@//.opam.d/buildfiles/tls/lwt:BUILD.bazel":
            "lwt tls/lwt",

        }
    )

    new_local_pkg_repository(
        name       = "parsexp",
        build_file = "@//.opam.d/buildfiles/parsexp:BUILD.bazel",
        path       = "parsexp",
    )

    new_local_pkg_repository(
        name       = "ppx_pipebang",
        build_file = "@//.opam.d/buildfiles/ppx_pipebang:BUILD.bazel",
        path       = "ppx_pipebang",
    )

    new_local_pkg_repository(
        name       = "ppx_hash",
        build_file = "@//.opam.d/buildfiles/ppx_hash:BUILD.bazel",
        path       = "ppx_hash",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_hash/expander:BUILD.bazel":
            "expander ppx_hash/expander",

            "@//.opam.d/buildfiles/ppx_hash/runtime-lib:BUILD.bazel":
            "runtime-lib ppx_hash/runtime-lib",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_derivers",
        build_file = "@//.opam.d/buildfiles/ppx_derivers:BUILD.bazel",
        path       = "ppx_derivers",
    )

    new_local_pkg_repository(
        name       = "threads",
        build_file = "@//.opam.d/buildfiles/threads:BUILD.bazel",
        path       = "threads",
    )

    new_local_pkg_repository(
        name       = "optint",
        build_file = "@//.opam.d/buildfiles/optint:BUILD.bazel",
        path       = "optint",
    )

    new_local_pkg_repository(
        name       = "irmin-layers",
        build_file = "@//.opam.d/buildfiles/irmin-layers:BUILD.bazel",
        path       = "irmin-layers",
    )

    new_local_pkg_repository(
        name       = "ff-sig",
        build_file = "@//.opam.d/buildfiles/ff-sig:BUILD.bazel",
        path       = "ff-sig",
    )

    new_local_pkg_repository(
        name       = "mirage-crypto-ec",
        build_file = "@//.opam.d/buildfiles/mirage-crypto-ec:BUILD.bazel",
        path       = "mirage-crypto-ec",
    )

    new_local_pkg_repository(
        name       = "ocaml-migrate-parsetree",
        build_file = "@//.opam.d/buildfiles/ocaml-migrate-parsetree:BUILD.bazel",
        path       = "ocaml-migrate-parsetree",
        subpackages = {
            "@//.opam.d/buildfiles/ocaml-migrate-parsetree/driver-main:BUILD.bazel":
            "driver-main ocaml-migrate-parsetree/driver-main",

        }
    )

    new_local_pkg_repository(
        name       = "easy-format",
        build_file = "@//.opam.d/buildfiles/easy-format:BUILD.bazel",
        path       = "easy-format",
    )

    new_local_pkg_repository(
        name       = "cstruct-lwt",
        build_file = "@//.opam.d/buildfiles/cstruct-lwt:BUILD.bazel",
        path       = "cstruct-lwt",
    )

    new_local_pkg_repository(
        name       = "zarith",
        build_file = "@//.opam.d/buildfiles/zarith:BUILD.bazel",
        path       = "zarith",
        subpackages = {
            "@//.opam.d/buildfiles/zarith/top:BUILD.bazel":
            "top zarith",

        }
    )

    new_local_pkg_repository(
        name       = "lwt-watcher",
        build_file = "@//.opam.d/buildfiles/lwt-watcher:BUILD.bazel",
        path       = "lwt-watcher",
    )

    new_local_pkg_repository(
        name       = "bls12-381-unix",
        build_file = "@//.opam.d/buildfiles/bls12-381-unix:BUILD.bazel",
        path       = "bls12-381-unix",
    )

    new_local_pkg_repository(
        name       = "jsonm",
        build_file = "@//.opam.d/buildfiles/jsonm:BUILD.bazel",
        path       = "jsonm",
    )

    new_local_pkg_repository(
        name       = "hacl-star",
        build_file = "@//.opam.d/buildfiles/hacl-star:BUILD.bazel",
        path       = "hacl-star",
    )

    new_local_pkg_repository(
        name       = "ocaml-compiler-libs",
        build_file = "@//.opam.d/buildfiles/ocaml-compiler-libs:BUILD.bazel",
        path       = "ocaml-compiler-libs",
        subpackages = {
            "@//.opam.d/buildfiles/ocaml-compiler-libs/bytecomp:BUILD.bazel":
            "bytecomp ocaml-compiler-libs/bytecomp",

            "@//.opam.d/buildfiles/ocaml-compiler-libs/common:BUILD.bazel":
            "common ocaml-compiler-libs/common",

            "@//.opam.d/buildfiles/ocaml-compiler-libs/optcomp:BUILD.bazel":
            "optcomp ocaml-compiler-libs/optcomp",

            "@//.opam.d/buildfiles/ocaml-compiler-libs/shadow:BUILD.bazel":
            "shadow ocaml-compiler-libs/shadow",

            "@//.opam.d/buildfiles/ocaml-compiler-libs/toplevel:BUILD.bazel":
            "toplevel ocaml-compiler-libs/toplevel",

        }
    )

    new_local_pkg_repository(
        name       = "hashcons",
        build_file = "@//.opam.d/buildfiles/hashcons:BUILD.bazel",
        path       = "hashcons",
    )

    new_local_pkg_repository(
        name       = "b0",
        build_file = "@//.opam.d/buildfiles/b0:BUILD.bazel",
        path       = "b0",
        subpackages = {
            "@//.opam.d/buildfiles/b0/b00:BUILD.bazel":
            "b00 b0/b00",

            "@//.opam.d/buildfiles/b0/b00/std:BUILD.bazel":
            "b00/std b0/b00/std",

            "@//.opam.d/buildfiles/b0/b00/kit:BUILD.bazel":
            "b00/kit b0/b00/kit",

            "@//.opam.d/buildfiles/b0/kit:BUILD.bazel":
            "kit b0/kit",

            "@//.opam.d/buildfiles/b0/b0:BUILD.bazel":
            "b0 b0/b0",

        }
    )

    new_local_pkg_repository(
        name       = "tar-unix",
        build_file = "@//.opam.d/buildfiles/tar-unix:BUILD.bazel",
        path       = "tar-unix",
    )

    new_local_pkg_repository(
        name       = "index",
        build_file = "@//.opam.d/buildfiles/index:BUILD.bazel",
        path       = "index",
        subpackages = {
            "@//.opam.d/buildfiles/index/unix:BUILD.bazel":
            "unix index/unix",

        }
    )

    new_local_pkg_repository(
        name       = "stdlib",
        build_file = "@//.opam.d/buildfiles/stdlib:BUILD.bazel",
        path       = "stdlib",
    )

    new_local_pkg_repository(
        name       = "ppx_assert",
        build_file = "@//.opam.d/buildfiles/ppx_assert:BUILD.bazel",
        path       = "ppx_assert",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_assert/runtime-lib:BUILD.bazel":
            "runtime-lib ppx_assert/runtime-lib",

        }
    )

    new_local_pkg_repository(
        name       = "alcotest",
        build_file = "@//.opam.d/buildfiles/alcotest:BUILD.bazel",
        path       = "alcotest",
        subpackages = {
            "@//.opam.d/buildfiles/alcotest/engine:BUILD.bazel":
            "engine alcotest/engine",

            "@//.opam.d/buildfiles/alcotest/stdlib_ext:BUILD.bazel":
            "stdlib_ext alcotest/stdlib_ext",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_sexp_conv",
        build_file = "@//.opam.d/buildfiles/ppx_sexp_conv:BUILD.bazel",
        path       = "ppx_sexp_conv",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_sexp_conv/expander:BUILD.bazel":
            "expander ppx_sexp_conv/expander",

            "@//.opam.d/buildfiles/ppx_sexp_conv/runtime-lib:BUILD.bazel":
            "runtime-lib ppx_sexp_conv/runtime-lib",

        }
    )

    new_local_pkg_repository(
        name       = "uchar",
        build_file = "@//.opam.d/buildfiles/uchar:BUILD.bazel",
        path       = "uchar",
    )

    new_local_pkg_repository(
        name       = "bos",
        build_file = "@//.opam.d/buildfiles/bos:BUILD.bazel",
        path       = "bos",
        subpackages = {
            "@//.opam.d/buildfiles/bos/top:BUILD.bazel":
            "top bos",

            "@//.opam.d/buildfiles/bos/setup:BUILD.bazel":
            "setup bos",

        }
    )

    new_local_pkg_repository(
        name       = "tezos-lwt-result-stdlib",
        build_file = "@//.opam.d/buildfiles/tezos-lwt-result-stdlib:BUILD.bazel",
        path       = "tezos-lwt-result-stdlib",
        subpackages = {
            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/bare:BUILD.bazel":
            "bare tezos-lwt-result-stdlib/bare",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/bare/functor-outputs:BUILD.bazel":
            "bare/functor-outputs tezos-lwt-result-stdlib/bare/functor-outputs",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/bare/sigs:BUILD.bazel":
            "bare/sigs tezos-lwt-result-stdlib/bare/sigs",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/bare/structs:BUILD.bazel":
            "bare/structs tezos-lwt-result-stdlib/bare/structs",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/examples:BUILD.bazel":
            "examples tezos-lwt-result-stdlib/examples",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/examples/traces:BUILD.bazel":
            "examples/traces tezos-lwt-result-stdlib/examples/traces",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/traced:BUILD.bazel":
            "traced tezos-lwt-result-stdlib/traced",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/traced/functor-outputs:BUILD.bazel":
            "traced/functor-outputs tezos-lwt-result-stdlib/traced/functor-outputs",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/traced/sigs:BUILD.bazel":
            "traced/sigs tezos-lwt-result-stdlib/traced/sigs",

            "@//.opam.d/buildfiles/tezos-lwt-result-stdlib/traced/structs:BUILD.bazel":
            "traced/structs tezos-lwt-result-stdlib/traced/structs",

        }
    )

    new_local_pkg_repository(
        name       = "sexplib0",
        build_file = "@//.opam.d/buildfiles/sexplib0:BUILD.bazel",
        path       = "sexplib0",
    )

    new_local_pkg_repository(
        name       = "ppx_tools",
        build_file = "@//.opam.d/buildfiles/ppx_tools:BUILD.bazel",
        path       = "ppx_tools",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_tools/ast_lifter:BUILD.bazel":
            "ast_lifter ppx_tools/ast_lifter",

            "@//.opam.d/buildfiles/ppx_tools/metaquot:BUILD.bazel":
            "metaquot ppx_tools/metaquot",

        }
    )

    new_local_pkg_repository(
        name       = "octavius",
        build_file = "@//.opam.d/buildfiles/octavius:BUILD.bazel",
        path       = "octavius",
    )

    new_local_pkg_repository(
        name       = "tyxml",
        build_file = "@//.opam.d/buildfiles/tyxml:BUILD.bazel",
        path       = "tyxml",
        subpackages = {
            "@//.opam.d/buildfiles/tyxml/functor:BUILD.bazel":
            "functor tyxml/functor",

        }
    )

    new_local_pkg_repository(
        name       = "angstrom",
        build_file = "@//.opam.d/buildfiles/angstrom:BUILD.bazel",
        path       = "angstrom",
        subpackages = {
            "@//.opam.d/buildfiles/angstrom/unix:BUILD.bazel":
            "unix angstrom",

            "@//.opam.d/buildfiles/angstrom/lwt-unix:BUILD.bazel":
            "lwt-unix angstrom",

            "@//.opam.d/buildfiles/angstrom/async:BUILD.bazel":
            "async angstrom",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_stable",
        build_file = "@//.opam.d/buildfiles/ppx_stable:BUILD.bazel",
        path       = "ppx_stable",
    )

    new_local_pkg_repository(
        name       = "sosa",
        build_file = "@//.opam.d/buildfiles/sosa:BUILD.bazel",
        path       = "sosa",
    )

    new_local_pkg_repository(
        name       = "odoc",
        build_file = "@//.opam.d/buildfiles/odoc:BUILD.bazel",
        path       = "odoc",
        subpackages = {
            "@//.opam.d/buildfiles/odoc/compat:BUILD.bazel":
            "compat odoc/compat",

            "@//.opam.d/buildfiles/odoc/html:BUILD.bazel":
            "html odoc/html",

            "@//.opam.d/buildfiles/odoc/loader:BUILD.bazel":
            "loader odoc/loader",

            "@//.opam.d/buildfiles/odoc/model:BUILD.bazel":
            "model odoc/model",

            "@//.opam.d/buildfiles/odoc/odoc:BUILD.bazel":
            "odoc odoc/odoc",

            "@//.opam.d/buildfiles/odoc/parser:BUILD.bazel":
            "parser odoc/parser",

            "@//.opam.d/buildfiles/odoc/xref:BUILD.bazel":
            "xref odoc/xref",

        }
    )

    new_local_pkg_repository(
        name       = "bls12-381",
        build_file = "@//.opam.d/buildfiles/bls12-381:BUILD.bazel",
        path       = "bls12-381",
    )

    new_local_pkg_repository(
        name       = "macaddr",
        build_file = "@//.opam.d/buildfiles/macaddr:BUILD.bazel",
        path       = "macaddr",
        subpackages = {
            "@//.opam.d/buildfiles/macaddr/top:BUILD.bazel":
            "top macaddr/top",

        }
    )

    new_local_pkg_repository(
        name       = "ringo",
        build_file = "@//.opam.d/buildfiles/ringo:BUILD.bazel",
        path       = "ringo",
    )

    new_local_pkg_repository(
        name       = "crowbar",
        build_file = "@//.opam.d/buildfiles/crowbar:BUILD.bazel",
        path       = "crowbar",
    )

    new_local_pkg_repository(
        name       = "resto-cohttp-self-serving-client",
        build_file = "@//.opam.d/buildfiles/resto-cohttp-self-serving-client:BUILD.bazel",
        path       = "resto-cohttp-self-serving-client",
    )

    new_local_pkg_repository(
        name       = "ocamlgraph",
        build_file = "@//.opam.d/buildfiles/ocamlgraph:BUILD.bazel",
        path       = "ocamlgraph",
    )

    new_local_pkg_repository(
        name       = "ppx_bench",
        build_file = "@//.opam.d/buildfiles/ppx_bench:BUILD.bazel",
        path       = "ppx_bench",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_bench/runtime-lib:BUILD.bazel":
            "runtime-lib ppx_bench/runtime-lib",

        }
    )

    new_local_pkg_repository(
        name       = "uutf",
        build_file = "@//.opam.d/buildfiles/uutf:BUILD.bazel",
        path       = "uutf",
    )

    new_local_pkg_repository(
        name       = "js_of_ocaml-compiler",
        build_file = "@//.opam.d/buildfiles/js_of_ocaml-compiler:BUILD.bazel",
        path       = "js_of_ocaml-compiler",
        subpackages = {
            "@//.opam.d/buildfiles/js_of_ocaml-compiler/findlib-support:BUILD.bazel":
            "findlib-support js_of_ocaml-compiler/findlib-support",

            "@//.opam.d/buildfiles/js_of_ocaml-compiler/runtime:BUILD.bazel":
            "runtime js_of_ocaml-compiler/runtime",

        }
    )

    new_local_pkg_repository(
        name       = "ff",
        build_file = "@//.opam.d/buildfiles/ff:BUILD.bazel",
        path       = "ff",
    )

    new_local_pkg_repository(
        name       = "resto-cohttp-client",
        build_file = "@//.opam.d/buildfiles/resto-cohttp-client:BUILD.bazel",
        path       = "resto-cohttp-client",
    )

    new_local_pkg_repository(
        name       = "odig",
        build_file = "@//.opam.d/buildfiles/odig:BUILD.bazel",
        path       = "odig",
        subpackages = {
            "@//.opam.d/buildfiles/odig/support:BUILD.bazel":
            "support odig",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_enumerate",
        build_file = "@//.opam.d/buildfiles/ppx_enumerate:BUILD.bazel",
        path       = "ppx_enumerate",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_enumerate/runtime-lib:BUILD.bazel":
            "runtime-lib ppx_enumerate/runtime-lib",

        }
    )

    new_local_pkg_repository(
        name       = "irmin-pack",
        build_file = "@//.opam.d/buildfiles/irmin-pack:BUILD.bazel",
        path       = "irmin-pack",
        subpackages = {
            "@//.opam.d/buildfiles/irmin-pack/layered:BUILD.bazel":
            "layered irmin-pack/layered",

        }
    )

    new_local_pkg_repository(
        name       = "uri",
        build_file = "@//.opam.d/buildfiles/uri:BUILD.bazel",
        path       = "uri",
        subpackages = {
            "@//.opam.d/buildfiles/uri/services:BUILD.bazel":
            "services uri/services",

            "@//.opam.d/buildfiles/uri/services_full:BUILD.bazel":
            "services_full uri/services_full",

        }
    )

    new_local_pkg_repository(
        name       = "conduit-lwt",
        build_file = "@//.opam.d/buildfiles/conduit-lwt:BUILD.bazel",
        path       = "conduit-lwt",
    )

    new_local_pkg_repository(
        name       = "lwt_log",
        build_file = "@//.opam.d/buildfiles/lwt_log:BUILD.bazel",
        path       = "lwt_log",
        subpackages = {
            "@//.opam.d/buildfiles/lwt_log/core:BUILD.bazel":
            "core lwt_log/core",

        }
    )

    new_local_pkg_repository(
        name       = "duration",
        build_file = "@//.opam.d/buildfiles/duration:BUILD.bazel",
        path       = "duration",
    )

    new_local_pkg_repository(
        name       = "ca-certs",
        build_file = "@//.opam.d/buildfiles/ca-certs:BUILD.bazel",
        path       = "ca-certs",
    )

    new_local_pkg_repository(
        name       = "tar",
        build_file = "@//.opam.d/buildfiles/tar:BUILD.bazel",
        path       = "tar",
    )

    new_local_pkg_repository(
        name       = "vector",
        build_file = "@//.opam.d/buildfiles/vector:BUILD.bazel",
        path       = "vector",
    )

    new_local_pkg_repository(
        name       = "ocplib-endian",
        build_file = "@//.opam.d/buildfiles/ocplib-endian:BUILD.bazel",
        path       = "ocplib-endian",
        subpackages = {
            "@//.opam.d/buildfiles/ocplib-endian/bigstring:BUILD.bazel":
            "bigstring ocplib-endian/bigstring",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_sexp_message",
        build_file = "@//.opam.d/buildfiles/ppx_sexp_message:BUILD.bazel",
        path       = "ppx_sexp_message",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_sexp_message/expander:BUILD.bazel":
            "expander ppx_sexp_message/expander",

        }
    )

    new_local_pkg_repository(
        name       = "lwt-dllist",
        build_file = "@//.opam.d/buildfiles/lwt-dllist:BUILD.bazel",
        path       = "lwt-dllist",
    )

    new_local_pkg_repository(
        name       = "ppx_cstruct",
        build_file = "@//.opam.d/buildfiles/ppx_cstruct:BUILD.bazel",
        path       = "ppx_cstruct",
    )

    new_local_pkg_repository(
        name       = "core_kernel",
        build_file = "@//.opam.d/buildfiles/core_kernel:BUILD.bazel",
        path       = "core_kernel",
        subpackages = {
            "@//.opam.d/buildfiles/core_kernel/ansi_kernel:BUILD.bazel":
            "ansi_kernel core_kernel/ansi_kernel",

            "@//.opam.d/buildfiles/core_kernel/balanced_reducer:BUILD.bazel":
            "balanced_reducer core_kernel/balanced_reducer",

            "@//.opam.d/buildfiles/core_kernel/base_for_tests:BUILD.bazel":
            "base_for_tests core_kernel/base_for_tests",

            "@//.opam.d/buildfiles/core_kernel/binary_packing:BUILD.bazel":
            "binary_packing core_kernel/binary_packing",

            "@//.opam.d/buildfiles/core_kernel/bounded_int_table:BUILD.bazel":
            "bounded_int_table core_kernel/bounded_int_table",

            "@//.opam.d/buildfiles/core_kernel/bus:BUILD.bazel":
            "bus core_kernel/bus",

            "@//.opam.d/buildfiles/core_kernel/caml_unix:BUILD.bazel":
            "caml_unix core_kernel/caml_unix",

            "@//.opam.d/buildfiles/core_kernel/composition_infix:BUILD.bazel":
            "composition_infix core_kernel/composition_infix",

            "@//.opam.d/buildfiles/core_kernel/enum:BUILD.bazel":
            "enum core_kernel/enum",

            "@//.opam.d/buildfiles/core_kernel/fheap:BUILD.bazel":
            "fheap core_kernel/fheap",

            "@//.opam.d/buildfiles/core_kernel/flags:BUILD.bazel":
            "flags core_kernel/flags",

            "@//.opam.d/buildfiles/core_kernel/force_once:BUILD.bazel":
            "force_once core_kernel/force_once",

            "@//.opam.d/buildfiles/core_kernel/hash_heap:BUILD.bazel":
            "hash_heap core_kernel/hash_heap",

            "@//.opam.d/buildfiles/core_kernel/int_set:BUILD.bazel":
            "int_set core_kernel/int_set",

            "@//.opam.d/buildfiles/core_kernel/iobuf:BUILD.bazel":
            "iobuf core_kernel/iobuf",

            "@//.opam.d/buildfiles/core_kernel/limiter:BUILD.bazel":
            "limiter core_kernel/limiter",

            "@//.opam.d/buildfiles/core_kernel/linked_stack:BUILD.bazel":
            "linked_stack core_kernel/linked_stack",

            "@//.opam.d/buildfiles/core_kernel/moption:BUILD.bazel":
            "moption core_kernel/moption",

            "@//.opam.d/buildfiles/core_kernel/pairing_heap:BUILD.bazel":
            "pairing_heap core_kernel/pairing_heap",

            "@//.opam.d/buildfiles/core_kernel/pooled_hashtbl:BUILD.bazel":
            "pooled_hashtbl core_kernel/pooled_hashtbl",

            "@//.opam.d/buildfiles/core_kernel/rope:BUILD.bazel":
            "rope core_kernel/rope",

            "@//.opam.d/buildfiles/core_kernel/sexp_hidden_in_test:BUILD.bazel":
            "sexp_hidden_in_test core_kernel/sexp_hidden_in_test",

            "@//.opam.d/buildfiles/core_kernel/thread_pool_cpu_affinity:BUILD.bazel":
            "thread_pool_cpu_affinity core_kernel/thread_pool_cpu_affinity",

            "@//.opam.d/buildfiles/core_kernel/thread_safe_queue:BUILD.bazel":
            "thread_safe_queue core_kernel/thread_safe_queue",

            "@//.opam.d/buildfiles/core_kernel/timing_wheel:BUILD.bazel":
            "timing_wheel core_kernel/timing_wheel",

            "@//.opam.d/buildfiles/core_kernel/total_map:BUILD.bazel":
            "total_map core_kernel/total_map",

            "@//.opam.d/buildfiles/core_kernel/tuple_pool:BUILD.bazel":
            "tuple_pool core_kernel/tuple_pool",

            "@//.opam.d/buildfiles/core_kernel/univ:BUILD.bazel":
            "univ core_kernel/univ",

            "@//.opam.d/buildfiles/core_kernel/unpack_buffer:BUILD.bazel":
            "unpack_buffer core_kernel/unpack_buffer",

            "@//.opam.d/buildfiles/core_kernel/uopt:BUILD.bazel":
            "uopt core_kernel/uopt",

            "@//.opam.d/buildfiles/core_kernel/uuid:BUILD.bazel":
            "uuid core_kernel/uuid",

            "@//.opam.d/buildfiles/core_kernel/version_util:BUILD.bazel":
            "version_util core_kernel/version_util",

            "@//.opam.d/buildfiles/core_kernel/weak_array:BUILD.bazel":
            "weak_array core_kernel/weak_array",

            "@//.opam.d/buildfiles/core_kernel/weak_hashtbl:BUILD.bazel":
            "weak_hashtbl core_kernel/weak_hashtbl",

            "@//.opam.d/buildfiles/core_kernel/weak_pointer:BUILD.bazel":
            "weak_pointer core_kernel/weak_pointer",

        }
    )

    new_local_pkg_repository(
        name       = "hacl-star-raw",
        build_file = "@//.opam.d/buildfiles/hacl-star-raw:BUILD.bazel",
        path       = "hacl-star-raw",
    )

    new_local_pkg_repository(
        name       = "spawn",
        build_file = "@//.opam.d/buildfiles/spawn:BUILD.bazel",
        path       = "spawn",
    )

    new_local_pkg_repository(
        name       = "fieldslib",
        build_file = "@//.opam.d/buildfiles/fieldslib:BUILD.bazel",
        path       = "fieldslib",
    )

    new_local_pkg_repository(
        name       = "terminal_size",
        build_file = "@//.opam.d/buildfiles/terminal_size:BUILD.bazel",
        path       = "terminal_size",
    )

    new_local_pkg_repository(
        name       = "str",
        build_file = "@//.opam.d/buildfiles/str:BUILD.bazel",
        path       = "str",
    )

    new_local_pkg_repository(
        name       = "mirage-crypto-pk",
        build_file = "@//.opam.d/buildfiles/mirage-crypto-pk:BUILD.bazel",
        path       = "mirage-crypto-pk",
    )

    new_local_pkg_repository(
        name       = "stdcompat",
        build_file = "@//.opam.d/buildfiles/stdcompat:BUILD.bazel",
        path       = "stdcompat",
    )

    new_local_pkg_repository(
        name       = "codept",
        build_file = "@//.opam.d/buildfiles/codept:BUILD.bazel",
        path       = "codept",
        subpackages = {
            "@//.opam.d/buildfiles/codept/ocamlbuild:BUILD.bazel":
            "ocamlbuild codept/ocamlbuild",

        }
    )

    new_local_pkg_repository(
        name       = "ocamldoc",
        build_file = "@//.opam.d/buildfiles/ocamldoc:BUILD.bazel",
        path       = "ocamldoc",
    )

    new_local_pkg_repository(
        name       = "base",
        build_file = "@//.opam.d/buildfiles/base:BUILD.bazel",
        path       = "base",
        subpackages = {
            "@//.opam.d/buildfiles/base/base_internalhash_types:BUILD.bazel":
            "base_internalhash_types base/base_internalhash_types",

            "@//.opam.d/buildfiles/base/caml:BUILD.bazel":
            "caml base/caml",

            "@//.opam.d/buildfiles/base/md5:BUILD.bazel":
            "md5 base/md5",

            "@//.opam.d/buildfiles/base/shadow_stdlib:BUILD.bazel":
            "shadow_stdlib base/shadow_stdlib",

        }
    )

    new_local_pkg_repository(
        name       = "data-encoding",
        build_file = "@//.opam.d/buildfiles/data-encoding:BUILD.bazel",
        path       = "data-encoding",
    )

    new_local_pkg_repository(
        name       = "variantslib",
        build_file = "@//.opam.d/buildfiles/variantslib:BUILD.bazel",
        path       = "variantslib",
    )

    new_local_pkg_repository(
        name       = "genspio",
        build_file = "@//.opam.d/buildfiles/genspio:BUILD.bazel",
        path       = "genspio",
    )

    new_local_pkg_repository(
        name       = "uucp",
        build_file = "@//.opam.d/buildfiles/uucp:BUILD.bazel",
        path       = "uucp",
    )

    new_local_pkg_repository(
        name       = "stringext",
        build_file = "@//.opam.d/buildfiles/stringext:BUILD.bazel",
        path       = "stringext",
    )

    new_local_pkg_repository(
        name       = "irmin",
        build_file = "@//.opam.d/buildfiles/irmin:BUILD.bazel",
        path       = "irmin",
        subpackages = {
            "@//.opam.d/buildfiles/irmin/mem:BUILD.bazel":
            "mem irmin/mem",

        }
    )

    new_local_pkg_repository(
        name       = "fpath",
        build_file = "@//.opam.d/buildfiles/fpath:BUILD.bazel",
        path       = "fpath",
        subpackages = {
            "@//.opam.d/buildfiles/fpath/top:BUILD.bazel":
            "top fpath",

        }
    )

    new_local_pkg_repository(
        name       = "re",
        build_file = "@//.opam.d/buildfiles/re:BUILD.bazel",
        path       = "re",
        subpackages = {
            "@//.opam.d/buildfiles/re/emacs:BUILD.bazel":
            "emacs re/emacs",

            "@//.opam.d/buildfiles/re/glob:BUILD.bazel":
            "glob re/glob",

            "@//.opam.d/buildfiles/re/pcre:BUILD.bazel":
            "pcre re/pcre",

            "@//.opam.d/buildfiles/re/perl:BUILD.bazel":
            "perl re/perl",

            "@//.opam.d/buildfiles/re/posix:BUILD.bazel":
            "posix re/posix",

            "@//.opam.d/buildfiles/re/str:BUILD.bazel":
            "str re/str",

        }
    )

    new_local_pkg_repository(
        name       = "cohttp",
        build_file = "@//.opam.d/buildfiles/cohttp:BUILD.bazel",
        path       = "cohttp",
    )

    new_local_pkg_repository(
        name       = "dune-configurator",
        build_file = "@//.opam.d/buildfiles/dune-configurator:BUILD.bazel",
        path       = "dune-configurator",
    )

    new_local_pkg_repository(
        name       = "repr",
        build_file = "@//.opam.d/buildfiles/repr:BUILD.bazel",
        path       = "repr",
    )

    new_local_pkg_repository(
        name       = "ppx_fields_conv",
        build_file = "@//.opam.d/buildfiles/ppx_fields_conv:BUILD.bazel",
        path       = "ppx_fields_conv",
    )

    new_local_pkg_repository(
        name       = "mtime",
        build_file = "@//.opam.d/buildfiles/mtime:BUILD.bazel",
        path       = "mtime",
        subpackages = {
            "@//.opam.d/buildfiles/mtime/top:BUILD.bazel":
            "top mtime",

            "@//.opam.d/buildfiles/mtime/clock:BUILD.bazel":
            "clock mtime",

            "@//.opam.d/buildfiles/mtime/clock/os:BUILD.bazel":
            "clock/os mtime/os",

            "@//.opam.d/buildfiles/mtime/clock/jsoo:BUILD.bazel":
            "clock/jsoo mtime/jsoo",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_here",
        build_file = "@//.opam.d/buildfiles/ppx_here:BUILD.bazel",
        path       = "ppx_here",
        subpackages = {
            "@//.opam.d/buildfiles/ppx_here/expander:BUILD.bazel":
            "expander ppx_here/expander",

            "@//.opam.d/buildfiles/ppx_here/runtime-lib:BUILD.bazel":
            "runtime-lib ppx_here/runtime-lib",

        }
    )

    new_local_pkg_repository(
        name       = "ppx_js_style",
        build_file = "@//.opam.d/buildfiles/ppx_js_style:BUILD.bazel",
        path       = "ppx_js_style",
    )

    new_local_pkg_repository(
        name       = "jst-config",
        build_file = "@//.opam.d/buildfiles/jst-config:BUILD.bazel",
        path       = "jst-config",
    )

    new_local_pkg_repository(
        name       = "mirage-crypto",
        build_file = "@//.opam.d/buildfiles/mirage-crypto:BUILD.bazel",
        path       = "mirage-crypto",
    )

    new_local_pkg_repository(
        name       = "dynlink",
        build_file = "@//.opam.d/buildfiles/dynlink:BUILD.bazel",
        path       = "dynlink",
    )

