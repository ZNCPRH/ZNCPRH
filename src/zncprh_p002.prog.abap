*&---------------------------------------------------------------------*
*& Report ZNCPRH_P002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p002.

TABLES : pa0001 , t591s , pa0002.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
SELECT-OPTIONS : s_pernr FOR pa0001-pernr,
                 s_vorna FOR pa0002-vorna ,
                 s_nachn FOR pa0002-nachn ,
                 s_persk FOR pa0001-persk .

PARAMETERS p_infty TYPE t591s-infty DEFAULT '0105' NO-DISPLAY.
PARAMETERS p_field TYPE fieldname DEFAULT 'USRID' NO-DISPLAY.
PARAMETERS p_lfield TYPE fieldname DEFAULT 'USRID_LONG' NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK b1.


*--------------------------------------------------------------------*
DATA : gs_alv   TYPE zncprh_s013.

FIELD-SYMBOLS : <table>          TYPE table,
                <ft_gen_data>    TYPE table,
                <ft_table_pernr> TYPE table,
                <field1>         TYPE any,
                <wa>             TYPE any,
                <fs_line>        TYPE any.
DATA : l_alv    TYPE REF TO data,
       lv_field TYPE fieldname.
DATA:  o_ref TYPE REF TO data.
DATA: gv_strname TYPE tabname VALUE 'ZNCPRH_S013'.
DATA: gt_fcat TYPE lvc_t_fcat.

*--------------------------------------------------------------------*

START-OF-SELECTION.

  SELECT  * FROM t591s INTO TABLE @DATA(lt_591s)
     WHERE infty = @p_infty AND sprsl = 'T'.

  CHECK sy-subrc EQ 0.


  SORT  lt_591s BY subty.
  DATA(lv_tabname) = 'PA' && p_infty.
  CREATE DATA o_ref TYPE TABLE OF (lv_tabname).

  ASSIGN p_field TO <field1>.
  ASSIGN o_ref->* TO <ft_gen_data> .


  SELECT * FROM zncprh_ddl001 INTO TABLE @DATA(lt_007)
        WHERE pernr IN @s_pernr
        AND   vorna IN @s_vorna
        AND   nachn IN @s_nachn
        AND   persk IN @s_persk
        AND pernr NOT IN
    ( SELECT pernr FROM pa0000 WHERE endda > @sy-datum  AND massn = '10' ).



  SELECT * "pernr , p_field , p_lfield
   INTO CORRESPONDING FIELDS OF TABLE @<ft_gen_data>
    FROM (lv_tabname) WHERE pernr IN @s_pernr AND endda >= @sy-datum.


  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     i_buffer_active        =     " Buffer active
      i_structure_name       = gv_strname   " Structure name (structure, table, view)
*     i_client_never_display = 'X'    " Hide client fields
*     i_bypassing_buffer     =     " Ignore buffer while reading
*     i_internal_tabname     =     " Table Name
    CHANGING
      ct_fieldcat            = gt_fcat    " Field Catalog with Field Descriptions
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  DATA ls_fcat LIKE LINE OF gt_fcat.

  LOOP AT lt_591s
        INTO DATA(ls_customizing)
       WHERE stext NE ' '.

    ls_fcat-col_pos   = lines( gt_fcat ) + 1.
    ls_fcat-fieldname = |P_{ ls_customizing-subty }|.
    ls_fcat-tabname   = 1.
    ls_fcat-scrtext_s =
    ls_fcat-scrtext_m =
    ls_fcat-scrtext_l =
    ls_fcat-reptext   = |{ ls_customizing-stext }|.

*  IF i_inttype IS NOT INITIAL.
    ls_fcat-inttype = 'C'.
*    ls_fcat-inttype = i_inttype.
*  ENDIF.


*  IF i_intlen IS NOT INITIAL.
*    ls_fcat-intlen = i_intlen.
    ls_fcat-intlen = 50.
*  ENDIF.

*  IF i_datatype IS NOT INITIAL.
*    ls_fcat-datatype = i_datatype.
    ls_fcat-datatype = 'CHAR'.
*  ENDIF.


*
*  IF i_sum EQ 'X'.
*    ls_fcat-do_sum = i_sum.
*  ENDIF.
*
*  IF i_hotspot = 'X'.
*    ls_fcat-hotspot = i_hotspot.
*  ENDIF.

    APPEND ls_fcat
        TO gt_fcat.
    CLEAR ls_fcat.
  ENDLOOP.

  DATA(l_dynamic) = zncprh_cl005=>create( gt_fcat ).

  DATA(rt_table) = l_dynamic->create_table( ).
  l_dynamic->free( ).

  IF rt_table IS NOT INITIAL.
    ASSIGN rt_table->* TO <table>.
    CHECK sy-subrc EQ 0.
  ENDIF.

  LOOP AT lt_007 INTO DATA(ls_007).
    DATA(lv_tabix) = sy-tabix.

    APPEND INITIAL LINE TO <table> ASSIGNING FIELD-SYMBOL(<fs_table>).
    <fs_table> = CORRESPONDING #( ls_007 ).

    LOOP AT lt_591s INTO DATA(ls_591s) WHERE infty = p_infty.
      ASSIGN COMPONENT |P_{ ls_591s-subty }|  OF STRUCTURE <fs_table>
                      TO FIELD-SYMBOL(<f_value>)."Short
      CHECK <f_value> IS ASSIGNED.
      DATA(lv_where) = | pernr = '{ ls_007-pernr }' and subty = '{ ls_591s-subty }' |.

      LOOP AT  <ft_gen_data> ASSIGNING <fs_line> WHERE (lv_where)  .
        ASSIGN COMPONENT p_lfield OF STRUCTURE <fs_line> TO FIELD-SYMBOL(<fs_lusrid>)."Length
        IF  <fs_lusrid> IS ASSIGNED.
          IF <fs_lusrid> IS NOT INITIAL.
            <f_value> = <fs_lusrid>.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT p_field  OF STRUCTURE <fs_line> TO FIELD-SYMBOL(<fs_susrid>)."Short
        IF <fs_susrid> IS ASSIGNED AND <f_value> IS INITIAL.
          <f_value> = <fs_susrid>.
        ENDIF.

        UNASSIGN  : <fs_lusrid> , <fs_susrid>. ", <f_value>.
      ENDLOOP.

    ENDLOOP.
  ENDLOOP.

  BREAK p1362.
