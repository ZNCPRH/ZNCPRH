*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P021_I002
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZMES_P009_I002
*&---------------------------------------------------------------------*
FORM start_of_sel.

  FIELD-SYMBOLS : <fs_wa> TYPE soi_generic_item.
  DATA : ls_t035 TYPE zncprh_t001,
         lt_t035 TYPE TABLE OF zncprh_t001.

  DATA   lv_datum   TYPE sy-datum.
  DATA : lr_column  TYPE RANGE OF char4,
         lrs_column LIKE LINE OF lr_column.

  DATA : lt_trim_binis_md TYPE soi_generic_table,
         lt_trim_binis_ot TYPE soi_generic_table.

  DATA: lt_trim_inis_md TYPE soi_generic_table,
        lt_trim_inis_ot TYPE soi_generic_table.

  CONCATENATE 'FILE://' p_file INTO v_document_url.

  CALL METHOD iref_document->open_document
    EXPORTING
      document_title = 'Excel'
      document_url   = v_document_url
*     no_flush       = ' '
      open_inplace   = 'X'
*     open_readonly  = ' '
*     protect_document = ' '
*     onsave_macro   = ' '
*     startup_macro  = ''
*     user_info      =
    IMPORTING
      error          = iref_error
*     retcode        =
    .
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL METHOD iref_document->get_spreadsheet_interface
    EXPORTING
      no_flush        = ' '
    IMPORTING
      error           = iref_error
      sheet_interface = iref_spreadsheet
*     retcode         =
    .

  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL METHOD iref_spreadsheet->get_sheets
    EXPORTING
      no_flush = ' '
*     updating = -1
    IMPORTING
      sheets   = i_sheets
      error    = iref_error
*     retcode  =
    .

  "istemedğimiz sheet isimlerini sildiriyoruz
  DELETE i_sheets WHERE  ( sheet_name NE TEXT-001  AND
                           sheet_name NE TEXT-002  AND
                           sheet_name NE TEXT-003  AND
                           sheet_name NE TEXT-004
                          ).

  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  LOOP AT i_sheets INTO wa_sheets.
    CALL METHOD iref_spreadsheet->select_sheet
      EXPORTING
        name  = wa_sheets-sheet_name
*       no_flush = ' '
      IMPORTING
        error = iref_error
*       retcode  =
      .
    IF iref_error->has_failed = 'X'.
      EXIT.
*      call method iref_error->raise_message
*        exporting
*          type = 'E'.
    ENDIF.
    CALL METHOD iref_spreadsheet->set_selection
      EXPORTING
        top     = 1
        left    = 1
        rows    = p_rows
        columns = p_cols.

    CALL METHOD iref_spreadsheet->insert_range
      EXPORTING
        name     = 'Test'
        rows     = p_rows
        columns  = p_cols
        no_flush = ''
      IMPORTING
        error    = iref_error.
    IF iref_error->has_failed = 'X'.
      EXIT.
*      call method iref_error->raise_message
*        exporting
*          type = 'E'.
    ENDIF.

    REFRESH : i_data , lt_rdata.
*    okunacak sayfadaki aralık
    ls_rdata-row = 1.
    ls_rdata-column = 1.
    ls_rdata-rows = p_rows.
    ls_rdata-columns = p_cols.

    APPEND ls_rdata TO lt_rdata.

    CALL METHOD iref_spreadsheet->get_ranges_data
      EXPORTING
*       no_flush  = ' '
*       all       = 'X'
*       updating  = -1
        rangesdef = lt_rdata
      IMPORTING
        contents  = i_data
        error     = iref_error
*       retcode   =
      CHANGING
        ranges    = i_ranges.

* Remove ranges not to be processed else the data keeps on adding up
    CALL METHOD iref_spreadsheet->delete_ranges
      EXPORTING
        ranges = i_ranges.

    REFRESH : lr_column.
    CLEAR   : lv_datum,ls_t035,lrs_column.

    CASE wa_sheets-sheet_name.
      WHEN TEXT-001."md çatım
        DELETE i_data WHERE row LE 4.

        lrs_column-low     = '1'.
        lrs_column-sign    = 'I'.
        lrs_column-option  = 'EQ'.
        APPEND lrs_column TO lr_column.
        lrs_column-low     = '7'.
        APPEND lrs_column TO lr_column.

        DELETE i_data WHERE column NOT IN lr_column.

        LOOP AT i_data ASSIGNING <fs_wa>.
