*&---------------------------------------------------------------------*
*& Report ZNCPRH_P029
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p029.

DATA : gv_way TYPE string.

SELECTION-SCREEN BEGIN OF BLOCK 200 WITH FRAME TITLE TEXT-001.
PARAMETERS :  file_2 LIKE rlgrap-filename.
SELECTION-SCREEN   END OF BLOCK 200.

INITIALIZATION.
  CALL METHOD cl_gui_frontend_services=>get_desktop_directory
    CHANGING
      desktop_directory = gv_way
    EXCEPTIONS
      cntl_error        = 1.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  CALL METHOD cl_gui_cfw=>update_view.

  file_2 = gv_way && '\Şablon.xls'.


  CALL METHOD cl_gui_frontend_services=>get_ip_address
    RECEIVING
      ip_address           = DATA(lv_ip)     " IP ADDRESS
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  cl_gui_frontend_services=>get_screenshot(
    IMPORTING
      mime_type_str        = DATA(lv_mime)
      image                = DATA(lv_image)
*  EXCEPTIONS
*    access_denied        = 1
*    cntl_error           = 2
*    error_no_gui         = 3
*    not_supported_by_gui = 4
*    others               = 5
  ).
  IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
