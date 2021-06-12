*&---------------------------------------------------------------------*
*& Report ZNCPRH_P022
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p022.

CLASS test DEFINITION.
  PUBLIC SECTION.
    TYPES   : tt_fieldtab TYPE TABLE OF dfies.
    TYPES   : tt_rettab   TYPE TABLE OF ddshretval.
    METHODS:f4_request            IMPORTING im_retfield  TYPE fieldname
                                            im_dynfield  TYPE dynfnam
                                            im_mark      TYPE ddshmarks
                                  CHANGING  ch_fieldtab  TYPE tt_fieldtab OPTIONAL
                                            ch_valuetab  TYPE STANDARD TABLE
                                            ch_returntab TYPE tt_rettab,


      field_info_get         IMPORTING im_tabname    TYPE ddobjname
                                       im_fieldname  TYPE fieldname
                                       im_lfieldname TYPE fnam_____4
                             CHANGING  ch_data       TYPE dfies.

ENDCLASS.

CLASS test IMPLEMENTATION.
  METHOD f4_request.
    DATA lv_reset.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = im_retfield
        dynpprog        = sy-repid
        dynpnr          = sy-dynnr
        dynprofield     = im_dynfield
        value_org       = 'S'
        multiple_choice = 'X'
        mark_tab        = im_mark
      IMPORTING
        user_reset      = lv_reset
      TABLES
        field_tab       = ch_fieldtab
        value_tab       = ch_valuetab
        return_tab      = ch_returntab.
  ENDMETHOD.                    "f4_request


  METHOD field_info_get.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = im_tabname
        fieldname      = im_fieldname
        lfieldname     = im_lfieldname
      IMPORTING
        dfies_wa       = ch_data
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.                    "field_info_get

ENDCLASS.


DATA: gr_ref TYPE REF TO test.

INITIALIZATION.
  CREATE OBJECT gr_ref.


  DATA : lt_fieldtab TYPE TABLE OF dfies,
         ls_fieldtab TYPE dfies.

  DATA : BEGIN OF gs_status,
           pernr TYPE persno,
           ename TYPE emnam,
         END OF gs_status,
         gt_status LIKE TABLE OF gs_status.

  DATA : lt_return TYPE TABLE OF ddshretval,
         ls_return TYPE ddshretval.

  DATA : lt_mark TYPE ddshmarks,
         ls_mark LIKE LINE OF lt_mark.

  SELECT * FROM pa0001 INTO CORRESPONDING FIELDS OF TABLE gt_status
    WHERE begda LE sy-datum
    AND   endda GE sy-datum
    ORDER BY pernr.


*        LOOP AT gt_item INTO ls_item.
*        READ TABLE gt_status TRANSPORTING NO FIELDS
*                                WITH KEY bpid = ls_item-bpid.
*        IF sy-subrc EQ 0.
*          ls_mark = sy-tabix.
*          INSERT  ls_mark INTO TABLE lt_mark.
*        ENDIF.
*      ENDLOOP.

  ls_mark = 1. " gt_status tablosunda ilk sıradaki indexe göre
  INSERT ls_mark INTO TABLE lt_mark.

  gr_ref->f4_request(
    EXPORTING
      im_retfield  = 'PERNR'
      im_dynfield  = 'GS_STATUS-PERNR'
      im_mark      = lt_mark
    CHANGING
      ch_fieldtab  = lt_fieldtab
      ch_valuetab  = gt_status
      ch_returntab = lt_return
  ).






  gr_ref->field_info_get(
    EXPORTING
      im_tabname    = 'PA0001'
      im_fieldname  = 'PERNR'
      im_lfieldname = 'PERNR'
    CHANGING
      ch_data       = ls_fieldtab
  ).
  ls_fieldtab-outputlen = 12.
  APPEND ls_fieldtab TO lt_fieldtab.

  CLEAR  : ls_fieldtab.

  gr_ref->field_info_get(
   EXPORTING
     im_tabname    = 'PA0001'
     im_fieldname  = 'ENAME'
     im_lfieldname = 'ENAME'
   CHANGING
     ch_data       = ls_fieldtab
 ).
  ls_fieldtab-outputlen = 35.
  APPEND ls_fieldtab TO lt_fieldtab.
