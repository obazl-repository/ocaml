Store_young_limit MACRO reg
  mov [r14+0], reg
ENDM
Load_young_limit MACRO reg
  mov reg, [r14+0]
ENDM
Push_young_limit MACRO
  push [r14+0]
ENDM
Pop_young_limit MACRO
  pop [r14+0]
ENDM
Cmp_young_limit MACRO reg
  cmp reg, [r14+0]
ENDM
Store_young_ptr MACRO reg
  mov [r14+8], reg
ENDM
Load_young_ptr MACRO reg
  mov reg, [r14+8]
ENDM
Push_young_ptr MACRO
  push [r14+8]
ENDM
Pop_young_ptr MACRO
  pop [r14+8]
ENDM
Cmp_young_ptr MACRO reg
  cmp reg, [r14+8]
ENDM
Store_young_start MACRO reg
  mov [r14+16], reg
ENDM
Load_young_start MACRO reg
  mov reg, [r14+16]
ENDM
Push_young_start MACRO
  push [r14+16]
ENDM
Pop_young_start MACRO
  pop [r14+16]
ENDM
Cmp_young_start MACRO reg
  cmp reg, [r14+16]
ENDM
Store_young_end MACRO reg
  mov [r14+24], reg
ENDM
Load_young_end MACRO reg
  mov reg, [r14+24]
ENDM
Push_young_end MACRO
  push [r14+24]
ENDM
Pop_young_end MACRO
  pop [r14+24]
ENDM
Cmp_young_end MACRO reg
  cmp reg, [r14+24]
ENDM
Store_current_stack MACRO reg
  mov [r14+32], reg
ENDM
Load_current_stack MACRO reg
  mov reg, [r14+32]
ENDM
Push_current_stack MACRO
  push [r14+32]
ENDM
Pop_current_stack MACRO
  pop [r14+32]
ENDM
Cmp_current_stack MACRO reg
  cmp reg, [r14+32]
ENDM
Store_exn_handler MACRO reg
  mov [r14+40], reg
ENDM
Load_exn_handler MACRO reg
  mov reg, [r14+40]
ENDM
Push_exn_handler MACRO
  push [r14+40]
ENDM
Pop_exn_handler MACRO
  pop [r14+40]
ENDM
Cmp_exn_handler MACRO reg
  cmp reg, [r14+40]
ENDM
Store_action_pending MACRO reg
  mov [r14+48], reg
ENDM
Load_action_pending MACRO reg
  mov reg, [r14+48]
ENDM
Push_action_pending MACRO
  push [r14+48]
ENDM
Pop_action_pending MACRO
  pop [r14+48]
ENDM
Cmp_action_pending MACRO reg
  cmp reg, [r14+48]
ENDM
Store_c_stack MACRO reg
  mov [r14+56], reg
ENDM
Load_c_stack MACRO reg
  mov reg, [r14+56]
ENDM
Push_c_stack MACRO
  push [r14+56]
ENDM
Pop_c_stack MACRO
  pop [r14+56]
ENDM
Cmp_c_stack MACRO reg
  cmp reg, [r14+56]
ENDM
Store_stack_cache MACRO reg
  mov [r14+64], reg
ENDM
Load_stack_cache MACRO reg
  mov reg, [r14+64]
ENDM
Push_stack_cache MACRO
  push [r14+64]
ENDM
Pop_stack_cache MACRO
  pop [r14+64]
ENDM
Cmp_stack_cache MACRO reg
  cmp reg, [r14+64]
ENDM
Store_gc_regs_buckets MACRO reg
  mov [r14+72], reg
ENDM
Load_gc_regs_buckets MACRO reg
  mov reg, [r14+72]
ENDM
Push_gc_regs_buckets MACRO
  push [r14+72]
ENDM
Pop_gc_regs_buckets MACRO
  pop [r14+72]
ENDM
Cmp_gc_regs_buckets MACRO reg
  cmp reg, [r14+72]
ENDM
Store_gc_regs MACRO reg
  mov [r14+80], reg
ENDM
Load_gc_regs MACRO reg
  mov reg, [r14+80]
ENDM
Push_gc_regs MACRO
  push [r14+80]
ENDM
Pop_gc_regs MACRO
  pop [r14+80]
ENDM
Cmp_gc_regs MACRO reg
  cmp reg, [r14+80]
ENDM
Store_minor_tables MACRO reg
  mov [r14+88], reg
ENDM
Load_minor_tables MACRO reg
  mov reg, [r14+88]
ENDM
Push_minor_tables MACRO
  push [r14+88]
