*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P510_I002
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS cl_event_receiver DEFINITION
*----------------------------------------------------------------------*
CLASS cl_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS handle_right_click                  " RIGHT_CLICK
      FOR EVENT right_click OF cl_gui_alv_grid.

    METHODS handle_left_click_design            " LEFT_CLICK_DESIGN
      FOR EVENT left_click_design OF cl_gui_alv_grid.

    METHODS handle_move_control                 " MOVE_CONTROL
      FOR EVENT move_control OF cl_gui_alv_grid.

    METHODS handle_size_control                 " SIZE_CONTROL
      FOR EVENT size_control OF cl_gui_alv_grid.

    METHODS handle_left_click_run               " LEFT_CLICK_RUN
      FOR EVENT left_click_run OF cl_gui_alv_grid.

    METHODS handle_onf1                                     " ONF1
      FOR EVENT onf1 OF cl_gui_alv_grid
        IMPORTING
          e_fieldname
          es_row_no
          er_event_data.

    METHODS handle_onf4                                     " ONF4
      FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING
          e_fieldname
          e_fieldvalue
          es_row_no
          er_event_data
          et_bad_cells
          e_display.

    METHODS handle_data_changed                 " DATA_CHANGED
      FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed
          e_onf4
          e_onf4_before
          e_onf4_after
          e_ucomm.

    METHODS handle_ondropgetflavor              " ONDROPGETFLAVOR
      FOR EVENT ondropgetflavor OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          e_dragdropobj
          e_flavors.

    METHODS handle_ondrag                       " ONDRAG
      FOR EVENT ondrag OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          e_dragdropobj.

    METHODS handle_ondrop                       " ONDROP
      FOR EVENT ondrop OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          e_dragdropobj.

    METHODS handle_ondropcomplete               " ONDROPCOMPLETE
      FOR EVENT ondropcomplete OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          e_dragdropobj.

    METHODS handle_subtotal_text                " SUBTOTAL_TEXT
      FOR EVENT subtotal_text OF cl_gui_alv_grid
        IMPORTING
          es_subtottxt_info
          ep_subtot_line
          e_event_data.

    METHODS handle_before_user_command          " BEFORE_USER_COMMAND
      FOR EVENT before_user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm.

    METHODS handle_user_command                 " USER_COMMAND
      FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm.

    METHODS handle_after_user_command           " AFTER_USER_COMMAND
      FOR EVENT after_user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm
          e_not_processed.

    METHODS handle_double_click                 " DOUBLE_CLICK
      FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no.

    METHODS handle_delayed_callback             " DELAYED_CALLBACK
      FOR EVENT delayed_callback OF cl_gui_alv_grid.

    METHODS handle_delayed_changed_sel_cal " DELAYED_CHANGED_SEL_CALLBACK
      FOR EVENT delayed_changed_sel_callback OF cl_gui_alv_grid.

    METHODS handle_print_top_of_page            " PRINT_TOP_OF_PAGE
      FOR EVENT print_top_of_page OF cl_gui_alv_grid
        IMPORTING
          table_index.

    METHODS handle_print_top_of_list            " PRINT_TOP_OF_LIST
      FOR EVENT print_top_of_list OF cl_gui_alv_grid.

    METHODS handle_print_end_of_page            " PRINT_END_OF_PAGE
      FOR EVENT print_end_of_page OF cl_gui_alv_grid.

    METHODS handle_print_end_of_list            " PRINT_END_OF_LIST
      FOR EVENT print_end_of_list OF cl_gui_alv_grid.

    METHODS handle_top_of_page                  " TOP_OF_PAGE
      FOR EVENT top_of_page OF cl_gui_alv_grid
        IMPORTING
          e_dyndoc_id
          table_index.

    METHODS handle_context_menu_request         " CONTEXT_MENU_REQUEST
      FOR EVENT context_menu_request OF cl_gui_alv_grid
        IMPORTING
          e_object.

    METHODS handle_menu_button                  " MENU_BUTTON
      FOR EVENT menu_button OF cl_gui_alv_grid
        IMPORTING
          e_object
          e_ucomm.

    METHODS handle_toolbar                      " TOOLBAR
      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING
          e_object
          e_interactive.

    METHODS handle_hotspot_click                " HOTSPOT_CLICK
      FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING
          e_row_id
          e_column_id.

    METHODS handle_end_of_list                  " END_OF_LIST
      FOR EVENT end_of_list OF cl_gui_alv_grid
        IMPORTING
          e_dyndoc_id.

    METHODS handle_after_refresh                " AFTER_REFRESH
      FOR EVENT after_refresh OF cl_gui_alv_grid.

    METHODS handle_button_click                 " BUTTON_CLICK
      FOR EVENT button_click OF cl_gui_alv_grid
        IMPORTING
          es_col_id
          es_row_no.

    METHODS handle_data_changed_finished        " DATA_CHANGED_FINISHED
      FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING
          e_modified
          et_good_cells.

