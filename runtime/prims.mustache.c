#define CAML_INTERNALS
#include "caml/mlvalues.h"
#include "caml/prims.h"
{{#primitives}}
extern value caml_{{prim}}();
{{/primitives}}
{{#int64}}
extern value caml_int64_{{prim}}();
extern value caml_int64_{{prim}}_native();
{{/int64}}
c_primitive caml_builtin_cprim[] = {
{{#primitives}}
  caml_{{prim}},
{{/primitives}}
{{#int64}}
  caml_int64_{{prim}},
  caml_int64_{{prim}}_native,
{{/int64}}
  0 };

char * caml_names_of_builtin_cprim[] = {
{{#primitives}}
  "caml_{{prim}}",
{{/primitives}}
{{#int64}}
  "caml_int64_{{prim}}",
  "caml_int64_{{prim}}_native",
{{/int64}}
  0 };
