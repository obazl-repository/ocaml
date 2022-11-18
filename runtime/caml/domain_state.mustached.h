/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*      KC Sivaramakrishnan, Indian Institute of Technology, Madras       */
/*                Stephen Dolan, University of Cambridge                  */
/*                                                                        */
/*   Copyright 2019 Indian Institute of Technology, Madras                */
/*   Copyright 2019 University of Cambridge                               */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#ifndef CAML_STATE_H
#define CAML_STATE_H

#include <stddef.h>
#include <stdio.h>

#include "misc.h"

#define NUM_EXTRA_PARAMS 64
typedef value extra_params_area[NUM_EXTRA_PARAMS];

/* This structure sits in the TLS area and is also accessed efficiently
 * via native code, which is why the indices are important */
typedef struct {
CAMLalign(8) atomic_uintnat young_limit;
CAMLalign(8) value* young_ptr;
CAMLalign(8) value* young_start;
CAMLalign(8) value* young_end;
CAMLalign(8) struct stack_info* current_stack;
CAMLalign(8) void* exn_handler;
CAMLalign(8) int action_pending;
CAMLalign(8) struct c_stack_link* c_stack;
CAMLalign(8) struct stack_info** stack_cache;
CAMLalign(8) value* gc_regs_buckets;
CAMLalign(8) value* gc_regs;
CAMLalign(8) struct caml_minor_tables* minor_tables;
CAMLalign(8) struct mark_stack* mark_stack;
CAMLalign(8) uintnat marking_done;
CAMLalign(8) uintnat sweeping_done;
CAMLalign(8) uintnat allocated_words;
CAMLalign(8) uintnat swept_words;
CAMLalign(8) intnat major_work_computed;
CAMLalign(8) intnat major_work_todo;
CAMLalign(8) double major_gc_clock;
CAMLalign(8) struct caml__roots_block* local_roots;
CAMLalign(8) struct caml_ephe_info* ephe_info;
CAMLalign(8) struct caml_final_info* final_info;
CAMLalign(8) intnat backtrace_pos;
CAMLalign(8) intnat backtrace_active;
CAMLalign(8) backtrace_slot* backtrace_buffer;
CAMLalign(8) value backtrace_last_exn;
CAMLalign(8) intnat compare_unordered;
CAMLalign(8) uintnat oo_next_id_local;
CAMLalign(8) uintnat requested_major_slice;
CAMLalign(8) uintnat requested_minor_gc;
CAMLalign(8) atomic_uintnat requested_external_interrupt;
CAMLalign(8) int parser_trace;
CAMLalign(8) asize_t minor_heap_wsz;
CAMLalign(8) struct caml_heap_state* shared_heap;
CAMLalign(8) int id;
CAMLalign(8) int unique_id;
CAMLalign(8) value dls_root;
CAMLalign(8) double extra_heap_resources;
CAMLalign(8) double extra_heap_resources_minor;
CAMLalign(8) uintnat dependent_size;
CAMLalign(8) uintnat dependent_allocated;
CAMLalign(8) struct caml_extern_state* extern_state;
CAMLalign(8) struct caml_intern_state* intern_state;
CAMLalign(8) uintnat stat_minor_words;
CAMLalign(8) uintnat stat_promoted_words;
CAMLalign(8) uintnat stat_major_words;
CAMLalign(8) intnat stat_minor_collections;
CAMLalign(8) intnat stat_forced_major_collections;
CAMLalign(8) uintnat stat_blocks_marked;
CAMLalign(8) int inside_stw_handler;
CAMLalign(8) intnat trap_sp_off;
CAMLalign(8) intnat trap_barrier_off;
CAMLalign(8) int64_t trap_barrier_block;
CAMLalign(8) struct caml_exception_context* external_raise;
CAMLalign(8) extra_params_area extra_params;
} caml_domain_state;

enum {
  Domain_state_num_fields =
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
 + 1
};

#define LAST_DOMAIN_STATE_MEMBER extra_params

/* Check that the structure was laid out without padding,
   since the runtime assumes this in computing offsets */
CAML_STATIC_ASSERT(
    offsetof(caml_domain_state, LAST_DOMAIN_STATE_MEMBER) ==
    (Domain_state_num_fields - 1) * 8);

#if defined(HAS_FULL_THREAD_VARIABLES) || defined(IN_CAML_RUNTIME)
  CAMLextern __thread caml_domain_state* caml_state;
  #define Caml_state_opt caml_state
#else
#ifdef __GNUC__
  __attribute__((pure))
#endif
  CAMLextern caml_domain_state* caml_get_domain_state(void);
  #define Caml_state_opt (caml_get_domain_state())
#endif

#define Caml_state (CAMLassert(Caml_state_opt != NULL), Caml_state_opt)

CAMLnoreturn_start
CAMLextern void caml_bad_caml_state(void)
CAMLnoreturn_end;

/* This check is performed regardless of debug mode. It is placed once
   at every code path starting from entry points of the public C API,
   whenever the load of Caml_state_opt can be eliminated by CSE (or if
   the function is not performance-sensitive). */
#define Caml_check_caml_state()                                         \
  (CAMLlikely(Caml_state_opt != NULL) ? (void)0 :                       \
   caml_bad_caml_state())

#define Caml_state_field(field) (Caml_state->field)

#endif /* CAML_STATE_H */
