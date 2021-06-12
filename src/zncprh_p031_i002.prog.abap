*&---------------------------------------------------------------------*
*& Include          ZZP050_I002
*&---------------------------------------------------------------------*

CLASS lcl_class DEFINITION.
  PUBLIC SECTION.

    METHODS: get_filename CHANGING file   TYPE char200 ,
      click_example,
      download_excel,
      modify_data,
      set_data   RETURNING VALUE(status) TYPE abap_bool,
      get_data     RETURNING VALUE(subrc) TYPE sy-subrc.

ENDCLASS.

CLASS lcl_class IMPLEMENTATION.

  METHOD get_filename.
    DATA: lt_files TYPE filetable,
          ls_files TYPE file_table,
          lv_rc    LIKE sy-subrc.

    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        file_filter             = cl_gui_frontend_services=>filetype_excel
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

  METHOD click_example.
    CASE sscrfields-ucomm.
      WHEN 'FC01'.
        download_excel( ).

    ENDCASE.

  ENDMETHOD.
  METHOD download_excel.
    DATA: lt_files TYPE filetable,
          ls_files TYPE file_table,
          lv_rc    LIKE sy-subrc.

    TYPES: BEGIN OF l_excel,
             gbasl          TYPE c LENGTH 30,
             gbits          TYPE c LENGTH 30,
             statet         TYPE c LENGTH 30,
             districtt      TYPE c LENGTH 30,
             zzdonersermaye TYPE c LENGTH 30,
           END OF l_excel.
    DATA lt_excel TYPE  TABLE OF l_excel.

    APPEND  VALUE #( gbasl     = 'Geç. Baş.'
                     gbits     = 'Gçrl. Btş.'
                     statet    = 'İl'
                     districtt = 'İlçe'
                     zzdonersermaye = 'Döner Sermaye'
                     ) TO lt_excel.
    DATA lv_fname(200) TYPE c.
    get_filename( CHANGING file = lv_fname ).

    CHECK lv_fname IS NOT INITIAL.


    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename              = CONV #( lv_fname )
        write_field_separator = 'X'
      CHANGING
        data_tab              = lt_excel.
    IF sy-subrc EQ 0.

    ENDIF.

  ENDMETHOD.
  METHOD modify_data.

    CLEAR : gs_data , gt_data.
    IF p_file IS INITIAL.

      MESSAGE i062(zekre) DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    IF 0 NE get_data( ).
    ELSE.
      set_data( ).
    ENDIF.
  ENDMETHOD.
  METHOD get_data.
    FIELD-SYMBOLS :<fs> TYPE any.
    DATA : ld_index     TYPE i.
    DATA : lv_fname     TYPE rlgrap-filename.
    DATA : p_scol  TYPE i VALUE '1',
           p_srow  TYPE i VALUE '1',
           p_ecol  TYPE i VALUE '256',
           p_erow  TYPE i VALUE '65536',
           lv_type TYPE c.


    DATA : lt_intern TYPE  TABLE OF kcde_cells .
    DATA : lv_string1 TYPE string,
           lv_string2 TYPE string,
           lv_string3 TYPE string.
    DATA : lv_length TYPE i.
    DATA : lv_decimal TYPE p LENGTH 10 DECIMALS 2.

    MOVE : p_file TO lv_fname .
* Note: Alternative function module - 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
      EXPORTING
        filename                = lv_fname
        i_begin_col             = p_scol
        i_begin_row             = p_srow
        i_end_col               = p_ecol
        i_end_row               = p_erow
      TABLES
        intern                  = lt_intern
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
      FORMAT COLOR COL_BACKGROUND INTENSIFIED.
      WRITE:/ 'Error Uploading file'.
      EXIT.
    ENDIF.
    IF lt_intern[] IS INITIAL.
*      MESSAGE TEXT-001 TYPE 'S' DISPLAY LIKE 'E'.
      CHECK 1 EQ 2.
    ELSE.
      SORT lt_intern BY row col.
      IF p_header EQ 'X'.
        DELETE lt_intern WHERE row EQ 1.
      ENDIF.
      LOOP AT lt_intern ASSIGNING FIELD-SYMBOL(<f1>).
        CLEAR: lv_length, lv_string1 ,lv_string2,lv_string3,lv_decimal.
        MOVE <f1>-col TO ld_index.
        ASSIGN COMPONENT ld_index OF STRUCTURE gs_excel TO <fs>.
        DESCRIBE FIELD <fs> TYPE lv_type.
        CASE lv_type.
          WHEN 'D'.
            IF <f1>-value IS NOT INITIAL OR
               <f1>-value+0(8) NE '0000000'.


              SPLIT <f1>-value AT '.' INTO lv_string1 lv_string2 lv_string3.

              lv_length = strlen( lv_string1 ).
              IF lv_length EQ 1.

                CONCATENATE '0' lv_string1  INTO lv_string1.

              ENDIF.
              CLEAR lv_length.

              lv_length = strlen( lv_string2 ).
              IF lv_length EQ 1.

                CONCATENATE '0' lv_string2  INTO lv_string2.

              ENDIF.

              CONCATENATE lv_string1 lv_string2 lv_string3 INTO <f1>-value.


              CONCATENATE <f1>-value+4(4)   <f1>-value+2(2)
                           <f1>-value+0(2) INTO <fs>.
            ENDIF.
          WHEN 'P'.

            CALL FUNCTION 'MOVE_CHAR_TO_NUM'
              EXPORTING
                chr             = <f1>-value
              IMPORTING
                num             = lv_decimal
              EXCEPTIONS
                convt_no_number = 1
                convt_overflow  = 2
                OTHERS          = 3.
            MOVE lv_decimal TO <fs>.


          WHEN OTHERS.
            MOVE <f1>-value TO <fs>.
        ENDCASE.


        AT END OF row.
          APPEND gs_excel TO gt_excel.
          CLEAR gs_excel.
        ENDAT.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD set_data.

    gt_data = CORRESPONDING #( gt_excel ).
    IF gt_data IS NOT INITIAL.

      MODIFY zekre_t089 FROM TABLE gt_data.
      IF sy-subrc EQ 0 .


        MESSAGE i047(zekre) DISPLAY LIKE 'S'.
      ELSE.

        MESSAGE i063(zekre) DISPLAY LIKE 'E'.

      ENDIF.

    ELSE.

      MESSAGE i064(zekre) DISPLAY LIKE 'E'.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
