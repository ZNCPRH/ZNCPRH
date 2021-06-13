*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P053_I002
*&---------------------------------------------------------------------*
CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    DATA: gc_alvgrid   TYPE REF TO cl_gui_alv_grid,
          gc_container TYPE REF TO cl_gui_custom_container.

    METHODS:
      get_data,
      display_alv
        IMPORTING iv_tabnam   TYPE string
                  iv_strucnam TYPE string
                  iv_layout   TYPE lvc_s_layo
                  it_exclude  TYPE ui_functions,
      container_alv       IMPORTING iv_tabnam   TYPE string
                                    iv_strucnam TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS :
      alv_initialization  IMPORTING iv_tabnam   TYPE string
                                    iv_strucnam TYPE string,
      create_layout       RETURNING VALUE(ch_layout)  TYPE lvc_s_layo,
      modify_fcat         IMPORTING iv_strucnam    TYPE string
                          RETURNING VALUE(rt_fcat) TYPE lvc_t_fcat,
      create_alv_from_container,
      exclude_tb_functions CHANGING ct_exc TYPE ui_functions,
      set_container_alv_properties,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      handle_toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed e_ucomm,
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no,
      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no sender,
      handle_top_of_page  FOR EVENT top_of_page OF cl_gui_alv_grid
        IMPORTING e_dyndoc_id table_index,
      get_selected_rows   EXPORTING VALUE(rv_subrc) TYPE syst-subrc
                          RETURNING VALUE(rt_rows)  TYPE lvc_t_row,
      close_and_show_log  IMPORTING iv_matnr  TYPE mara-matnr
                                    is_handle TYPE balloghndl,
      open_log            RETURNING VALUE(rs_handle) TYPE balloghndl,
      add_log_data        IMPORTING i_type       TYPE bapiret2-type
                                    i_id         TYPE bapiret2-id
                                    i_number     TYPE bapiret2-number
                                    i_message_v1 TYPE bapiret2-message_v1
                                    i_message_v2 TYPE bapiret2-message_v2
                                    i_message_v3 TYPE bapiret2-message_v3
                                    i_message_v4 TYPE bapiret2-message_v4
                                    is_handle    TYPE balloghndl,
      refresh_table.

ENDCLASS.
