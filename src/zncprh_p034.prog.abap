*&---------------------------------------------------------------------*
*& Report ZNCPRH_P034
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p034.

TABLES:pa0000,pa0002,pa0022.


DATA : gt_per   TYPE TABLE OF zncprh_s028,
       gs_per   TYPE zncprh_s028,
       gt_egtm  TYPE TABLE OF zncprh_s029,
       gt_egtm2 TYPE TABLE OF zncprh_s029,
       gs_egtm  TYPE zncprh_s029,
       gs_egtm2 TYPE zncprh_s029,

       gt_fcat  TYPE lvc_t_fcat,
       gs_fcat  TYPE lvc_s_fcat,

       o_cust   TYPE REF TO cl_gui_custom_container,
       o_spli   TYPE REF TO cl_gui_splitter_container,
       o_spli2  TYPE REF TO cl_gui_splitter_container,
       o_ref1   TYPE REF TO cl_gui_container,
       o_ref2   TYPE REF TO cl_gui_container,
       o_ref3   TYPE REF TO cl_gui_container,
       o_alv1   TYPE REF TO cl_gui_alv_grid,
       o_alv2   TYPE REF TO cl_gui_alv_grid,
       o_alv3   TYPE REF TO cl_gui_alv_grid,
       gv_row   TYPE lvc_s_row.

CLASS handle_event DEFINITION.
  PUBLIC SECTION.

    CLASS-METHODS handle_double_click
                FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row sender.

ENDCLASS.

DATA obj TYPE REF TO handle_event.

CLASS handle_event IMPLEMENTATION.
  METHOD handle_double_click.

    gv_row = e_row.

    CASE sender.

      WHEN o_alv1.

        READ TABLE  gt_per INTO gs_per INDEX gv_row.
        SELECT * FROM pa0022 AS p1 INNER JOIN pa0002 AS p2 ON p1~pernr EQ p2~pernr
          INTO CORRESPONDING FIELDS OF TABLE gt_egtm
            WHERE p1~pernr EQ gs_per-pernr.

        PERFORM o_alv2.

        CLEAR gt_egtm2.

        PERFORM o_alv3.

      WHEN o_alv2.

        READ TABLE  gt_egtm INTO gs_egtm INDEX gv_row.
        SELECT * FROM pa0022 AS p1 INNER JOIN pa0002 AS p2 ON p1~pernr EQ p2~pernr
          INTO CORRESPONDING FIELDS OF TABLE gt_egtm2
            WHERE insti EQ gs_egtm-insti.

        PERFORM o_alv3.

    ENDCASE.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  PERFORM get_data.
  CALL SCREEN 0100.

FORM get_data.

  SELECT * FROM pa0022 INTO CORRESPONDING FIELDS OF TABLE gt_egtm.

  MOVE gt_egtm TO gt_egtm2.

  SELECT DISTINCT * FROM pa0002 INTO CORRESPONDING FIELDS OF TABLE gt_per ORDER BY pernr.


ENDFORM.



*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_001'.

  CREATE OBJECT o_cust
    EXPORTING
      container_name = 'CONT'.


  CREATE OBJECT o_spli
    EXPORTING
      parent  = o_cust
      rows    = 1
      columns = 2.

  CALL METHOD o_spli->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = o_ref1.

  CALL METHOD o_spli->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = o_ref2.

  CREATE OBJECT o_spli2
    EXPORTING
      parent  = o_ref2
      rows    = 2
      columns = 1.


  CALL METHOD o_spli2->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = o_ref2.

  CALL METHOD o_spli2->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = o_ref3.



  CREATE OBJECT o_alv1
    EXPORTING
      i_parent = o_ref1.


  CALL METHOD o_alv1->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZNCPRH_S028'
    CHANGING
      it_outtab        = gt_per.

  CREATE OBJECT obj.
  SET HANDLER obj->handle_double_click FOR o_alv1.



ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CALL METHOD cl_gui_cfw=>dispatch.

  CASE sy-ucomm.
    WHEN '&F03'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT


FORM o_alv2 .
  CREATE OBJECT o_cust
    EXPORTING
      container_name = 'CONT'.

  IF o_alv2 IS INITIAL.
    CREATE OBJECT o_alv2
      EXPORTING
        i_parent = o_ref2.
    CALL METHOD o_alv2->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZNCPRH_S029'
        i_default        = 'X'
      CHANGING
        it_outtab        = gt_egtm.
  ELSE.
    o_alv2->refresh_table_display( ).

  ENDIF.

  SET HANDLER obj->handle_double_click FOR o_alv2.
ENDFORM.


FORM o_alv3 .
  CREATE OBJECT o_cust
    EXPORTING
      container_name = 'CONT'.

  IF o_alv3 IS INITIAL.
    CREATE OBJECT o_alv3
      EXPORTING
        i_parent = o_ref3.
    CALL METHOD o_alv3->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZNCPRH_S029'
      CHANGING
        it_outtab        = gt_egtm2.
  ELSE.
    o_alv3->refresh_table_display( ).

  ENDIF.

ENDFORM.
