 .set domain_curr_field, 0
        .macro DOMAIN_STATE c_type, name
        .equ domain_field_caml_\name, domain_curr_field
        .set domain_curr_field, domain_curr_field + 1
        .endm
DOMAIN_STATE atomic_uintnat, young_limit
DOMAIN_STATE value*, young_ptr
DOMAIN_STATE value*, young_start
DOMAIN_STATE value*, young_end
DOMAIN_STATE struct stack_info*, current_stack
DOMAIN_STATE void*, exn_handler
DOMAIN_STATE int, action_pending
DOMAIN_STATE struct c_stack_link*, c_stack
DOMAIN_STATE struct stack_info**, stack_cache
DOMAIN_STATE value*, gc_regs_buckets
DOMAIN_STATE value*, gc_regs
DOMAIN_STATE struct caml_minor_tables*, minor_tables
DOMAIN_STATE struct mark_stack*, mark_stack
DOMAIN_STATE uintnat, marking_done
DOMAIN_STATE uintnat, sweeping_done
DOMAIN_STATE uintnat, allocated_words
DOMAIN_STATE uintnat, swept_words
DOMAIN_STATE intnat, major_work_computed
DOMAIN_STATE intnat, major_work_todo
DOMAIN_STATE double, major_gc_clock
DOMAIN_STATE struct caml__roots_block*, local_roots
DOMAIN_STATE struct caml_ephe_info*, ephe_info
DOMAIN_STATE struct caml_final_info*, final_info
DOMAIN_STATE intnat, backtrace_pos
DOMAIN_STATE intnat, backtrace_active
DOMAIN_STATE backtrace_slot*, backtrace_buffer
DOMAIN_STATE value, backtrace_last_exn
DOMAIN_STATE intnat, compare_unordered
DOMAIN_STATE uintnat, oo_next_id_local
DOMAIN_STATE uintnat, requested_major_slice
DOMAIN_STATE uintnat, requested_minor_gc
DOMAIN_STATE atomic_uintnat, requested_external_interrupt
DOMAIN_STATE int, parser_trace
DOMAIN_STATE asize_t, minor_heap_wsz
DOMAIN_STATE struct caml_heap_state*, shared_heap
DOMAIN_STATE int, id
DOMAIN_STATE int, unique_id
DOMAIN_STATE value, dls_root
DOMAIN_STATE double, extra_heap_resources
DOMAIN_STATE double, extra_heap_resources_minor
DOMAIN_STATE uintnat, dependent_size
DOMAIN_STATE uintnat, dependent_allocated
DOMAIN_STATE struct caml_extern_state*, extern_state
DOMAIN_STATE struct caml_intern_state*, intern_state
DOMAIN_STATE uintnat, stat_minor_words
DOMAIN_STATE uintnat, stat_promoted_words
DOMAIN_STATE uintnat, stat_major_words
DOMAIN_STATE intnat, stat_minor_collections
DOMAIN_STATE intnat, stat_forced_major_collections
DOMAIN_STATE uintnat, stat_blocks_marked
DOMAIN_STATE int, inside_stw_handler
DOMAIN_STATE intnat, trap_sp_off
DOMAIN_STATE intnat, trap_barrier_off
DOMAIN_STATE int64_t, trap_barrier_block
DOMAIN_STATE struct caml_exception_context*, external_raise
DOMAIN_STATE extra_params_area, extra_params
 .macro ADDRGLOBAL reg, symb
        adrp x17, _\symb@GOTPAGE
        ldr \reg, [x17, _\symb@GOTPAGEOFF]
        .endm
        .macro FUNCTION name
        .align 2
        .globl _\name
_\name:
        .endm
        .macro OBJECT name
        .data
        .align 3
        .globl _\name
_\name:
        .endm