ENDM
Pop_minor_tables MACRO
  pop [r14+88]
ENDM
Cmp_minor_tables MACRO reg
  cmp reg, [r14+88]
ENDM
Store_mark_stack MACRO reg
  mov [r14+96], reg
ENDM
Load_mark_stack MACRO reg
  mov reg, [r14+96]
ENDM
Push_mark_stack MACRO
  push [r14+96]
ENDM
Pop_mark_stack MACRO
  pop [r14+96]
ENDM
Cmp_mark_stack MACRO reg
  cmp reg, [r14+96]
ENDM
Store_marking_done MACRO reg
  mov [r14+104], reg
ENDM
Load_marking_done MACRO reg
  mov reg, [r14+104]
ENDM
Push_marking_done MACRO
  push [r14+104]
ENDM
Pop_marking_done MACRO
  pop [r14+104]
ENDM
Cmp_marking_done MACRO reg
  cmp reg, [r14+104]
ENDM
Store_sweeping_done MACRO reg
  mov [r14+112], reg
ENDM
Load_sweeping_done MACRO reg
  mov reg, [r14+112]
ENDM
Push_sweeping_done MACRO
  push [r14+112]
ENDM
Pop_sweeping_done MACRO
  pop [r14+112]
ENDM
Cmp_sweeping_done MACRO reg
  cmp reg, [r14+112]
ENDM
Store_allocated_words MACRO reg
  mov [r14+120], reg
ENDM
Load_allocated_words MACRO reg
  mov reg, [r14+120]
ENDM
Push_allocated_words MACRO
  push [r14+120]
ENDM
Pop_allocated_words MACRO
  pop [r14+120]
ENDM
Cmp_allocated_words MACRO reg
  cmp reg, [r14+120]
ENDM
Store_swept_words MACRO reg
  mov [r14+128], reg
ENDM
Load_swept_words MACRO reg
  mov reg, [r14+128]
ENDM
Push_swept_words MACRO
  push [r14+128]
ENDM
Pop_swept_words MACRO
  pop [r14+128]
ENDM
Cmp_swept_words MACRO reg
  cmp reg, [r14+128]
ENDM
Store_major_work_computed MACRO reg
  mov [r14+136], reg
ENDM
Load_major_work_computed MACRO reg
  mov reg, [r14+136]
ENDM
Push_major_work_computed MACRO
  push [r14+136]
ENDM
Pop_major_work_computed MACRO
  pop [r14+136]
ENDM
Cmp_major_work_computed MACRO reg
  cmp reg, [r14+136]
ENDM
Store_major_work_todo MACRO reg
  mov [r14+144], reg
ENDM
Load_major_work_todo MACRO reg
  mov reg, [r14+144]
ENDM
Push_major_work_todo MACRO
  push [r14+144]
ENDM
Pop_major_work_todo MACRO
  pop [r14+144]
ENDM
Cmp_major_work_todo MACRO reg
  cmp reg, [r14+144]
ENDM
Store_major_gc_clock MACRO reg
  mov [r14+152], reg
ENDM
Load_major_gc_clock MACRO reg
  mov reg, [r14+152]
ENDM
Push_major_gc_clock MACRO
  push [r14+152]
ENDM
Pop_major_gc_clock MACRO
  pop [r14+152]
ENDM
Cmp_major_gc_clock MACRO reg
  cmp reg, [r14+152]
ENDM
Store_local_roots MACRO reg
  mov [r14+160], reg
ENDM
Load_local_roots MACRO reg
  mov reg, [r14+160]
ENDM
Push_local_roots MACRO
  push [r14+160]
ENDM
Pop_local_roots MACRO
  pop [r14+160]
ENDM
Cmp_local_roots MACRO reg
  cmp reg, [r14+160]
ENDM
Store_ephe_info MACRO reg
  mov [r14+168], reg
ENDM
Load_ephe_info MACRO reg
  mov reg, [r14+168]
ENDM
Push_ephe_info MACRO
  push [r14+168]
ENDM
Pop_ephe_info MACRO
  pop [r14+168]
ENDM
Cmp_ephe_info MACRO reg
  cmp reg, [r14+168]
ENDM
Store_final_info MACRO reg
  mov [r14+176], reg
ENDM
Load_final_info MACRO reg
  mov reg, [r14+176]
ENDM
Push_final_info MACRO
  push [r14+176]
ENDM
Pop_final_info MACRO
  pop [r14+176]
ENDM
Cmp_final_info MACRO reg
  cmp reg, [r14+176]
ENDM
Store_backtrace_pos MACRO reg
  mov [r14+184], reg