*                    WHERE row GE '5'.
*                    AND   ( column EQ '1' OR column EQ '7' ) .

          IF <fs_wa>-column EQ '1' AND <fs_wa>-value IS NOT INITIAL.
            CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
              EXPORTING
                date_external            = <fs_wa>-value
              IMPORTING
                date_internal            = <fs_wa>-value
              EXCEPTIONS
                date_external_is_invalid = 1
                OTHERS                   = 2.
            lv_datum = <fs_wa>-value.
            ls_t035-hbinistar = <fs_wa>-value.
          ELSEIF <fs_wa>-column EQ '1' AND <fs_wa>-value IS INITIAL.
            ls_t035-hbinistar = lv_datum.
          ENDIF.

          IF <fs_wa>-column EQ '7'.
            ls_t035-sase = <fs_wa>-value.
          ENDIF.

          IF ls_t035-sase IS NOT INITIAL
            AND ls_t035-hbinistar IS NOT INITIAL.

            SELECT SINGLE COUNT(*) FROM zncprh_t001
              WHERE sase EQ ls_t035-sase.
            IF sy-subrc EQ 0.
              UPDATE zncprh_t001
                     SET hbinistar  = ls_t035-hbinistar
                         chdate     = sy-datum
                         chtime     = sy-uzeit
                         chuser     = sy-uname
                     WHERE sase     = ls_t035-sase.
            ELSE.
              ls_t035-ist_tur  = 'MD'.
              ls_t035-crdate   = ls_t035-chdate = sy-datum.
              ls_t035-crtime   = ls_t035-chtime = sy-uzeit.
              ls_t035-cruser   = ls_t035-chuser = sy-uname.
              MODIFY zncprh_t001 FROM ls_t035.
            ENDIF.
            COMMIT WORK AND WAIT.
            CLEAR ls_t035.
          ENDIF.
        ENDLOOP.

      WHEN TEXT-002."ot çatım
        DELETE i_data WHERE row LE 5.

        lrs_column-low     = '1'.
        lrs_column-sign    = 'I'.
        lrs_column-option  = 'EQ'.
        APPEND lrs_column TO lr_column.
        lrs_column-low     = '7'.
        APPEND lrs_column TO lr_column.

        DELETE i_data WHERE column NOT IN lr_column.

        LOOP AT i_data ASSIGNING <fs_wa>.

          IF <fs_wa>-column EQ '1' AND <fs_wa>-value IS NOT INITIAL.
            CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
              EXPORTING
                date_external            = <fs_wa>-value
              IMPORTING
                date_internal            = <fs_wa>-value
              EXCEPTIONS
                date_external_is_invalid = 1
                OTHERS                   = 2.
            lv_datum = <fs_wa>-value.
            ls_t035-hbinistar = <fs_wa>-value.
          ELSEIF <fs_wa>-column EQ '1' AND <fs_wa>-value IS INITIAL.
            ls_t035-hbinistar = lv_datum.
          ENDIF.

          IF <fs_wa>-column EQ '7'.
            ls_t035-sase = <fs_wa>-value.
          ENDIF.

          IF ls_t035-sase IS NOT INITIAL
            AND ls_t035-hbinistar IS NOT INITIAL.

            SELECT SINGLE COUNT(*) FROM zncprh_t001
              WHERE sase EQ ls_t035-sase.
            IF sy-subrc EQ 0.
              UPDATE zncprh_t001
                     SET hbinistar  = ls_t035-hbinistar
                         chdate     = sy-datum
                         chtime     = sy-uzeit
                         chuser     = sy-uname
                     WHERE sase     = ls_t035-sase.
            ELSE.
              ls_t035-ist_tur = 'OT'.
              ls_t035-crdate   = ls_t035-chdate = sy-datum.
              ls_t035-crtime   = ls_t035-chtime = sy-uzeit.
              ls_t035-cruser   = ls_t035-chuser = sy-uname.
              MODIFY zncprh_t001 FROM ls_t035.
            ENDIF.
            COMMIT WORK AND WAIT.
            CLEAR ls_t035.
          ENDIF.
        ENDLOOP.

      WHEN TEXT-003."trım biniş
        DELETE i_data WHERE row LE 3.

        lt_trim_binis_md = lt_trim_binis_ot = i_data.


