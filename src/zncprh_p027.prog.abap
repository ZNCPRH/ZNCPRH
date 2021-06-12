*&---------------------------------------------------------------------*
*& Report ZNCPRH_P027
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p027.


DATA : l_bytecount TYPE i,
       l_tdbtype   LIKE stxbitmaps-tdbtype,
       l_content   TYPE STANDARD TABLE OF bapiconten INITIAL SIZE 0.

DATA: graphic_size TYPE i.

DATA: BEGIN OF graphic_table OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table.

CALL FUNCTION 'SAPSCRIPT_GET_GRAPHIC_BDS'
  EXPORTING
    i_object       = 'GRAPHICS'
    i_name         = 'ZREHA'
    i_id           = 'BMAP'
    i_btype        = 'BCOL'
  IMPORTING
    e_bytecount    = l_bytecount
  TABLES
    content        = l_content
  EXCEPTIONS
    not_found      = 1
    bds_get_failed = 2
    bds_no_content = 3
    OTHERS         = 4.

CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
  EXPORTING
    old_format               = 'BDS'
    new_format               = 'BMP'
    bitmap_file_bytecount_in = l_bytecount
  IMPORTING
    bitmap_file_bytecount    = graphic_size
  TABLES
    bds_bitmap_file          = l_content
    bitmap_file              = graphic_table
  EXCEPTIONS
    OTHERS                   = 1.

CALL FUNCTION 'WS_DOWNLOAD'
  EXPORTING
    bin_filesize            = graphic_size
    filename                = 'C:\Users\P1362\logo.bmp'
    filetype                = 'BIN'
  TABLES
    data_tab                = graphic_table
  EXCEPTIONS
    invalid_filesize        = 1
    invalid_table_width     = 2
    invalid_type            = 3
    no_batch                = 4
    unknown_error           = 5
    gui_refuse_filetransfer = 6.

IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

DATA : lv_string TYPE string.

CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
  EXPORTING
    p_object       = 'GRAPHICS'
    p_name         = 'ZREHA'
    p_id           = 'BMAP'
    p_btype        = 'BCOL'
  RECEIVING
    p_bmp          = lv_string
  EXCEPTIONS
    not_found      = 1
    internal_error = 2
    OTHERS         = 3.

BREAK p1362.