ENDM
Load_backtrace_pos MACRO reg
  mov reg, [r14+184]
ENDM
Push_backtrace_pos MACRO
  push [r14+184]
ENDM
Pop_backtrace_pos MACRO
  pop [r14+184]
ENDM
Cmp_backtrace_pos MACRO reg
  cmp reg, [r14+184]
ENDM
Store_backtrace_active MACRO reg
  mov [r14+192], reg
ENDM
Load_backtrace_active MACRO reg
  mov reg, [r14+192]
ENDM
Push_backtrace_active MACRO
  push [r14+192]
ENDM
Pop_backtrace_active MACRO
  pop [r14+192]
ENDM
Cmp_backtrace_active MACRO reg
  cmp reg, [r14+192]
ENDM
Store_backtrace_buffer MACRO reg
  mov [r14+200], reg
ENDM
Load_backtrace_buffer MACRO reg
  mov reg, [r14+200]
ENDM
Push_backtrace_buffer MACRO
  push [r14+200]
ENDM
Pop_backtrace_buffer MACRO
  pop [r14+200]
ENDM
Cmp_backtrace_buffer MACRO reg
  cmp reg, [r14+200]
ENDM
Store_backtrace_last_exn MACRO reg
  mov [r14+208], reg
ENDM
Load_backtrace_last_exn MACRO reg
  mov reg, [r14+208]
ENDM
Push_backtrace_last_exn MACRO
  push [r14+208]
ENDM
Pop_backtrace_last_exn MACRO
  pop [r14+208]
ENDM
Cmp_backtrace_last_exn MACRO reg
  cmp reg, [r14+208]
ENDM
Store_compare_unordered MACRO reg
  mov [r14+216], reg
ENDM
Load_compare_unordered MACRO reg
  mov reg, [r14+216]
ENDM
Push_compare_unordered MACRO
  push [r14+216]
ENDM
Pop_compare_unordered MACRO
  pop [r14+216]
ENDM
Cmp_compare_unordered MACRO reg
  cmp reg, [r14+216]
ENDM
Store_oo_next_id_local MACRO reg
  mov [r14+224], reg
ENDM
Load_oo_next_id_local MACRO reg
  mov reg, [r14+224]
ENDM
Push_oo_next_id_local MACRO
  push [r14+224]
ENDM
Pop_oo_next_id_local MACRO
  pop [r14+224]
ENDM
Cmp_oo_next_id_local MACRO reg
  cmp reg, [r14+224]
ENDM
Store_requested_major_slice MACRO reg
  mov [r14+232], reg
ENDM
Load_requested_major_slice MACRO reg
  mov reg, [r14+232]
ENDM
Push_requested_major_slice MACRO
  push [r14+232]
ENDM
Pop_requested_major_slice MACRO
  pop [r14+232]
ENDM
Cmp_requested_major_slice MACRO reg
  cmp reg, [r14+232]
ENDM
Store_requested_minor_gc MACRO reg
  mov [r14+240], reg
ENDM
Load_requested_minor_gc MACRO reg
  mov reg, [r14+240]
ENDM
Push_requested_minor_gc MACRO
  push [r14+240]
ENDM
Pop_requested_minor_gc MACRO
  pop [r14+240]
ENDM
Cmp_requested_minor_gc MACRO reg
  cmp reg, [r14+240]
ENDM
Store_requested_external_interrupt MACRO reg
  mov [r14+248], reg
ENDM
Load_requested_external_interrupt MACRO reg
  mov reg, [r14+248]
ENDM
Push_requested_external_interrupt MACRO
  push [r14+248]
ENDM
Pop_requested_external_interrupt MACRO
  pop [r14+248]
ENDM
Cmp_requested_external_interrupt MACRO reg
  cmp reg, [r14+248]
ENDM
Store_parser_trace MACRO reg
  mov [r14+256], reg
ENDM
Load_parser_trace MACRO reg
  mov reg, [r14+256]
ENDM
Push_parser_trace MACRO
  push [r14+256]
ENDM
Pop_parser_trace MACRO
  pop [r14+256]
ENDM
Cmp_parser_trace MACRO reg
  cmp reg, [r14+256]
ENDM
Store_minor_heap_wsz MACRO reg
  mov [r14+264], reg
ENDM
Load_minor_heap_wsz MACRO reg
  mov reg, [r14+264]
ENDM
Push_minor_heap_wsz MACRO
  push [r14+264]
ENDM
Pop_minor_heap_wsz MACRO
  pop [r14+264]
ENDM
Cmp_minor_heap_wsz MACRO reg
  cmp reg, [r14+264]