*- Trim Biniş MD
        lrs_column-low     = '1'.
        lrs_column-sign    = 'I'.
        lrs_column-option  = 'EQ'.
        APPEND lrs_column TO lr_column.
        lrs_column-low     = '6'.
        APPEND lrs_column TO lr_column.

        DELETE lt_trim_binis_md WHERE column NOT IN lr_column.


        LOOP AT lt_trim_binis_md ASSIGNING <fs_wa>.

          IF <fs_wa>-column EQ '1' AND <fs_wa>-value IS NOT INITIAL.
            CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
              EXPORTING
                date_external            = <fs_wa>-value
              IMPORTING
                date_internal            = <fs_wa>-value
              EXCEPTIONS
                date_external_is_invalid = 1
                OTHERS                   = 2.
            lv_datum = <fs_wa>-value.
            ls_t035-trimbintr = <fs_wa>-value.
          ELSEIF <fs_wa>-column EQ '1' AND <fs_wa>-value IS INITIAL.
            ls_t035-trimbintr = lv_datum.
          ENDIF.

          IF <fs_wa>-column EQ '6'.
            ls_t035-sase = <fs_wa>-value.
          ENDIF.

          IF ls_t035-sase IS NOT INITIAL
            AND ls_t035-trimbintr IS NOT INITIAL.

            SELECT SINGLE COUNT(*) FROM zncprh_t001
              WHERE sase EQ ls_t035-sase.
            IF sy-subrc EQ 0.
              UPDATE zncprh_t001
                     SET trimbintr  = ls_t035-trimbintr
                         chdate     = sy-datum
                         chtime     = sy-uzeit
                         chuser     = sy-uname
                     WHERE sase     = ls_t035-sase.
            ELSE.
              ls_t035-ist_tur = 'MD'.
              ls_t035-crdate   = ls_t035-chdate = sy-datum.
              ls_t035-crtime   = ls_t035-chtime = sy-uzeit.
              ls_t035-cruser   = ls_t035-chuser = sy-uname.
              MODIFY zncprh_t001 FROM ls_t035.
            ENDIF.
            COMMIT WORK AND WAIT.
            CLEAR ls_t035.
          ENDIF.
        ENDLOOP.

