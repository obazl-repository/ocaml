#ifndef PRIMITIVES_H
#define PRIMITIVES_H
{{#primitives}}
#define CAMLprim_{{prim}} CAMLprim value caml_{{prim}}
{{/primitives}}
{{#int64}}
#define CAMLprim_int64_{{prim}} CAMLprim int64_t caml_int64_{{prim}}
{{/int64}}

#endif