ENDM
Store_shared_heap MACRO reg
  mov [r14+272], reg
ENDM
Load_shared_heap MACRO reg
  mov reg, [r14+272]
ENDM
Push_shared_heap MACRO
  push [r14+272]
ENDM
Pop_shared_heap MACRO
  pop [r14+272]
ENDM
Cmp_shared_heap MACRO reg
  cmp reg, [r14+272]
ENDM
Store_id MACRO reg
  mov [r14+280], reg
ENDM
Load_id MACRO reg
  mov reg, [r14+280]
ENDM
Push_id MACRO
  push [r14+280]
ENDM
Pop_id MACRO
  pop [r14+280]
ENDM
Cmp_id MACRO reg
  cmp reg, [r14+280]
ENDM
Store_unique_id MACRO reg
  mov [r14+288], reg
ENDM
Load_unique_id MACRO reg
  mov reg, [r14+288]
ENDM
Push_unique_id MACRO
  push [r14+288]
ENDM
Pop_unique_id MACRO
  pop [r14+288]
ENDM
Cmp_unique_id MACRO reg
  cmp reg, [r14+288]
ENDM
Store_dls_root MACRO reg
  mov [r14+296], reg
ENDM
Load_dls_root MACRO reg
  mov reg, [r14+296]
ENDM
Push_dls_root MACRO
  push [r14+296]
ENDM
Pop_dls_root MACRO
  pop [r14+296]
ENDM
Cmp_dls_root MACRO reg
  cmp reg, [r14+296]
ENDM
Store_extra_heap_resources MACRO reg
  mov [r14+304], reg
ENDM
Load_extra_heap_resources MACRO reg
  mov reg, [r14+304]
ENDM
Push_extra_heap_resources MACRO
  push [r14+304]
ENDM
Pop_extra_heap_resources MACRO
  pop [r14+304]
ENDM
Cmp_extra_heap_resources MACRO reg
  cmp reg, [r14+304]
ENDM
Store_extra_heap_resources_minor MACRO reg
  mov [r14+312], reg
ENDM
Load_extra_heap_resources_minor MACRO reg
  mov reg, [r14+312]
ENDM
Push_extra_heap_resources_minor MACRO
  push [r14+312]
ENDM
Pop_extra_heap_resources_minor MACRO
  pop [r14+312]
ENDM
Cmp_extra_heap_resources_minor MACRO reg
  cmp reg, [r14+312]
ENDM
Store_dependent_size MACRO reg
  mov [r14+320], reg
ENDM
Load_dependent_size MACRO reg
  mov reg, [r14+320]
ENDM
Push_dependent_size MACRO
  push [r14+320]
ENDM
Pop_dependent_size MACRO
  pop [r14+320]
ENDM
Cmp_dependent_size MACRO reg
  cmp reg, [r14+320]
ENDM
Store_dependent_allocated MACRO reg
  mov [r14+328], reg
ENDM
Load_dependent_allocated MACRO reg
  mov reg, [r14+328]
ENDM
Push_dependent_allocated MACRO
  push [r14+328]
ENDM
Pop_dependent_allocated MACRO
  pop [r14+328]
ENDM
Cmp_dependent_allocated MACRO reg
  cmp reg, [r14+328]
ENDM
Store_extern_state MACRO reg
  mov [r14+336], reg
ENDM
Load_extern_state MACRO reg
  mov reg, [r14+336]
ENDM
Push_extern_state MACRO
  push [r14+336]
ENDM
Pop_extern_state MACRO
  pop [r14+336]
ENDM
Cmp_extern_state MACRO reg
  cmp reg, [r14+336]
ENDM
Store_intern_state MACRO reg
  mov [r14+344], reg
ENDM
Load_intern_state MACRO reg
  mov reg, [r14+344]
ENDM
Push_intern_state MACRO
  push [r14+344]
ENDM
Pop_intern_state MACRO
  pop [r14+344]
ENDM
Cmp_intern_state MACRO reg
  cmp reg, [r14+344]
ENDM
Store_stat_minor_words MACRO reg
  mov [r14+352], reg
ENDM
Load_stat_minor_words MACRO reg
  mov reg, [r14+352]
ENDM
Push_stat_minor_words MACRO
  push [r14+352]
ENDM
Pop_stat_minor_words MACRO
  pop [r14+352]
ENDM
Cmp_stat_minor_words MACRO reg
  cmp reg, [r14+352]
ENDM
Store_stat_promoted_words MACRO reg
  mov [r14+360], reg
