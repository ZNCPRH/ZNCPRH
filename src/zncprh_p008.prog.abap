*&---------------------------------------------------------------------*
*& Report ZNCPRH_P008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p008.

TYPE-POOLS: slis.
TYPE-POOLS: abap.

FIELD-SYMBOLS: <dyn_table> TYPE STANDARD TABLE,
               <dyn_wa>,
               <dyn_field>.

DATA: alv_fldcat TYPE slis_t_fieldcat_alv,
      it_fldcat  TYPE lvc_t_fcat.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_check TYPE c.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  PERFORM build_dyn_itab.
  PERFORM build_report.


  DATA : it_details TYPE abap_compdescr_tab.
  DATA : ref_descr TYPE REF TO cl_abap_structdescr.

  ref_descr ?= cl_abap_typedescr=>describe_by_data( <dyn_wa> ).
  it_details[] = ref_descr->components[].

* Write out data from table.
  LOOP AT <dyn_table> INTO <dyn_wa>.
    DO.
      ASSIGN COMPONENT  sy-index  OF STRUCTURE <dyn_wa> TO <dyn_field>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      IF sy-index = 1.
        WRITE:/ <dyn_field>.
      ELSE.
        WRITE: <dyn_field>.
      ENDIF.
    ENDDO.
  ENDLOOP.


************************************************************************
*  Build_dyn_itab
************************************************************************
FORM build_dyn_itab.

  DATA: index(3) TYPE c.

  DATA: new_table    TYPE REF TO data,
        new_line     TYPE REF TO data,
        wa_it_fldcat TYPE lvc_s_fcat.

* Create fields
  CLEAR index.
  DO 10 TIMES.
    index = sy-index.
    CLEAR wa_it_fldcat.
    CONCATENATE 'Field' index INTO
             wa_it_fldcat-fieldname .
    CONDENSE  wa_it_fldcat-fieldname NO-GAPS.
    wa_it_fldcat-datatype = 'INT4'.
    wa_it_fldcat-intlen = 5.
    APPEND wa_it_fldcat TO it_fldcat .
  ENDDO.

* Create dynamic internal table and assign to FS
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = it_fldcat
    IMPORTING
      ep_table        = new_table.

  ASSIGN new_table->* TO <dyn_table>.

* Create dynamic work area and assign to FS
  CREATE DATA new_line LIKE LINE OF <dyn_table>.
  ASSIGN new_line->* TO <dyn_wa>.

ENDFORM.

*********************************************************************
*      Form  build_report
*********************************************************************
FORM build_report.

  DATA: fieldname(20) TYPE c.
  DATA: fieldvalue(5) TYPE c.
  DATA: index(3) TYPE c.
  FIELD-SYMBOLS: <fs1>.

  DO 10 TIMES.

    index = sy-index.

* Set up fieldname
    CONCATENATE 'FIELD' index INTO
             fieldname .
    CONDENSE   fieldname  NO-GAPS.

* Set up fieldvalue
    fieldvalue = index.
    CONDENSE   fieldvalue NO-GAPS.

    ASSIGN COMPONENT  fieldname  OF STRUCTURE <dyn_wa> TO <fs1>.
    <fs1> =  fieldvalue.

  ENDDO.

* Append to the dynamic internal table
  APPEND <dyn_wa> TO <dyn_table>.

ENDFORM.
