*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P510_I003
*&---------------------------------------------------------------------*
CLASS cl_base_event_receiver DEFINITION INHERITING FROM cl_gui_alv_grid_base.

  PUBLIC SECTION.

    METHODS set_protected_handlers.

  PROTECTED SECTION.

    METHODS handle_toolbar_menubutton_clk     " TOOLBAR_MENUBUTTON_CLICK
        FOR EVENT toolbar_menubutton_click OF cl_gui_alv_grid_base.

    METHODS handle_click_col_header             " CLICK_COL_HEADER
        FOR EVENT click_col_header OF cl_gui_alv_grid_base
      IMPORTING
        col_id.

    METHODS handle_delayed_move_curr_cell    " DELAYED_MOVE_CURRENT_CELL
        FOR EVENT delayed_move_current_cell OF cl_gui_alv_grid_base.

    METHODS handle_f1                           " F1
        FOR EVENT f1 OF cl_gui_alv_grid_base.

    METHODS handle_dblclick_row_col             " DBLCLICK_ROW_COL
        FOR EVENT dblclick_row_col OF cl_gui_alv_grid_base
      IMPORTING
        row_id
        col_id.

    METHODS handle_click_row_col                " CLICK_ROW_COL
        FOR EVENT click_row_col OF cl_gui_alv_grid_base
      IMPORTING
        row_id
        col_id.

    METHODS handle_toolbar_button_click         " TOOLBAR_BUTTON_CLICK
        FOR EVENT toolbar_button_click OF cl_gui_alv_grid_base.

    METHODS handle_double_click_col_sep   " DOUBLE_CLICK_COL_SEPARATOR
        FOR EVENT double_click_col_separator OF cl_gui_alv_grid_base
      IMPORTING
        col_id.

    METHODS handle_delayed_change_select     " DELAYED_CHANGE_SELECTION
        FOR EVENT delayed_change_selection OF cl_gui_alv_grid_base.

    METHODS handle_context_menu                 " CONTEXT_MENU
        FOR EVENT context_menu OF cl_gui_alv_grid_base.

    METHODS handle_total_click_row_col          " TOTAL_CLICK_ROW_COL
        FOR EVENT total_click_row_col OF cl_gui_alv_grid_base
      IMPORTING
        row_id
        col_id.

    METHODS handle_context_menu_selected        " CONTEXT_MENU_SELECTED
        FOR EVENT context_menu_selected  OF cl_gui_alv_grid_base
      IMPORTING
        fcode.

    METHODS handle_toolbar_menu_selected        " TOOLBAR_MENU_SELECTED
        FOR EVENT toolbar_menu_selected OF cl_gui_alv_grid_base
      IMPORTING
        fcode.

ENDCLASS.                    "cl_base_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_base_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cl_base_event_receiver IMPLEMENTATION.

  METHOD set_protected_handlers.
    SET HANDLER me->handle_toolbar_menubutton_clk     FOR go_grid.
    SET HANDLER me->handle_click_col_header           FOR go_grid.
    SET HANDLER me->handle_delayed_move_curr_cell     FOR go_grid.
    SET HANDLER me->handle_f1                         FOR go_grid.
    SET HANDLER me->handle_dblclick_row_col           FOR go_grid.
    SET HANDLER me->handle_click_row_col              FOR go_grid.
    SET HANDLER me->handle_toolbar_button_click       FOR go_grid.
    SET HANDLER me->handle_double_click_col_sep       FOR go_grid.
    SET HANDLER me->handle_delayed_change_select      FOR go_grid.
    SET HANDLER me->handle_context_menu               FOR go_grid.
    SET HANDLER me->handle_total_click_row_col        FOR go_grid.
    SET HANDLER me->handle_context_menu_selected      FOR go_grid.
    SET HANDLER me->handle_toolbar_menu_selected      FOR go_grid.
  ENDMETHOD.                    "set_protected_handlers

  METHOD handle_toolbar_menubutton_clk.
    BREAK-POINT.
  ENDMETHOD.                    "handle_toolbar_menubutton_clk

  METHOD handle_click_col_header.
    BREAK-POINT.
  ENDMETHOD.                    "handle_click_col_header

  METHOD handle_delayed_move_curr_cell.
    BREAK-POINT.
  ENDMETHOD.                    "handle_delayed_move_curr_cell

  METHOD handle_f1.
    BREAK-POINT.
  ENDMETHOD.                                                "handle_f1

  METHOD handle_dblclick_row_col.
    BREAK-POINT.
  ENDMETHOD.                    "handle_dblclick_row_col

  METHOD handle_click_row_col.
    BREAK-POINT.
  ENDMETHOD.                    "handle_click_row_col

  METHOD handle_toolbar_button_click.
    BREAK-POINT.
  ENDMETHOD.                    "handle_toolbar_button_click

  METHOD handle_double_click_col_sep.
    BREAK-POINT.
  ENDMETHOD.                    "handle_double_click_col_sep

  METHOD handle_delayed_change_select.
    BREAK-POINT.
  ENDMETHOD.                    "handle_delayed_change_select

  METHOD handle_context_menu.
    BREAK-POINT.
  ENDMETHOD.                    "handle_context_menu

  METHOD handle_total_click_row_col.
    BREAK-POINT.
  ENDMETHOD.                    "handle_total_click_row_col

  METHOD handle_context_menu_selected.
    BREAK-POINT.
  ENDMETHOD.                    "handle_context_menu_selected

  METHOD handle_toolbar_menu_selected.
    BREAK-POINT.
  ENDMETHOD.                    "handle_toolbar_menu_selected

ENDCLASS.                    "cl_base_event_receiver IMPLEMENTATION
