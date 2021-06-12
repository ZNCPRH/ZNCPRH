*&---------------------------------------------------------------------*
*& Report ZNCPRH_P039
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p039.

DATA: lr_mime_rep TYPE REF TO if_mr_api.

DATA: lv_url TYPE char255.
DATA: lv_content  TYPE xstring.
DATA: lv_repid TYPE sy-repid.

DATA: lt_data TYPE STANDARD TABLE OF x255.

DATA: p_path TYPE string VALUE 'SAP/PUBLIC/HS.bmp'.
*

START-OF-SELECTION.
  CALL SCREEN 0101.
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'GUI'.

  TYPES pict_line(256) TYPE c.
  DATA: container TYPE REF TO cl_gui_custom_container,
        editor    TYPE REF TO cl_gui_textedit,
        picture   TYPE REF TO cl_gui_picture,
        pict_tab  TYPE TABLE OF pict_line,
        url(255)  TYPE c.
  CREATE OBJECT:
       container EXPORTING container_name = 'CONT001',
       picture EXPORTING parent = container.

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
      subtype = 'BMP'
    TABLES
      data    = lt_data
    CHANGING
      url     = lv_url.

  picture->load_picture_from_url_async( lv_url ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.
  IF sy-ucomm EQ '&F03'.
    LEAVE TO SCREEN 0.
  ELSEIF sy-ucomm EQ 'FCT_ONE'.
*    CALL SCREEN 0102 STARTING AT 30 10.
  ENDIF.
ENDMODULE.