*-
        "Trim Biniş OT

        CLEAR : lrs_column,ls_t035,lv_datum.
        REFRESH : lr_column.

        lrs_column-low     = '1'.
        lrs_column-sign    = 'I'.
        lrs_column-option  = 'EQ'.
        APPEND lrs_column TO lr_column.
        lrs_column-low     = '13'.
        APPEND lrs_column TO lr_column.

        DELETE lt_trim_binis_ot WHERE column NOT IN lr_column.

        LOOP AT lt_trim_binis_ot ASSIGNING <fs_wa>.

          IF <fs_wa>-column EQ '1' AND <fs_wa>-value IS NOT INITIAL.
            CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
              EXPORTING
                date_external            = <fs_wa>-value
              IMPORTING
                date_internal            = <fs_wa>-value
              EXCEPTIONS
                date_external_is_invalid = 1
                OTHERS                   = 2.
            lv_datum = <fs_wa>-value.
            ls_t035-trimbintr = <fs_wa>-value.
          ELSEIF <fs_wa>-column EQ '1' AND <fs_wa>-value IS INITIAL.
            ls_t035-trimbintr = lv_datum.
          ENDIF.

          IF <fs_wa>-column EQ '13'.
            ls_t035-sase = <fs_wa>-value.
          ENDIF.

          IF ls_t035-sase IS NOT INITIAL
            AND ls_t035-trimbintr IS NOT INITIAL.

            SELECT SINGLE COUNT(*) FROM zncprh_t001
              WHERE sase EQ ls_t035-sase.
            IF sy-subrc EQ 0.
              UPDATE zncprh_t001
                     SET trimbintr  = ls_t035-trimbintr
                         chdate     = sy-datum
                         chtime     = sy-uzeit
                         chuser     = sy-uname
                     WHERE sase     = ls_t035-sase.
            ELSE.
              ls_t035-ist_tur = 'OT'.
              ls_t035-crdate   = ls_t035-chdate = sy-datum.
              ls_t035-crtime   = ls_t035-chtime = sy-uzeit.
              ls_t035-cruser   = ls_t035-chuser = sy-uname.
              MODIFY zncprh_t001 FROM ls_t035.
            ENDIF.
            COMMIT WORK AND WAIT.
            CLEAR ls_t035.
          ENDIF.
        ENDLOOP.

      WHEN TEXT-004."trım iniş
        DELETE i_data WHERE row LE 3.

        lt_trim_inis_md = lt_trim_inis_ot = i_data.

        "Trim iniş MD
        lrs_column-low     = '1'.
        lrs_column-sign    = 'I'.
        lrs_column-option  = 'EQ'.
        APPEND lrs_column TO lr_column.
        lrs_column-low     = '6'.
        APPEND lrs_column TO lr_column.

        DELETE lt_trim_inis_md WHERE column NOT IN lr_column.

        LOOP AT lt_trim_inis_md ASSIGNING <fs_wa>.

          IF <fs_wa>-column EQ '1' AND <fs_wa>-value IS NOT INITIAL.
            CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
              EXPORTING
                date_external            = <fs_wa>-value
              IMPORTING
                date_internal            = <fs_wa>-value
              EXCEPTIONS
                date_external_is_invalid = 1
                OTHERS                   = 2.
            lv_datum = <fs_wa>-value.
            ls_t035-hatckstar = <fs_wa>-value.
          ELSEIF <fs_wa>-column EQ '1' AND <fs_wa>-value IS INITIAL.
            ls_t035-hatckstar = lv_datum.
          ENDIF.

          IF <fs_wa>-column EQ '6'.
            ls_t035-sase = <fs_wa>-value.
          ENDIF.

          IF ls_t035-sase IS NOT INITIAL
            AND ls_t035-hatckstar IS NOT INITIAL.

            SELECT SINGLE COUNT(*) FROM zncprh_t001
              WHERE sase EQ ls_t035-sase.
            IF sy-subrc EQ 0.
              UPDATE zncprh_t001
                     SET hatckstar  = ls_t035-hatckstar
                         chdate     = sy-datum
                         chtime     = sy-uzeit
                         chuser     = sy-uname
                     WHERE sase     = ls_t035-sase.
            ELSE.
              ls_t035-ist_tur = 'MD'.
              ls_t035-crdate   = ls_t035-chdate = sy-datum.
              ls_t035-crtime   = ls_t035-chtime = sy-uzeit.
              ls_t035-cruser   = ls_t035-chuser = sy-uname.
              MODIFY zncprh_t001 FROM ls_t035.
            ENDIF.
            COMMIT WORK AND WAIT.
            CLEAR ls_t035.
          ENDIF.
        ENDLOOP.

        "Trim iniş OT

        CLEAR : lrs_column,ls_t035,lv_datum.
        REFRESH : lr_column.


        lrs_column-low     = '1'.
        lrs_column-sign    = 'I'.
        lrs_column-option  = 'EQ'.
        APPEND lrs_column TO lr_column.
        lrs_column-low     = '13'.
        APPEND lrs_column TO lr_column.

        DELETE lt_trim_inis_ot WHERE column NOT IN lr_column.

        LOOP AT lt_trim_inis_ot ASSIGNING <fs_wa>.

          IF <fs_wa>-column EQ '1' AND <fs_wa>-value IS NOT INITIAL.
            CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
              EXPORTING
                date_external            = <fs_wa>-value
              IMPORTING
                date_internal            = <fs_wa>-value
              EXCEPTIONS
                date_external_is_invalid = 1
                OTHERS                   = 2.
            lv_datum = <fs_wa>-value.
            ls_t035-hatckstar = <fs_wa>-value.
          ELSEIF <fs_wa>-column EQ '1' AND <fs_wa>-value IS INITIAL.
            ls_t035-hatckstar = lv_datum.
          ENDIF.

          IF <fs_wa>-column EQ '13'.
            ls_t035-sase = <fs_wa>-value.
          ENDIF.

          IF ls_t035-sase IS NOT INITIAL
            AND ls_t035-hatckstar IS NOT INITIAL.

            SELECT SINGLE COUNT(*) FROM zncprh_t001
              WHERE sase EQ ls_t035-sase.
            IF sy-subrc EQ 0.
              UPDATE zncprh_t001
                     SET hatckstar  = ls_t035-hatckstar
                         chdate     = sy-datum
                         chtime     = sy-uzeit
                         chuser     = sy-uname
                     WHERE sase     = ls_t035-sase.
            ELSE.
              ls_t035-ist_tur = 'OT'.
              ls_t035-crdate   = ls_t035-chdate = sy-datum.
              ls_t035-crtime   = ls_t035-chtime = sy-uzeit.
              ls_t035-cruser   = ls_t035-chuser = sy-uname.
              MODIFY zncprh_t001 FROM ls_t035.
            ENDIF.
            COMMIT WORK AND WAIT.
            CLEAR ls_t035.
          ENDIF.
        ENDLOOP.
    ENDCASE.

