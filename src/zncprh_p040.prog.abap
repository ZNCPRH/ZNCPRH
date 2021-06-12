*&---------------------------------------------------------------------*
*& Report ZNCPRH_P040
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p040.

DATA: lr_mime_rep TYPE REF TO if_mr_api.

DATA: lv_url TYPE char255.
DATA: lv_content  TYPE xstring.
DATA: lv_repid TYPE sy-repid.

DATA: lt_data TYPE STANDARD TABLE OF x255.

DATA: lo_docking TYPE REF TO cl_gui_docking_container.
DATA: lo_picture TYPE REF TO cl_gui_picture.

DATA: p_path TYPE string VALUE 'SAP/PUBLIC/HS.bmp'.

PARAMETERS: p_check.

AT SELECTION-SCREEN OUTPUT.

* Create controls
  CREATE OBJECT lo_docking
    EXPORTING
      repid     = lv_repid
      dynnr     = sy-dynnr
      side      = lo_docking->dock_at_left
      extension = 200.

  CREATE OBJECT lo_picture
    EXPORTING
      parent = lo_docking.

  lr_mime_rep = cl_mime_repository_api=>if_mr_api~get_api( ).

  lr_mime_rep->get(
             EXPORTING
                  i_url      = p_path
             IMPORTING
                   e_content = lv_content
             EXCEPTIONS
                   not_found = 3 ).

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = lv_content
    TABLES
      binary_tab = lt_data.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type    = 'IMAGE'
      subtype = 'JPG'
    TABLES
      data    = lt_data
    CHANGING
      url     = lv_url.

  lo_picture->load_picture_from_url_async( lv_url ).
