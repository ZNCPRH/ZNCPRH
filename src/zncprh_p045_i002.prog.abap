*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P045_I002
*&---------------------------------------------------------------------*
CLASS lcl_class DEFINITION.
  PUBLIC SECTION.
    METHODS:
      get_filename CHANGING file   TYPE char200 ,
*      click_example,
*      download_excel,
      modify_data.
*      set_data   RETURNING VALUE(status) TYPE abap_bool.
*      get_data     RETURNING VALUE(subrc) TYPE sy-subrc.
ENDCLASS.

CLASS lcl_class IMPLEMENTATION.
  METHOD get_filename.
    DATA: lt_files TYPE filetable,
          ls_files TYPE file_table,
          lv_rc    LIKE sy-subrc.

    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        file_filter             = cl_gui_frontend_services=>filetype_text
      CHANGING
        file_table              = lt_files
        rc                      = lv_rc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.

    IF sy-subrc <> 0 OR lv_rc < 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      READ TABLE lt_files INDEX 1 INTO ls_files.
      file = ls_files-filename.
    ENDIF.
  ENDMETHOD.
  METHOD modify_data.
    DATA : lv_string        TYPE string,
           lv_headerxstring TYPE xstring,
           lv_filelength    TYPE i.
    FIELD-SYMBOLS : <gt_data>       TYPE STANDARD TABLE .
    DATA : lt_records   TYPE solix_tab,
           lv_taskname  TYPE numc10 VALUE '0',
           lv_excp_flag TYPE flag,
           lv_lines     TYPE i.

    DATA : ls_data    TYPE zncprh_t007,
           lv_msg(80) TYPE c.
    DATA :lt_temp  TYPE TABLE OF zncprh_s033 .

    lv_string = p_file.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = lv_string
        filetype                = 'DAT'
*       has_field_separator     = 'X'
*       HEADER_LENGTH           = 0
        read_by_line            = 'X'
*       DAT_MODE                = ' '
*       CODEPAGE                = ' '
*       IGNORE_CERR             = ABAP_TRUE
*       REPLACEMENT             = '#'
      IMPORTING
        filelength              = lv_filelength
        header                  = lv_headerxstring
      TABLES
        data_tab                = lt_data
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.
    IF sy-subrc EQ 0.
      MESSAGE 'Yükleme Başarılı!' TYPE 'S'.
    ELSE.
    ENDIF.

    CHECK lt_data IS NOT INITIAL.

    IF p_header EQ 'X'.
      DELETE lt_data INDEX 1.
    ENDIF.
    DESCRIBE TABLE lt_data LINES lv_lines.

    DO 10 TIMES.

      lv_taskname = sy-index.

      lt_temp[] = CORRESPONDING #( lt_data[] ).
      DELETE lt_temp FROM 100000 TO  lv_lines  .
      DELETE lt_data FROM 1 TO  100000  .
      IF lt_temp[] IS INITIAL .
        EXIT .
      ENDIF.
*-
      CALL FUNCTION 'ZNCPRH_FG005_002'
        STARTING NEW TASK lv_taskname
        DESTINATION 'NONE'
*        DESTINATION IN GROUP
*        PERFORMING process_callback_prog ON END OF TASK
        EXPORTING
          it_data               = lt_temp
        EXCEPTIONS
          communication_failure = 1 MESSAGE lv_msg
          system_failure        = 2 MESSAGE lv_msg
          resource_failure      = 3 "“No work processes are
          OTHERS                = 4. "“Add exceptions generated by

    ENDDO.
*    COMMIT WORK AND WAIT .
    BREAK xrertug.

  ENDMETHOD.
ENDCLASS.