*&---------------------------------------------------------------------*
*& Report ZNCPRH_P023
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p023.

CLASS lcl_class DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS : get_fix_table IMPORTING i_tab          TYPE any
                                            i_col          TYPE any
                                            i_cond         TYPE any OPTIONAL
                                  RETURNING VALUE(rt_data) TYPE REF TO data.

ENDCLASS.

CLASS  lcl_class IMPLEMENTATION.
  METHOD get_fix_table.
    DATA lv_column TYPE string.
    DATA: lt_fcat TYPE STANDARD TABLE OF  lvc_s_fcat,
          ls_fcat TYPE  lvc_s_fcat.

    FIELD-SYMBOLS <fs_table> TYPE ANY TABLE.

    DATA: BEGIN OF ls_p,
            p TYPE char50,
          END OF ls_p,
          lt_p LIKE TABLE OF  ls_p,
          ls_a LIKE           ls_p,
          lt_a LIKE TABLE OF  ls_p.

    DATA lo_data TYPE REF TO data.
    DATA lv_str TYPE string.
    SPLIT i_col AT ',' INTO TABLE lt_p.
    LOOP AT lt_p INTO ls_p .
      REFRESH lt_a.
      CLEAR ls_a.
      SPLIT ls_p-p AT space INTO TABLE lt_a.
      IF lines( lt_a ) EQ 3 .
        READ TABLE lt_a INTO ls_a INDEX 3.
        ls_fcat-fieldname  = ls_a-p.
        ls_fcat-ref_field  = ls_a-p.
        ls_fcat-ref_table  = 'ZNCPRH_S019'.
      ELSE.
        ls_fcat-fieldname  = ls_p-p.
        ls_fcat-ref_field  = ls_p-p.
        ls_fcat-ref_table  = i_tab.
      ENDIF.

      APPEND ls_fcat TO lt_fcat.
      CLEAR ls_fcat.

      CONCATENATE lv_column ls_p-p INTO  lv_column SEPARATED BY space.
    ENDLOOP.
    IF sy-subrc NE 0.
      ls_fcat-fieldname  = i_col.
      ls_fcat-ref_field  = i_col.
      ls_fcat-ref_table  = i_tab.
      APPEND ls_fcat TO lt_fcat.
      CLEAR ls_fcat.
    ENDIF.

    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog           = lt_fcat
      IMPORTING
        ep_table                  = rt_data
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.

    ASSIGN rt_data->* TO <fs_table>.

    CHECK i_tab   IS NOT INITIAL AND
          lv_column   IS NOT INITIAL.
    SELECT (lv_column) FROM (i_tab)
      INTO TABLE <fs_table>
       WHERE (i_cond).
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  DATA lo_data TYPE REF TO data.
  FIELD-SYMBOLS : <fs_table> TYPE ANY TABLE.

  lo_data =  lcl_class=>get_fix_table(
               EXPORTING
                 i_tab   = 'T001P'
                 i_col   = 'WERKS,BTRTL,BTEXT'
                 i_cond  = 'MOLGA EQ 47'
           ).

  ASSIGN lo_data->* TO <fs_table>.

  FREE lo_data.
  UNASSIGN <fs_table>.



  lo_data = lcl_class=>get_fix_table(
     i_tab   = 'T500P'
     i_col   = 'PERSA AS KEY,NAME1 AS VALUE' ).
  ASSIGN lo_data->* TO <fs_table>.


  BREAK-POINT.
