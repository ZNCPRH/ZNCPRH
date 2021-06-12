*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P035_I002
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       CLASS lcl_eventhandler DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_eventhandler DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA:
      ms_row TYPE lvc_s_row,
      ms_col TYPE lvc_s_col.

    CLASS-METHODS:
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no
          sender,
      init_controls,
      set_layout_and_variant,
      get_data,
      link_container,
      customer_show_details,
      toggle_display.
ENDCLASS.                    "lcl_eventhandler DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_eventhandler IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_eventhandler IMPLEMENTATION.
  METHOD get_data.
    SELECT  * FROM  knb1 INTO TABLE gt_outtab1.
  ENDMETHOD.
  METHOD link_container.
* link the docking container to the target dynpro
    gd_repid = syst-repid.
    CALL METHOD go_docking1->link
      EXPORTING
        repid  = gd_repid
        dynnr  = '0100'
*       CONTAINER                   =
      EXCEPTIONS
        OTHERS = 4.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDMETHOD.
  METHOD init_controls.
    "* Create docking container
    CREATE OBJECT go_docking1
      EXPORTING
        parent = cl_gui_container=>screen0
        side   = cl_gui_docking_container=>dock_at_left
        ratio  = 45
      EXCEPTIONS
        OTHERS = 6.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


* Create docking container
    CREATE OBJECT go_docking2
      EXPORTING
        parent = cl_gui_container=>screen0
*       side   = cl_gui_docking_container=>dock_at_top
        side   = cl_gui_docking_container=>dock_at_left
        ratio  = 90
      EXCEPTIONS
        OTHERS = 6.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


* Create ALV grids
    CREATE OBJECT go_grid1
      EXPORTING
        i_parent = go_docking1
      EXCEPTIONS
        OTHERS   = 5.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CREATE OBJECT go_grid2
      EXPORTING
        i_parent = go_docking2
      EXCEPTIONS
        OTHERS   = 5.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


* Set event handler
    SET HANDLER:
      lcl_eventhandler=>handle_double_click FOR go_grid1.

    set_layout_and_variant( ).

    " Display data
    CALL METHOD go_grid1->set_table_for_first_display
      EXPORTING
        i_structure_name = 'KNB1'
        is_layout        = gs_layout1
        is_variant       = gs_variant1
        i_save           = 'A'
      CHANGING
        it_outtab        = gt_outtab1
      EXCEPTIONS
        OTHERS           = 4.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CALL METHOD go_grid2->set_table_for_first_display
      EXPORTING
        i_structure_name = 'KNVV'
        is_layout        = gs_layout2
        is_variant       = gs_variant2
        i_save           = 'A'
      CHANGING
        it_outtab        = gt_outtab2  " empty !!!
      EXCEPTIONS
        OTHERS           = 4.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDMETHOD.
  METHOD set_layout_and_variant.
    CLEAR: gs_layout1,
        gs_layout2.
    CLEAR: gs_variant1,
           gs_variant2.

    gs_layout1-grid_title = 'Customers'.
    gs_layout1-cwidth_opt = abap_true.
    gs_layout1-zebra      = abap_true.
*
    gs_layout2-grid_title = 'Sales Areas'.
    gs_layout2-cwidth_opt = abap_true.
    gs_layout2-zebra      = abap_true.

    gs_variant1-report = syst-repid.
    gs_variant1-handle = 'GRD1'.
*
    gs_variant2-report = syst-repid.
    gs_variant2-handle = 'GRD2'.
  ENDMETHOD.
  METHOD handle_double_click.
*   define local data
    DATA:
      ls_knb1      TYPE knb1.

    CLEAR: ms_row,
           ms_col.

    ms_row = e_row.
    ms_col = e_column.

*   Triggers PAI of the dynpro with the specified ok-code
    CALL METHOD cl_gui_cfw=>set_new_ok_code( 'DETAIL' ).
    RETURN.

    " Version for SAP release 4.6
    CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
        new_code = 'DETAIL'
*      IMPORTING
*       rc       =
      .
  ENDMETHOD.                    "handle_double_click
  METHOD customer_show_details.
    DATA:
      ld_row     TYPE i,
      ls_outtab1 LIKE LINE OF gt_outtab1.

    READ TABLE gt_outtab1 INTO ls_outtab1
                          INDEX lcl_eventhandler=>ms_row-index.
    CHECK ( syst-subrc = 0 ).

    SELECT * FROM  knvv INTO TABLE gt_outtab2
           WHERE  kunnr  = ls_outtab1-kunnr.

    " Link 2nd docking container again to main screen
    CALL METHOD go_docking2->link
      EXPORTING
        repid  = gd_repid
        dynnr  = '0100'
*       CONTAINER                   =
      EXCEPTIONS
        OTHERS = 4.
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDMETHOD.
  METHOD toggle_display.
    "* define local data
    DATA: ls_linkinfo   TYPE cfw_link.

    ls_linkinfo = go_docking2->get_link_info( ).

    CASE ls_linkinfo-dynnr.
        " 2nd ALV visible -> hide
      WHEN '0100'.
        CALL METHOD go_docking2->link
          EXPORTING
            repid  = gd_repid
            dynnr  = '0101'  " <<< !!!
*           CONTAINER                   =
          EXCEPTIONS
            OTHERS = 4.
        IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        " 2nd ALV hidden -> display
      WHEN '0101'.
        CALL METHOD go_docking2->link
          EXPORTING
            repid  = gd_repid
            dynnr  = '0100'  " <<< !!!
*           CONTAINER                   =
          EXCEPTIONS
            OTHERS = 4.
        IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.                    "lcl_eventhandler IMPLEMENTATION
