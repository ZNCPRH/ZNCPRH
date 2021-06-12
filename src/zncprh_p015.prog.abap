*&---------------------------------------------------------------------*
*& Report ZNCPRH_P015
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p015.


TYPES: BEGIN OF ty_vbap,
         vbeln TYPE vbeln,
         posnr TYPE posnr,
         matnr TYPE matnr,
       END OF ty_vbap.
*-ALL related Declarations
DATA: t_header  TYPE STANDARD TABLE OF w3head WITH HEADER LINE,  "Header
      t_fields  TYPE STANDARD TABLE OF w3fields WITH HEADER LINE,    "Fields
      t_html    TYPE STANDARD TABLE OF w3html,
      wa_header TYPE w3head,
      w_head    TYPE w3head.
DATA: it_vbap TYPE STANDARD TABLE OF ty_vbap,
      it_fcat TYPE lvc_t_fcat WITH HEADER LINE.
DATA : BEGIN OF ls_data ,
         t1 TYPE string,
         t2 TYPE string,
         t3 TYPE string,
       END OF ls_data.

DATA lt_data LIKE TABLE OF ls_data.

ls_data-t1 = 'Reha yorum yazdı'.
ls_data-t2 = 'Ertuğrul yorum'.
ls_data-t3 = 'Hğlagü yorumu'.
APPEND ls_data TO lt_data.
ls_data-t1 = 'Reha yorum yazdı'.
ls_data-t2 = 'Ertuğrul yorum'.
ls_data-t3 = 'Hğlagü yorumu'.
APPEND ls_data TO lt_data.
ls_data-t1 = 'Reha yorum yazdı'.
ls_data-t2 = 'Ertuğrul yorum'.
ls_data-t3 = 'Hğlagü yorumu'.
APPEND ls_data TO lt_data.

START-OF-SELECTION.
*  SELECT vbeln posnr matnr
*          FROM vbap
*          INTO TABLE it_vbap
*         UP TO 20 ROWS.
END-OF-SELECTION.
*-Populate the Columns
  it_fcat-coltext = 'Necip Reha'.
  APPEND it_fcat.
  it_fcat-coltext = 'Ertuğrul'.
  APPEND it_fcat.
  it_fcat-coltext = 'Hülagü'.
  APPEND it_fcat.
*-Fill the Column heading and Filed Properties
  LOOP AT it_fcat.
    w_head-text = it_fcat-coltext.
    CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
      EXPORTING
        field_nr = sy-tabix
        text     = w_head-text
        fgcolor  = 'black'
        bgcolor  = 'green'
      TABLES
        header   = t_header.
    CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
      EXPORTING
        field_nr = sy-tabix
        fgcolor  = 'black'
        size     = '3'
      TABLES
        fields   = t_fields.
  ENDLOOP.
*-Title of the Display
  wa_header-text = 'Sales Order Details' .
  wa_header-font = 'Arial'.
  wa_header-size = '2'.
*-Preparing the HTML from Intenal Table
  REFRESH t_html.
  CALL FUNCTION 'WWW_ITAB_TO_HTML'
    EXPORTING
      table_header = wa_header
    TABLES
      html         = t_html
      fields       = t_fields
      row_header   = t_header
      itable       = lt_data.
*-Download  the HTML into frontend
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = 'C:\Users\P1362\Desktop\sap.html'
    TABLES
      data_tab                = t_html
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*-Display the HTML file
  CALL METHOD cl_gui_frontend_services=>execute
    EXPORTING
      document               = 'C:\Users\P1362\Desktop\sap.html'
      operation              = 'OPEN'
    EXCEPTIONS
      cntl_error             = 1
      error_no_gui           = 2
      bad_parameter          = 3
      file_not_found         = 4
      path_not_found         = 5
      file_extension_unknown = 6
      error_execute_failed   = 7
      synchronous_failed     = 8
      not_supported_by_gui   = 9
      OTHERS                 = 10.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