ENDM
Load_stat_promoted_words MACRO reg
  mov reg, [r14+360]
ENDM
Push_stat_promoted_words MACRO
  push [r14+360]
ENDM
Pop_stat_promoted_words MACRO
  pop [r14+360]
ENDM
Cmp_stat_promoted_words MACRO reg
  cmp reg, [r14+360]
ENDM
Store_stat_major_words MACRO reg
  mov [r14+368], reg
ENDM
Load_stat_major_words MACRO reg
  mov reg, [r14+368]
ENDM
Push_stat_major_words MACRO
  push [r14+368]
ENDM
Pop_stat_major_words MACRO
  pop [r14+368]
ENDM
Cmp_stat_major_words MACRO reg
  cmp reg, [r14+368]
ENDM
Store_stat_minor_collections MACRO reg
  mov [r14+376], reg
ENDM
Load_stat_minor_collections MACRO reg
  mov reg, [r14+376]
ENDM
Push_stat_minor_collections MACRO
  push [r14+376]
ENDM
Pop_stat_minor_collections MACRO
  pop [r14+376]
ENDM
Cmp_stat_minor_collections MACRO reg
  cmp reg, [r14+376]
ENDM
Store_stat_forced_major_collections MACRO reg
  mov [r14+384], reg
ENDM
Load_stat_forced_major_collections MACRO reg
  mov reg, [r14+384]
ENDM
Push_stat_forced_major_collections MACRO
  push [r14+384]
ENDM
Pop_stat_forced_major_collections MACRO
  pop [r14+384]
ENDM
Cmp_stat_forced_major_collections MACRO reg
  cmp reg, [r14+384]
ENDM
Store_stat_blocks_marked MACRO reg
  mov [r14+392], reg
ENDM
Load_stat_blocks_marked MACRO reg
  mov reg, [r14+392]
ENDM
Push_stat_blocks_marked MACRO
  push [r14+392]
ENDM
Pop_stat_blocks_marked MACRO
  pop [r14+392]
ENDM
Cmp_stat_blocks_marked MACRO reg
  cmp reg, [r14+392]
ENDM
Store_inside_stw_handler MACRO reg
  mov [r14+400], reg
ENDM
Load_inside_stw_handler MACRO reg
  mov reg, [r14+400]
ENDM
Push_inside_stw_handler MACRO
  push [r14+400]
ENDM
Pop_inside_stw_handler MACRO
  pop [r14+400]
ENDM
Cmp_inside_stw_handler MACRO reg
  cmp reg, [r14+400]
ENDM
Store_trap_sp_off MACRO reg
  mov [r14+408], reg
ENDM
Load_trap_sp_off MACRO reg
  mov reg, [r14+408]
ENDM
Push_trap_sp_off MACRO
  push [r14+408]
ENDM
Pop_trap_sp_off MACRO
  pop [r14+408]
ENDM
Cmp_trap_sp_off MACRO reg
  cmp reg, [r14+408]
ENDM
Store_trap_barrier_off MACRO reg
  mov [r14+416], reg
ENDM
Load_trap_barrier_off MACRO reg
  mov reg, [r14+416]
ENDM
Push_trap_barrier_off MACRO
  push [r14+416]
ENDM
Pop_trap_barrier_off MACRO
  pop [r14+416]
ENDM
Cmp_trap_barrier_off MACRO reg
  cmp reg, [r14+416]
ENDM
Store_trap_barrier_block MACRO reg
  mov [r14+424], reg
ENDM
Load_trap_barrier_block MACRO reg
  mov reg, [r14+424]
ENDM
Push_trap_barrier_block MACRO
  push [r14+424]
ENDM
Pop_trap_barrier_block MACRO
  pop [r14+424]
ENDM
Cmp_trap_barrier_block MACRO reg
  cmp reg, [r14+424]
ENDM
Store_external_raise MACRO reg
  mov [r14+432], reg
ENDM
Load_external_raise MACRO reg
  mov reg, [r14+432]
ENDM
Push_external_raise MACRO
  push [r14+432]
ENDM
Pop_external_raise MACRO
  pop [r14+432]
ENDM
Cmp_external_raise MACRO reg
  cmp reg, [r14+432]
ENDM
Store_extra_params MACRO reg
  mov [r14+440], reg
ENDM
Load_extra_params MACRO reg
  mov reg, [r14+440]
ENDM
Push_extra_params MACRO
  push [r14+440]
ENDM
Pop_extra_params MACRO
  pop [r14+440]
ENDM
Cmp_extra_params MACRO reg
  cmp reg, [r14+440]
ENDM
