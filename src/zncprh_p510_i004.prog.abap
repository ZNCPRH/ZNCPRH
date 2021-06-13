*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P510_I004
*&---------------------------------------------------------------------*

FORM create_fieldcat.

  DATA:
    ls_fcat TYPE lvc_s_fcat.

* create field catalog
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'USR02'
    CHANGING
      ct_fieldcat      = gt_fcat.

* hotspot fields
  ls_fcat-hotspot = 'X'.
  MODIFY gt_fcat FROM ls_fcat
    TRANSPORTING hotspot
    WHERE fieldname = 'BNAME'.

* editable column
  ls_fcat-edit = 'X'.
  MODIFY gt_fcat FROM ls_fcat
    TRANSPORTING edit
    WHERE
         fieldname = 'GLTGV'.

* F4 list
  ls_fcat-f4availabl = 'X'.
  MODIFY gt_fcat FROM ls_fcat
    TRANSPORTING f4availabl
    WHERE
         fieldname = 'UFLAG'
      OR fieldname = 'ANAME'.

* dropdown list
  ls_fcat-drdn_hndl = '1'.
  MODIFY gt_fcat FROM ls_fcat
    TRANSPORTING drdn_hndl
    WHERE
         fieldname = 'CLASS'
      OR fieldname = 'LOCNT'.
ENDFORM.                    "create_fieldcat

*&---------------------------------------------------------------------*
*&      Form  field_f4_register
*&---------------------------------------------------------------------*
FORM field_f4_register.

  DATA:
    lt_f4 TYPE lvc_t_f4,
    ls_f4 TYPE lvc_s_f4.

  ls_f4-fieldname  = 'UFLAG'.
  ls_f4-register   = 'X'.
* ls_f4-getbefore  = 'X'.
* ls_f4-chngeafter = 'X'.
  INSERT ls_f4 INTO TABLE lt_f4.

  ls_f4-fieldname  = 'ANAME'.
  ls_f4-register   = 'X'.
* ls_f4-getbefore  = 'X'.
* ls_f4-chngeafter = 'X'.
  INSERT ls_f4 INTO TABLE lt_f4.

  CALL METHOD go_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.
ENDFORM.                    "field_f4_register

*----------------------------------------------------------------------*
*  MODULE pbo_0100 OUTPUT
*----------------------------------------------------------------------*
MODULE pbo_0100 OUTPUT.

* set GUI status
  SET PF-STATUS 'STAT_0100'.

  IF go_custom_container IS INITIAL.

    CREATE OBJECT go_custom_container
      EXPORTING
        container_name = 'CONT1_0100'.

    CREATE OBJECT go_grid
      EXPORTING
        i_appl_events = 'X'
        i_parent      = go_custom_container.

*   create handler
    CREATE OBJECT go_event_receiver.

*   register handler for events
    SET HANDLER go_event_receiver->handle_right_click                FOR go_grid.
    SET HANDLER go_event_receiver->handle_left_click_design          FOR go_grid.
    SET HANDLER go_event_receiver->handle_move_control               FOR go_grid.
    SET HANDLER go_event_receiver->handle_size_control               FOR go_grid.
    SET HANDLER go_event_receiver->handle_left_click_run             FOR go_grid.
    SET HANDLER go_event_receiver->handle_onf1                       FOR go_grid.
    SET HANDLER go_event_receiver->handle_onf4                       FOR go_grid.
    SET HANDLER go_event_receiver->handle_data_changed               FOR go_grid.
    SET HANDLER go_event_receiver->handle_ondropgetflavor            FOR go_grid.
    SET HANDLER go_event_receiver->handle_ondrag                     FOR go_grid.
    SET HANDLER go_event_receiver->handle_ondrop                     FOR go_grid.
    SET HANDLER go_event_receiver->handle_ondropcomplete             FOR go_grid.
    SET HANDLER go_event_receiver->handle_subtotal_text              FOR go_grid.
    SET HANDLER go_event_receiver->handle_before_user_command        FOR go_grid.
    SET HANDLER go_event_receiver->handle_user_command               FOR go_grid.
    SET HANDLER go_event_receiver->handle_after_user_command         FOR go_grid.
    SET HANDLER go_event_receiver->handle_double_click               FOR go_grid.
    SET HANDLER go_event_receiver->handle_delayed_callback           FOR go_grid.
    SET HANDLER go_event_receiver->handle_delayed_changed_sel_cal    FOR go_grid.
    SET HANDLER go_event_receiver->handle_print_top_of_page          FOR go_grid.
    SET HANDLER go_event_receiver->handle_print_top_of_list          FOR go_grid.
    SET HANDLER go_event_receiver->handle_print_end_of_page          FOR go_grid.
    SET HANDLER go_event_receiver->handle_print_end_of_list          FOR go_grid.
    SET HANDLER go_event_receiver->handle_top_of_page                FOR go_grid.
    SET HANDLER go_event_receiver->handle_context_menu_request       FOR go_grid.
    SET HANDLER go_event_receiver->handle_menu_button                FOR go_grid.
    SET HANDLER go_event_receiver->handle_toolbar                    FOR go_grid.
    SET HANDLER go_event_receiver->handle_hotspot_click              FOR go_grid.
    SET HANDLER go_event_receiver->handle_end_of_list                FOR go_grid.
    SET HANDLER go_event_receiver->handle_after_refresh              FOR go_grid.
    SET HANDLER go_event_receiver->handle_button_click               FOR go_grid.
    SET HANDLER go_event_receiver->handle_data_changed_finished      FOR go_grid.

*   create handler for protected events
    CREATE OBJECT go_base_event_receiver.

*   register handler for protected events
    CALL METHOD go_base_event_receiver->set_protected_handlers.

*   register F4 fields
    PERFORM field_f4_register.

*   register extra events for edit mode
*   - events DATA_CHANGED and DATA_CHANGED_FINISHED are called, when:

*   ENTER key is pressed or
    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

*   data is changed and cursor is moved from the cell
    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

*   display table
    CALL METHOD go_grid->set_table_for_first_display
      CHANGING
        it_fieldcatalog = gt_fcat
        it_outtab       = gt_usr.
  ENDIF.
ENDMODULE.                    "pbo_0100 OUTPUT

*----------------------------------------------------------------------*
*  MODULE pai_0100 INPUT
*----------------------------------------------------------------------*
MODULE pai_0100 INPUT.

  BREAK-POINT.

* to react on custom events:
  CALL METHOD cl_gui_cfw=>dispatch.

  BREAK-POINT.

  CASE ok_code.

    WHEN 'EXIT'.
      LEAVE PROGRAM.

    WHEN 'SAVE'.
*     force ALV to copy the data from grid to the internal table
*     (events DATA_CHANGED and DATA_CHANGED_FINISHED will be fired)
      CALL METHOD go_grid->check_changed_data.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                    "pai_0100 INPUT