*    DELETE i_data WHERE value IS INITIAL OR value = space.
*    ULINE.
*    WRITE:/1 wa_sheets-sheet_name COLOR 3.
*    ULINE.
*
*    LOOP AT i_data INTO wa_data.
*      WRITE:(50) wa_data-value.
*      AT END OF row.
*        NEW-LINE.
*      ENDAT.
*    ENDLOOP.
  ENDLOOP.

  CALL METHOD iref_document->close_document
*  EXPORTING
*    do_save     = ' '
*    no_flush    = ' '
    IMPORTING
      error = iref_error
*     has_changed =
*     retcode     =
    .
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  CALL METHOD iref_document->release_document
*  EXPORTING
*    no_flush = ' '
    IMPORTING
      error = iref_error
*     retcode  =
    .
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.                    "start_of_sel


*&---------------------------------------------------------------------*
*&      Form  init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM init.
  CALL METHOD c_oi_container_control_creator=>get_container_control
    IMPORTING
      control = iref_control
      error   = iref_error
*     retcode =
    .
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.


  CREATE OBJECT oref_container
    EXPORTING
*     parent                      =
      container_name              = 'CONT'
*     style                       =
*     lifetime                    = lifetime_default
*     repid                       =
*     dynnr                       =
*     no_autodef_progid_dynnr     =
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH 'Error while creating container'.
  ENDIF.

  CALL METHOD iref_control->init_control
    EXPORTING
*     dynpro_nr            = SY-DYNNR
*     gui_container        = ' '
      inplace_enabled      = 'X'
*     inplace_mode         = 0
*     inplace_resize_documents = ' '
*     inplace_scroll_documents = ' '
*     inplace_show_toolbars    = 'X'
*     no_flush             = ' '
*     parent_id            = cl_gui_cfw=>dynpro_0
      r3_application_name  = 'EXCEL CONTAINER'
*     register_on_close_event  = ' '
*     register_on_custom_event = ' '
*     rep_id               = SY-REPID
*     shell_style          = 1384185856
      parent               = oref_container
*     name                 =
*     autoalign            = 'x'
    IMPORTING
      error                = iref_error
*     retcode              =
    EXCEPTIONS
      javabeannotsupported = 1
      OTHERS               = 2.
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

  CALL METHOD iref_control->get_document_proxy
    EXPORTING
*     document_format    = 'NATIVE'
      document_type  = soi_doctype_excel_sheet
*     no_flush       = ' '
*     register_container = ' '
    IMPORTING
      document_proxy = iref_document
      error          = iref_error
*     retcode        =
    .
  IF iref_error->has_failed = 'X'.
    CALL METHOD iref_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

ENDFORM.                    "init
*&---------------------------------------------------------------------*
*&      Form  sub_file_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sub_file_f4 .
  DATA:
    l_desktop  TYPE string,
    l_i_files  TYPE filetable,
    l_wa_files TYPE file_table,
    l_rcode    TYPE int4.

* Finding desktop
  CALL METHOD cl_gui_frontend_services=>get_desktop_directory
    CHANGING
      desktop_directory    = l_desktop
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH
        'Desktop not found'.
  ENDIF.

* Update View
  CALL METHOD cl_gui_cfw=>update_view
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Select Excel file'
      default_extension       = '.xlsx'
*     default_filename        =
      file_filter             = '.xlsx'
*     with_encoding           =
      initial_directory       = l_desktop
*     multiselection          =
    CHANGING
      file_table              = l_i_files
      rc                      = l_rcode
*     user_action             =
*     file_encoding           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE e001(00) WITH 'Error while opening file'.
  ENDIF.

  READ TABLE l_i_files INDEX 1 INTO l_wa_files.
  IF sy-subrc = 0.
    p_file = l_wa_files-filename.
  ELSE.
    MESSAGE e001(00) WITH 'Error while opening file'.
  ENDIF.

ENDFORM.                    " SUB_FILE_F4