.macro SWITCH_OCAML_TO_C
        ldr x16, [x28, 8*domain_field_caml_current_stack]
        mov x17, sp
        str x17, [x16]
        ldr x17, [x28, 8*domain_field_caml_c_stack]
        str x16, [x17]
        mov x16, sp
        str x16, [x17, #8]
        mov sp, x17
        .cfi_remember_state
        .cfi_escape 0x0f, 5, 0x70 + 31, 8, 0x06, 0x23, 16
.endm
.macro SWITCH_C_TO_OCAML
        ldr x16, [sp, #8]
        mov sp, x16
        .cfi_restore_state
.endm
.macro SAVE_ALL_REGS
        str x27, [x28, 8*domain_field_caml_young_ptr]
        str x26, [x28, 8*domain_field_caml_exn_handler]
        ldr x16, [x28, 8*domain_field_caml_gc_regs_buckets]
        ldr x17, [x16, 0]
        str x17, [x28, 8*domain_field_caml_gc_regs_buckets]
        stp x0, x1, [x16, 16]
        stp x2, x3, [x16, 32]
        stp x4, x5, [x16, 48]
        stp x6, x7, [x16, 64]
        stp x8, x9, [x16, 80]
        stp x10, x11, [x16, 96]
        stp x12, x13, [x16, 112]
        stp x14, x15, [x16, 128]
        stp x19, x20, [x16, 144]
        stp x21, x22, [x16, 160]
        stp x23, x24, [x16, 176]
        str x25, [x16, 192]
        stp d0, d1, [x16, 208]
        stp d2, d3, [x16, 224]
        stp d4, d5, [x16, 240]
        stp d6, d7, [x16, 256]
        stp d16, d17, [x16, 272]
        stp d18, d19, [x16, 288]
        stp d20, d21, [x16, 304]
        stp d22, d23, [x16, 320]
        stp d24, d25, [x16, 336]
        stp d26, d27, [x16, 352]
        stp d28, d29, [x16, 368]
        stp d30, d31, [x16, 384]
        add x16, x16, #16
        str x16, [x28, 8*domain_field_caml_gc_regs]
.endm
.macro RESTORE_ALL_REGS
        ldr x16, [x28, 8*domain_field_caml_gc_regs]
        sub x16, x16, #16
        ldp x0, x1, [x16, 16]
        ldp x2, x3, [x16, 32]
        ldp x4, x5, [x16, 48]
        ldp x6, x7, [x16, 64]
        ldp x8, x9, [x16, 80]
        ldp x10, x11, [x16, 96]
        ldp x12, x13, [x16, 112]
        ldp x14, x15, [x16, 128]
        ldp x19, x20, [x16, 144]
        ldp x21, x22, [x16, 160]
        ldp x23, x24, [x16, 176]
        ldr x25, [x16, 192]
        ldp d0, d1, [x16, 208]
        ldp d2, d3, [x16, 224]
        ldp d4, d5, [x16, 240]
        ldp d6, d7, [x16, 256]
        ldp d16, d17, [x16, 272]
        ldp d18, d19, [x16, 288]
        ldp d20, d21, [x16, 304]
        ldp d22, d23, [x16, 320]
        ldp d24, d25, [x16, 336]
        ldp d26, d27, [x16, 352]
        ldp d28, d29, [x16, 368]
        ldp d30, d31, [x16, 384]
        ldr x17, [x28, 8*domain_field_caml_gc_regs_buckets]
        str x17, [x16, 0]
        str x16, [x28, 8*domain_field_caml_gc_regs_buckets]
        ldr x27, [x28, 8*domain_field_caml_young_ptr]
        ldr x26, [x28, 8*domain_field_caml_exn_handler]
.endm
        .globl _caml_system__code_begin
_caml_system__code_begin:
FUNCTION caml_call_realloc_stack
        .cfi_startproc
        .cfi_offset 29,-16
        .cfi_offset 30,-8
        stp x29, x30, [sp, -16]!
        .cfi_adjust_cfa_offset 16
        add x29, sp, #0
        SAVE_ALL_REGS
        ldr x0, [sp, 16]
        SWITCH_OCAML_TO_C
        bl _caml_try_realloc_stack
        SWITCH_C_TO_OCAML
        cbz x0, 1f
        RESTORE_ALL_REGS
        ldp x29, x30, [sp], 16
        ret
1: RESTORE_ALL_REGS
        ldp x29, x30, [sp], 16
        add sp, sp, 16
        ADDRGLOBAL x0, caml_exn_Stack_overflow
        b _caml_raise_exn
        .cfi_endproc
FUNCTION caml_call_gc
        .cfi_startproc
Lcaml_call_gc:
        .cfi_offset 29,-16
        .cfi_offset 30,-8
        stp x29, x30, [sp, -16]!
        .cfi_adjust_cfa_offset 16
        add x29, sp, #0
        SAVE_ALL_REGS
        SWITCH_OCAML_TO_C
        bl _caml_garbage_collection
        SWITCH_C_TO_OCAML
        RESTORE_ALL_REGS
        ldp x29, x30, [sp], 16
        ret
        .cfi_endproc
FUNCTION caml_alloc1
        .cfi_startproc
        ldr x16, [x28, 8*domain_field_caml_young_limit]
        sub x27, x27, #16
        cmp x27, x16
        b.lo Lcaml_call_gc
        ret
        .cfi_endproc
FUNCTION caml_alloc2
        .cfi_startproc
        ldr x16, [x28, 8*domain_field_caml_young_limit]
        sub x27, x27, #24
        cmp x27, x16
        b.lo Lcaml_call_gc
        ret
        .cfi_endproc
FUNCTION caml_alloc3
        .cfi_startproc
        ldr x16, [x28, 8*domain_field_caml_young_limit]
        sub x27, x27, #32
        cmp x27, x16
        b.lo Lcaml_call_gc
        ret
        .cfi_endproc
FUNCTION caml_allocN
        .cfi_startproc
        ldr x16, [x28, 8*domain_field_caml_young_limit]
        sub x27, x27, x8
        cmp x27, x16
        b.lo Lcaml_call_gc
        ret
        .cfi_endproc
FUNCTION caml_c_call
        .cfi_startproc
        .cfi_offset 29,-16
        .cfi_offset 30,-8
        stp x29, x30, [sp, -16]!
        .cfi_adjust_cfa_offset 16
        add x29, sp, #0
        SWITCH_OCAML_TO_C
        str x27, [x28, 8*domain_field_caml_young_ptr]
        str x26, [x28, 8*domain_field_caml_exn_handler]
        blr x8
        ldr x27, [x28, 8*domain_field_caml_young_ptr]
        SWITCH_C_TO_OCAML
        ldp x29, x30, [sp], 16
        ret
        .cfi_endproc
FUNCTION caml_c_call_stack_args
        .cfi_startproc
        .cfi_offset 29,-16
        .cfi_offset 30,-8
        stp x29, x30, [sp, -16]!
        .cfi_adjust_cfa_offset 16
        add x29, sp, #0
        SWITCH_OCAML_TO_C
        str x27, [x28, 8*domain_field_caml_young_ptr]
        str x26, [x28, 8*domain_field_caml_exn_handler]
        mov x19, sp
1: sub x21, x21, 16
        cmp x21, x20
        b.lo 2f
        ldp x16, x17, [x21]
        stp x16, x17, [sp, -16]!; .cfi_adjust_cfa_offset 16
        b 1b
2:
        blr x8
        mov sp, x19
        ldr x27, [x28, 8*domain_field_caml_young_ptr]
        SWITCH_C_TO_OCAML
        ldp x29, x30, [sp], 16
        ret
.cfi_endproc
FUNCTION caml_start_program
        .cfi_startproc
        mov x16, x0
        ADDRGLOBAL x17, caml_program
Ljump_to_caml:
        .cfi_offset 29,-160
        .cfi_offset 30,-152
        stp x29, x30, [sp, -160]!
        .cfi_adjust_cfa_offset 160
        add x29, sp, #0
        stp x19, x20, [sp, 16]
        stp x21, x22, [sp, 32]
        stp x23, x24, [sp, 48]
        stp x25, x26, [sp, 64]
        stp x27, x28, [sp, 80]
        stp d8, d9, [sp, 96]
        stp d10, d11, [sp, 112]
        stp d12, d13, [sp, 128]
        stp d14, d15, [sp, 144]
        mov x28, x16
        ldr x27, [x28, 8*domain_field_caml_young_ptr]
        ldr x8, [x28, 8*domain_field_caml_c_stack]
        stp x8, xzr, [sp, -16]!
        .cfi_adjust_cfa_offset 16
        stp xzr, xzr, [sp, -16]!
        .cfi_adjust_cfa_offset 16
        mov x8, sp
        str x8, [x28, 8*domain_field_caml_c_stack]
        ldr x8, [x28, 8*domain_field_caml_current_stack]
        ldr x8, [x8]
        ldr x9, [x28, 8*domain_field_caml_gc_regs]
        str x9, [x8, -8]!
        mov x9, sp
        str x9, [x8, -8]!
        ldr x9, [x28, 8*domain_field_caml_exn_handler]
        adr x10, Ltrap_handler
        stp x9, x10, [x8, -16]!
        mov x26, x8
        mov sp, x8
        .cfi_remember_state
        .cfi_escape 0x0f, 3 + 2 + 2, 0x70 + 31, 16 , 0x06, 0x23, 96, 0x23, 96
        blr x17
Lcaml_retaddr:
        ldr x8, [sp], 16
        .cfi_adjust_cfa_offset -16
        str x8, [x28, 8*domain_field_caml_exn_handler]
Lreturn_result:
        ldp x8, x9, [sp], 16
        .cfi_adjust_cfa_offset -16
        str x9, [x28, 8*domain_field_caml_gc_regs]
        str x27, [x28, 8*domain_field_caml_young_ptr]
        ldr x8, [x28, 8*domain_field_caml_current_stack]
        mov x9, sp
        str x9, [x8]
        ldr x9, [x28, 8*domain_field_caml_c_stack]
        mov sp, x9
        .cfi_restore_state
        ldr x8, [sp, #16]
        add sp, sp, 32
        .cfi_adjust_cfa_offset -32
        str x8, [x28, 8*domain_field_caml_c_stack]
        ldp x19, x20, [sp, 16]
        ldp x21, x22, [sp, 32]
        ldp x23, x24, [sp, 48]
        ldp x25, x26, [sp, 64]
        ldp x27, x28, [sp, 80]
        ldp d8, d9, [sp, 96]
        ldp d10, d11, [sp, 112]
        ldp d12, d13, [sp, 128]
        ldp d14, d15, [sp, 144]
        ldp x29, x30, [sp], 160
        .cfi_adjust_cfa_offset -160
        ret
        .cfi_endproc
        .align 2
Ltrap_handler:
        .cfi_startproc
        str x26, [x28, 8*domain_field_caml_exn_handler]
        orr x0, x0, #2
        b Lreturn_result
        .cfi_endproc
.macro JUMP_TO_TRAP_PTR
        mov sp, x26
        ldr x16, [sp, 8]
        ldr x26, [sp], 16
        br x16
.endm
FUNCTION caml_raise_exn
        .cfi_startproc
        ldr x16, [x28, 8*domain_field_caml_backtrace_active]
        cbnz x16, 2f
1:
        JUMP_TO_TRAP_PTR
2:
        str xzr, [x28, 8*domain_field_caml_backtrace_pos]
Lcaml_reraise_exn_stash:
        mov x19, x0
        mov x1, x30
        mov x2, sp
        mov x3, x26
        ldr x16, [x28, 8*domain_field_caml_c_stack]
        mov sp, x16
        bl _caml_stash_backtrace
        mov x0, x19
        b 1b
        .cfi_endproc
FUNCTION caml_reraise_exn
        .cfi_startproc
        ldr x16, [x28, 8*domain_field_caml_backtrace_active]
        cbnz x16, Lcaml_reraise_exn_stash
        JUMP_TO_TRAP_PTR
        .cfi_endproc
FUNCTION caml_raise_exception
        .cfi_startproc
        mov x28, x0
        mov x0, x1
        ldr x26, [x28, 8*domain_field_caml_exn_handler]
        ldr x27, [x28, 8*domain_field_caml_young_ptr]
        ldr x16, [x28, 8*domain_field_caml_current_stack]
        ldr x16, [x16]
        mov sp, x16
        ldp x29, x30, [sp], 16
        b _caml_raise_exn
        .cfi_endproc
FUNCTION caml_callback_asm
        .cfi_startproc
        mov x16, x0
        ldr x0, [x2]
        ldr x17, [x1]
        b Ljump_to_caml
        .cfi_endproc
FUNCTION caml_callback2_asm
        .cfi_startproc
        mov x16, x0
        mov x17, x1
        ldp x0, x1, [x2, 0]
        mov x2, x17
        ADDRGLOBAL x17, caml_apply2
        b Ljump_to_caml
        .cfi_endproc
FUNCTION caml_callback3_asm
        .cfi_startproc
        mov x16, x0
        mov x3, x1
        ldp x0, x1, [x2, 0]
        ldr x2, [x2, 16]
        ADDRGLOBAL x17, caml_apply3
        b Ljump_to_caml
        .cfi_endproc
.macro SWITCH_OCAML_STACKS old_stack, new_stack
        stp x29, x30, [sp, -16]!
        .cfi_adjust_cfa_offset 16
        add x29, sp, #0
        mov x16, sp
        str x16, [\old_stack]
        str x26, [\old_stack, #8]
        str \new_stack, [x28, 8*domain_field_caml_current_stack]
        ldr x16, [\new_stack]
        mov sp, x16
        ldr x26, [\new_stack, #8]
        ldp x29, x30, [sp], 16
.endm
FUNCTION caml_perform
        .cfi_startproc
        ldr x2, [x28, 8*domain_field_caml_current_stack]
        add x3, x2, 1
        str x3, [x1]
Ldo_perform:
        ldr x9, [x2, #16]
        ldr x10, [x9, #24]
        cbz x10, 1f
        SWITCH_OCAML_STACKS x2, x10
        str xzr, [x9, #24]
        ldr x16, [x9, #16]
        mov x2, x3
        mov x3, x16
        b _caml_apply3
1:
        ldr x10, [x1]
        sub x10, x10, 1
        ldr x9, [x28, 8*domain_field_caml_current_stack]
        SWITCH_OCAML_STACKS x9, x10
        ADDRGLOBAL x8, caml_raise_unhandled_effect
        b _caml_c_call
        .cfi_endproc
FUNCTION caml_reperform
        .cfi_startproc
        ldr x16, [x2, #15]
        ldr x2, [x28, 8*domain_field_caml_current_stack]
        str x2, [x16, #24]
        add x3, x2, 1
        b Ldo_perform
        .cfi_endproc
FUNCTION caml_resume
.cfi_startproc
        sub x0, x0, 1
        ldr x3, [x1]
        cbz x0, 2f
        mov x16, x0
1: ldr x8, [x16, #16]
        ldr x16, [x8, #24]
        cbnz x16, 1b
        ldr x9, [x28, 8*domain_field_caml_current_stack]
        str x9, [x8, #24]
        SWITCH_OCAML_STACKS x9, x0
        mov x0, x2
        br x3
2: ADDRGLOBAL x8, caml_raise_continuation_already_resumed
        b _caml_c_call
        .cfi_endproc
FUNCTION caml_runstack
.cfi_startproc
        .cfi_offset 29,-16
        .cfi_offset 30,-8
        stp x29, x30, [sp, -16]!
        .cfi_adjust_cfa_offset 16
        add x29, sp, #0
        sub x0, x0, 1
        ldr x3, [x1]
        ldr x8, [x28, 8*domain_field_caml_current_stack]
        mov x16, sp
        str x16, [x8]
        str x26, [x8, #8]
        ldr x16, [x0, #16]
        str x8, [x16, #24]
        str x0, [x28, 8*domain_field_caml_current_stack]
        ldr x9, [x0]
        sub x9, x9, 32
        adr x16, Lfiber_exn_handler
        str x16, [x9, 8]
        ldr x16, [x0, #8]
        str x16, [x9]
        mov x26, x9
        mov sp, x9
        .cfi_remember_state
        .cfi_escape 0x0f, 3+3+2, 0x70 + 31, 16 + 8 + 8 + 24, 0x06, 0x23, 0, 0x06, 0x23, 16
        mov x0, x2
        blr x3
Lframe_runstack:
        add x8, sp, 32
        ldr x19, [x8]
1:
        mov x20, x0
        ldr x0, [x28, 8*domain_field_caml_current_stack]
        ldr x16, [x8, #24]
        str x16, [x28, 8*domain_field_caml_current_stack]
        ldr x26, [x16, #8]
        str x26, [x28, 8*domain_field_caml_exn_handler]
        ldr x21, [x16]
        .cfi_restore_state
        .cfi_remember_state
        .cfi_def_cfa_register 21
        ldr x16, [x28, 8*domain_field_caml_c_stack]
        mov sp, x16
        bl _caml_free_stack
        mov x0, x20
        mov x1, x19
        mov sp, x21
        .cfi_restore_state
        ldr x16, [x19]
        ldp x29, x30, [sp], 16
        .cfi_adjust_cfa_offset -16
        br x16
Lfiber_exn_handler:
        add x8, sp, 16
        ldr x19, [x8, #8]
        b 1b
        .cfi_endproc
FUNCTION caml_ml_array_bound_error
        .cfi_startproc
        ADDRGLOBAL x8, caml_array_bound_error_asm
        b _caml_c_call
        .cfi_endproc
        .globl _caml_system__code_end
_caml_system__code_end:
OBJECT caml_system.frametable
        .quad 2
        .quad Lcaml_retaddr
        .short -1
        .short 0
        .align 3
        .quad Lframe_runstack
        .short -1
        .short 0
        .align 3