ENDCLASS.                    "cl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cl_event_receiver IMPLEMENTATION.

  METHOD handle_right_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_right_click

  METHOD handle_left_click_design.
    BREAK-POINT.
  ENDMETHOD.                    "handle_left_click_design

  METHOD handle_move_control.
    BREAK-POINT.
  ENDMETHOD.                    "handle_move_control

  METHOD handle_size_control.
    BREAK-POINT.
  ENDMETHOD.                    "handle_size_control

  METHOD handle_left_click_run.
    BREAK-POINT.
  ENDMETHOD.                    "handle_left_click_run

  METHOD handle_onf1.
    BREAK-POINT.
  ENDMETHOD.                    "handle_onf1

  METHOD handle_onf4.
    BREAK-POINT.
  ENDMETHOD.                    "handle_onf4

  METHOD handle_data_changed.
    BREAK-POINT.
  ENDMETHOD.                    "handle_data_changed

  METHOD handle_ondropgetflavor.
    BREAK-POINT.
  ENDMETHOD.                    "handle_ondropgetflavor

  METHOD handle_ondrag.
    BREAK-POINT.
  ENDMETHOD.                    "handle_ondrag

  METHOD handle_ondrop.
    BREAK-POINT.
  ENDMETHOD.                    "handle_ondrop

  METHOD handle_ondropcomplete.
    BREAK-POINT.
  ENDMETHOD.                    "handle_ondropcomplete

  METHOD handle_subtotal_text.
    BREAK-POINT.
  ENDMETHOD.                    "handle_subtotal_text

  METHOD handle_before_user_command.
    BREAK-POINT.
  ENDMETHOD.                    "handle_before_user_command

  METHOD handle_user_command.
    BREAK-POINT.
  ENDMETHOD.                    "handle_user_command

  METHOD handle_after_user_command.
    BREAK-POINT.
  ENDMETHOD.                    "handle_after_user_command

  METHOD handle_double_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_double_click

  METHOD handle_delayed_callback.
    BREAK-POINT.
  ENDMETHOD.                    "handle_delayed_callback

  METHOD handle_delayed_changed_sel_cal.
    BREAK-POINT.
  ENDMETHOD.                    "handle_delayed_changed_sel_cal

  METHOD handle_print_top_of_page.
    BREAK-POINT.
  ENDMETHOD.                    "handle_print_top_of_page

  METHOD handle_print_top_of_list.
    BREAK-POINT.
  ENDMETHOD.                    "handle_print_top_of_list

  METHOD handle_print_end_of_page.
    BREAK-POINT.
  ENDMETHOD.                    "handle_print_end_of_page

  METHOD handle_print_end_of_list.
    BREAK-POINT.
  ENDMETHOD.                    "handle_print_end_of_list

  METHOD handle_top_of_page.
    BREAK-POINT.
  ENDMETHOD.                    "handle_top_of_page

  METHOD handle_context_menu_request.
    BREAK-POINT.
  ENDMETHOD.                    "handle_context_menu_request

  METHOD handle_menu_button.
    BREAK-POINT.
  ENDMETHOD.                    "handle_menu_button

  METHOD handle_toolbar.
    BREAK-POINT.
  ENDMETHOD.                    "handle_toolbar

  METHOD handle_hotspot_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD handle_end_of_list.
    BREAK-POINT.
  ENDMETHOD.                    "handle_end_of_list

  METHOD handle_after_refresh.
    BREAK-POINT.
  ENDMETHOD.                    "handle_after_refresh

  METHOD handle_button_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_button_click

  METHOD handle_data_changed_finished.
    BREAK-POINT.
  ENDMETHOD.                    "handle_data_changed_finished

ENDCLASS.                    "cl_event_receiver IMPLEMENTATION
