*&---------------------------------------------------------------------*
*& Report ZNCPRH_P028
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZNCPRH_P028.

DATA : lt         TYPE TABLE OF scarr,
       ls         TYPE scarr,
       lv_string  TYPE string,
       lv_xstring TYPE xstring,
       lr_zip     TYPE REF TO cl_abap_zip,
       lt_bin     TYPE TABLE OF x255.

START-OF-SELECTION.
  SELECT * FROM scarr INTO TABLE lt.
  LOOP AT lt INTO ls.
    CONCATENATE lv_string ls INTO lv_string SEPARATED BY cl_abap_char_utilities=>newline.
  ENDLOOP.

* Convert String to X String
  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = lv_string
    IMPORTING
      buffer = lv_xstring.

  CREATE OBJECT lr_zip.
* Add teh X String as a Zip file
  CALL METHOD lr_zip->add
    EXPORTING
      name    = 'flight'
      content = lv_xstring.

  CALL METHOD lr_zip->save
    RECEIVING
      zip = lv_xstring.

* Convert Xstring to Binary Table
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = lv_xstring
    TABLES
      binary_tab = lt_bin.

* Download the Binary table
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename = 'C:\Users\P1362\Desktop'
      filetype = 'BIN'
    TABLES
      data_tab = lt_bin.
  IF sy-subrc IS INITIAL.
    MESSAGE 'check the zip file in the location:' TYPE 'I'.
  ENDIF.
