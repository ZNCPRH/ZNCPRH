*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P032_I002
*&---------------------------------------------------------------------*
CLASS alv_class DEFINITION .
  PUBLIC SECTION.

    METHODS:
    init,
    at_selection_screen                        ,
    fill_fcat                                  ,
    diffraction_data                           ,
    example_file                               ,
    diff_data_onli                             ,
    information_type                           ,
    create_fcat                                ,
    create_dyn_table                           ,
    at_selection_output                        ,
    get_file_name                              ,
    get_data                                   ,
    handle_user_command_click1                 ,
    create_layout                              ,
    alv_initial                                ,
    create_alv_from_container                  ,
    display_alv                                ,
    refresh_container_alv                      .

ENDCLASS .                    "alv_class DEFINITION

*----------------------------------------------------------------------*
*       CLASS alv_class IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS alv_class IMPLEMENTATION .

  METHOD init.

    sscrfields-functxt_01 = |{ icon_attachment }{ 'Aktarım Formatı' }|.

  ENDMETHOD.                    "init

  METHOD at_selection_screen.

    MOVE sy-ucomm TO lv_ucomm.
    CASE lv_ucomm.
      WHEN 'PUSH'.
        CLEAR : ssort[] , s_fnams[].
        me->fill_fcat( ).
        me->diffraction_data( ).

        WHEN'FC01'.

        me->example_file( ).

      WHEN 'ONLI'.
        IF p_file IS INITIAL.
          MESSAGE 'Dosya Yolu Girişi Yapılmadı' TYPE 'W' DISPLAY LIKE 'E'.
        ELSE.
          me->fill_fcat( ).
          me->diff_data_onli( ).
        ENDIF.
    ENDCASE.

  ENDMETHOD.                    "at_selection_screen

  METHOD fill_fcat.

    DATA: lv_repid  LIKE sy-repid,
       lv_tabnam TYPE slis_tabname.
    IF gt_fcat1 IS NOT  INITIAL.
      CLEAR : gt_fcat1.
    ENDIF.
    CLEAR : ssort[].
    CONCATENATE 'PA' p_infty  INTO lv_tabnam.
    lv_repid = sy-repid.
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_program_name         = lv_repid
        i_structure_name       = lv_tabnam
        i_inclname             = lv_repid
      CHANGING
        ct_fieldcat            = gt_fcat1
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.                    "fill_fcat

  METHOD diffraction_data.

    me->information_type( ).

    LOOP AT s_fnams INTO gs_fnams.
      READ TABLE csort INTO gs_csort
                       WITH KEY fnam = gs_fnams-low.
      CHECK sy-subrc EQ 0.  APPEND gs_csort TO ssort.
    ENDLOOP.
* popup açma ..
    CALL FUNCTION 'HR_FIELD_CHOICE'
      EXPORTING
        maxfields                 = 50
        popuptitel                = text-002
        titel1                    = text-004
        titel2                    = text-005
      TABLES
        fieldtabin                = csort
        selfields                 = ssort
      EXCEPTIONS
        no_tab_field_input        = 1
        to_many_selfields_entries = 2
        OTHERS                    = 3.

    REFRESH s_fnams.
    MOVE : 'I'          TO   s_fnams-sign,
           'EQ'         TO   s_fnams-option.
    LOOP AT ssort INTO gs_csort.
      MOVE : gs_csort-fnam  TO   gs_fnams-low.
      APPEND gs_fnams TO s_fnams.
    ENDLOOP.

*
    IF NOT ssort[] IS INITIAL .
      me->create_fcat( ).
      me->create_dyn_table( ).
*  ELSE .
*    MESSAGE 'Lütfen Field Seçimi Yapınız ..' TYPE 'E' DISPLAY LIKE 'E'.
    ENDIF .

  ENDMETHOD.                    "diffraction_data

  METHOD example_file.
    IF ssort[] IS NOT INITIAL.


      LOOP AT ssort INTO gs_csort.
        t_title-title = gs_csort-ftxt.
        APPEND t_title-title TO t_title.
      ENDLOOP.

      CALL METHOD cl_gui_frontend_services=>file_save_dialog
        EXPORTING
          default_file_name = 'DinamikBilgiTipi'
          default_extension = 'XLS'
        CHANGING
          filename          = lv_filename
          path              = lv_path
          fullpath          = lv_fullpath
          user_action       = lv_result.
      CHECK lv_result EQ '0'.

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename              = lv_fullpath
          filetype              = 'ASC'
          write_field_separator = 'X'
          confirm_overwrite     = 'X'
        TABLES
          fieldnames            = t_title
          data_tab              = gt_title
        EXCEPTIONS
          file_open_error       = 1
          file_write_error      = 2
          OTHERS                = 3.
    ELSE.
      MESSAGE 'Lütfen Field Seçimi Yapınız ..' TYPE 'E' DISPLAY LIKE 'E'.
    ENDIF.
  ENDMETHOD.                    "example_file

  METHOD diff_data_onli.

    me->information_type( ).
    DATA: mt_intern TYPE STANDARD TABLE OF alsmex_tabline.
    DATA : ms_intern LIKE LINE OF mt_intern.
    DATA : lv_ch1 TYPE char30,
           lv_ch2 TYPE char30.
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename    = p_file
        i_begin_col = 1   "1. sutun
        i_begin_row = 1   "2.satır başla
        i_end_col   = 96   "3. sutun
        i_end_row   = 1
      TABLES
        intern      = mt_intern[]. "bu tabloya aktar

    CHECK mt_intern IS NOT INITIAL.
    LOOP AT mt_intern INTO ms_intern.
      "Xtvarli.
      gs_csort-ftxt = ms_intern-value.
      SPLIT ms_intern-value AT ' -' INTO : lv_ch1 lv_ch2.
      gs_csort-fnam = lv_ch1.
      APPEND gs_csort TO ssort.

      gs_fnams-low = gs_csort-fnam.
      gs_fnams-sign = 'I' .
      gs_fnams-option = 'EQ' .
      APPEND gs_fnams TO s_fnams.

      CLEAR gs_fnams.
      CLEAR gs_csort.

      CLEAR : lv_ch1 , lv_ch2.
    ENDLOOP.

    IF NOT ssort[] IS INITIAL .
      me->create_fcat( ).
      me->create_dyn_table( ).
    ELSE.
      MESSAGE 'Excel Dosyası Hatalı..' TYPE 'E'.
    ENDIF.


  ENDMETHOD.                    "diff_data_onli

  METHOD information_type.
    DATA : lv_pa(2) TYPE c VALUE 'PA',
         lv_infty TYPE t582s-infty.
    DATA : lr_fieldname TYPE RANGE OF fieldname,
           lr_as4local  TYPE RANGE OF  as4local,
           lr_as4vers   TYPE RANGE OF   as4vers,
           lr_position  TYPE RANGE OF  tabfdpos.


    REFRESH csort.
    REFRESH ssort.
    lv_infty = p_infty.

    CONCATENATE lv_pa lv_infty INTO g_tabname.
    FREE dd03l .
* tablo alanlarını alma ..
    SELECT * FROM dd03l INTO TABLE dd03l
            WHERE tabname     EQ g_tabname
            AND   fieldname   IN lr_fieldname"
            AND   as4local    IN lr_as4local"
            AND   as4vers     IN lr_as4vers"
            AND   position    IN lr_position"
            AND   comptype    EQ 'E' .
    DELETE dd03l WHERE fieldname EQ 'MANDT' .
    SORT dd03l BY position .

    SELECT * FROM dd03m INTO TABLE dd03m
        FOR ALL ENTRIES IN dd03l
            WHERE tabname    EQ dd03l-tabname
              AND fieldname  EQ dd03l-fieldname
              AND ddlanguage EQ sy-langu .

    FREE csort .
    LOOP AT dd03l INTO gs_dd031.
      READ TABLE dd03m INTO gs_dd03m
                  WITH KEY fieldname = gs_dd031-fieldname.
      CONCATENATE gs_dd031-fieldname '-' gs_dd03m-ddtext
          INTO gs_csort-ftxt
            SEPARATED BY space.
      gs_csort-fnam = gs_dd031-fieldname.

      APPEND gs_csort TO csort.
      CLEAR gs_csort.

    ENDLOOP .
  ENDMETHOD.                    "information_type

  METHOD create_fcat.


    DATA l_tabix TYPE sy-tabix VALUE 1 .
    CLEAR gt_fcat .

    LOOP AT ssort INTO gs_ssort.

      IF p_infty EQ '0770' AND gs_ssort-FNAM eq 'MERNI'.
        ADD 1 TO l_tabix.
        CLEAR gs_fcat .
        gs_fcat-col_pos   = l_tabix.
        gs_fcat-fieldname = 'MERNI'.
        gs_fcat-datatype  = 'CHAR' .
        gs_fcat-inttype   = 'C'    .
        gs_fcat-intlen    = '12'   .
        gs_fcat-scrtext_l = 'T.C. Kimlik No'.
        APPEND gs_fcat TO gt_fcat .
      ELSEIF p_infty EQ '2001' and gs_ssort-FNAM eq 'ABRTG'.
        CLEAR gs_fcat .
        ADD 1 TO l_tabix.
        gs_fcat-col_pos   = l_tabix  .
        gs_fcat-fieldname = 'ABRTG'  .
        gs_fcat-scrtext_l = 'Kota Kullanımı' .
        APPEND gs_fcat TO gt_fcat    .
      ELSE .
        CLEAR gs_fcat.
        READ TABLE gt_fcat1 INTO gs_fcat1
                              WITH KEY fieldname = gs_ssort-fnam.
        MOVE-CORRESPONDING gs_fcat1 TO gs_fcat.
        MOVE: gs_fcat1-seltext_l TO gs_fcat-scrtext_l.
      ENDIF .
      gs_fcat-col_pos   = l_tabix   .

      APPEND gs_fcat TO gt_fcat .
      ADD 1 TO l_tabix .
    ENDLOOP .
    ADD 1 TO l_tabix .
    CLEAR gs_fcat .
    gs_fcat-col_pos   = l_tabix   .
    gs_fcat-fieldname = 'MESSAGE' .
    gs_fcat-scrtext_l = 'Açıklama'.
    gs_fcat-outputlen = 100       .
    APPEND gs_fcat TO gt_fcat     .
    ADD 1 TO l_tabix .
    CLEAR gs_fcat .
    gs_fcat-col_pos   = l_tabix  .
    gs_fcat-fieldname = 'ICON'   .
    gs_fcat-scrtext_l = 'Durum'  .
    gs_fcat-icon      = 'X'      .
    APPEND gs_fcat TO gt_fcat    .
    CLEAR: gs_ssort.


  ENDMETHOD.                    "create_fcat

  METHOD create_dyn_table.
    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog           = gt_fcat[]
      IMPORTING
        ep_table                  = itab
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.
    ASSIGN itab->* TO <dyn_table> .
    CREATE DATA new_line LIKE LINE OF <dyn_table> .
    ASSIGN new_line->* TO <wa> .

  ENDMETHOD.                    "create_dyn_table

  METHOD at_selection_output.

    IF s_fnams[] IS NOT INITIAL .

      me->information_type( ).
      REFRESH ssort.

      LOOP AT s_fnams INTO gs_fnams.
        READ TABLE csort INTO gs_csort
                             WITH KEY fnam = gs_fnams-low.
        CHECK sy-subrc EQ 0.  COLLECT gs_csort  INTO ssort  .
      ENDLOOP.
    ENDIF.
  ENDMETHOD.                    "at_selection_output

  METHOD get_file_name.

    CALL FUNCTION 'F4_FILENAME'
      EXPORTING
        field_name = 'P_FILE'
      IMPORTING
        file_name  = p_file.

  ENDMETHOD.                    "get_file_name

  METHOD get_data.

    DATA : raw TYPE truxs_t_text_data .
    me->information_type( ).

    IF s_fnams[] IS NOT  INITIAL.
      LOOP AT s_fnams INTO gs_fnams.
        READ TABLE csort INTO gs_csort WITH KEY fnam = gs_fnams-low.
        CHECK sy-subrc EQ 0.
        READ TABLE ssort INTO gs_ssort WITH KEY fnam = gs_fnams-low.
        CHECK sy-subrc NE 0 .
        APPEND gs_csort TO ssort.
      ENDLOOP.
    ELSE.
      DATA: mv_sfilename TYPE rlgrap-filename,
            lt_intern     TYPE STANDARD TABLE OF alsmex_tabline,
            ls_intern     LIKE LINE OF           lt_intern.
      DATA : t1 TYPE char40,
             t2 TYPE char40.
      mv_sfilename = p_file.
      CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
        EXPORTING
          filename                = mv_sfilename
          i_begin_col             = 1   "1. sutun
          i_begin_row             = 1   "2.satır başla
          i_end_col               = 96   "3. sutun
          i_end_row               = 1
        TABLES
          intern                  = lt_intern[] "bu tabloya aktar
        EXCEPTIONS
          inconsistent_parameters = 1
          upload_ole              = 2
          OTHERS                  = 3.
      LOOP AT lt_intern INTO ls_intern.
        SPLIT ls_intern-value AT '-' INTO : t1 t2.
        CONDENSE t1.
        READ TABLE csort INTO gs_csort WITH KEY fnam = t1.
        CHECK sy-subrc EQ 0.
        READ TABLE ssort INTO gs_ssort WITH KEY fnam = t1.
        CHECK sy-subrc NE 0 .
        APPEND gs_csort TO ssort.
        CLEAR : t1 , t2.
      ENDLOOP.

    ENDIF.

    IF p_pernr NE 'X' .
      MOVE : 'PERNR' TO gs_ssort-fnam ,
             'PERNR' TO gs_ssort-ftxt .
      APPEND gs_ssort TO ssort . CLEAR gs_ssort .
    ENDIF .
    me->create_fcat( )  .
    me->create_dyn_table( ).
* excel'den verilerin okunması ..
    TYPES: BEGIN OF ty_table,
             field1 TYPE solix,
           END OF ty_table.

    DATA: wa_file_data TYPE string.
    DATA: lv_line  TYPE solix,
          gt_table TYPE TABLE OF ty_table,
          gs_table TYPE ty_table.
    DATA: it_solix TYPE solix_tab.
*   excel'den verilerin okunması ..
    IF p_infty NE '2001'.
      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
        EXPORTING
          i_field_seperator    = 'X'
          i_line_header        = 'X'
          i_tab_raw_data       = raw
          i_filename           = p_file
        TABLES
          i_tab_converted_data = <dyn_table>
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.
    ELSE.
      DATA: lt_2001  TYPE TABLE OF kcde_cells,
            ld_index TYPE         i,
            lv_type  TYPE         c,
            lv_string1 TYPE string           ,
            lv_string2 TYPE string           ,
            lv_string3 TYPE string           ,
            lv_fname   TYPE rlgrap-filename  ,
            lv_length  TYPE i                ,
            lv_decimal TYPE p LENGTH 10 DECIMALS 2.
      CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
        EXPORTING
          filename                = p_file
          i_begin_col             = 1
          i_begin_row             = 1
          i_end_col               = 256
          i_end_row               = 65536
        TABLES
          intern                  = lt_2001
        EXCEPTIONS
          inconsistent_parameters = 1
          upload_ole              = 2
          OTHERS                  = 3.
      IF lt_2001[] IS INITIAL.
        CHECK 1 EQ 2.
      ELSE.
        SORT lt_2001 BY row col.
        DELETE lt_2001 WHERE row EQ 1.
      ENDIF.
      "Tolga

*    ASSIGN lt_2001 to <dyn_table>.
      LOOP AT lt_2001 ASSIGNING <f1>.
        MOVE sy-tabix TO ld_index.
*     ASSIGN COMPONENT ld_index OF STRUCTURE <f1> TO <fs>.
*
        REPLACE ALL OCCURRENCES OF ':' IN <f1> WITH ''.
        ASSIGN COMPONENT ld_index OF STRUCTURE <wa> TO <fs>.
        IF <f1>-value+2(1) EQ '.'.
          CONCATENATE <f1>-value+6(4) <f1>-value+3(2) <f1>-value+0(2)
          INTO <fs>.
        ELSE.
          <fs> = <f1>-value.
        ENDIF.
        AT END OF row.
          ASSIGN COMPONENT 'BEGUZ' OF STRUCTURE <wa> TO <fs1>.
          ASSIGN COMPONENT 'ENDUZ' OF STRUCTURE <wa> TO <fs2>.
          IF <fs1> IS NOT INITIAL AND <fs2> IS NOT INITIAL.
            DATA : lv_p TYPE p DECIMALS 2.

            lv_p = <fs2>+0(2) - <fs1>+0(2).

            ASSIGN COMPONENT 'ABRTG' OF STRUCTURE <wa> TO <fs1>.
            <fs1> = lv_p / 9.
          ENDIF.
          APPEND <wa> TO <dyn_table>.
          CLEAR <wa>.
        ENDAT.
        MODIFY lt_2001 FROM <f1> INDEX sy-tabix.


      ENDLOOP.

    ENDIF.

  ENDMETHOD.                    "get_data

  METHOD handle_user_command_click1.

    DATA : return TYPE  bapireturn1,
           key    TYPE  bapipakey.

    FIELD-SYMBOLS : <pernr> TYPE any,
                    <begda> TYPE any,
                    <endda> TYPE any,
                    <infty> TYPE any,
                    <fs>    TYPE any,
                    <t_fs>  TYPE any,
                    <icon>  TYPE any,
                    <subt>  TYPE any.
    FIELD-SYMBOLS <fs_1> TYPE any.

    DATA : BEGIN OF lv_t006,
           pernr TYPE pa0000-pernr,
            begda TYPE pa0000-begda,
            endda TYPE pa0000-endda,
            END OF lv_t006.

    DATA : l_pernr TYPE bapip0001-pernr,
           l_begda TYPE p0000-begda,
           l_endda TYPE p0000-endda.
    DATA : lp41 TYPE p0041.
    DATA : a(30).

    DATA : lv_index TYPE sy-index.
    CLEAR lv_index.
    DO.
      lv_index = lv_index + 1.
      READ TABLE <dyn_table> ASSIGNING <wa> INDEX lv_index.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
*
      ASSIGN ('<WA>-PERNR')   TO <pernr> .
      ASSIGN ('<WA>-BEGDA')   TO <begda> .
      ASSIGN ('<WA>-ENDDA')   TO <endda> .
      ASSIGN ('<WA>-MESSAGE') TO <fs>    .
      ASSIGN ('<WA>-ICON')    TO <icon>  .
      ASSIGN ('<WA>-SUBTY')   TO <subt>  .
      IF <pernr> EQ '00000000' .
        <fs>   = 'Personel Numarası Bulunamadı' .
        <icon> = '@0A@'                         .
      ELSE .
        l_pernr = <pernr> .
        l_begda = <begda> .
        l_endda = <endda> .
* personel numarasını lock'lama ..
        CALL FUNCTION 'HR_EMPLOYEE_ENQUEUE'
          EXPORTING
            number = l_pernr
          IMPORTING
            return = return.
        IF return-message IS INITIAL .

          CONCATENATE 'P' p_infty  INTO a.
          ASSIGN (a) TO <t_fs>.
          DATA : lv_pernr TYPE persno.
          MOVE-CORRESPONDING <wa> TO <t_fs>.
          IF p_infty EQ '0041'.
            CLEAR lp41.
            PERFORM batch_41 USING l_pernr
                             CHANGING lp41.
            MOVE-CORRESPONDING lp41 TO <t_fs>.
            IF lp41-begda IS INITIAL."kayıt bulamamıştır
              MOVE-CORRESPONDING <wa> TO <t_fs>.
            ENDIF.
          ELSEIF p_infty EQ '0021'.
            DATA : lv_modify TYPE pa0021.
            SELECT SINGLE * FROM pa0021
                                        INTO lv_modify
                                        WHERE pernr = <pernr>
                                        AND   subty = <subt>.
          ELSEIF p_infty EQ '0006'.
            SELECT SINGLE pernr begda endda FROM pa0006
         INTO lv_t006 WHERE pernr = <pernr>
                         AND subty = <subt>.
            IF lv_t006-pernr IS NOT INITIAL .
              ASSIGN COMPONENT 'BEGDA' OF STRUCTURE <t_fs> TO <fs_1>.
              <fs_1> = lv_t006-begda.
              UNASSIGN <fs_1>.
              ASSIGN COMPONENT 'ENDDA' OF STRUCTURE <t_fs> TO <fs_1>.
              <fs_1> = lv_t006-endda.
              UNASSIGN <fs_1>.
            ENDIF.
          ELSEIF p_infty EQ '0081'.
            SELECT SINGLE pernr FROM pa0081 INTO lv_pernr
                                  WHERE pernr EQ <pernr>.
            IF lv_pernr IS NOT INITIAL.
              DELETE FROM  pa0081 WHERE pernr EQ lv_pernr.
              "Şahsa ait tek kayıt olacak.
              COMMIT WORK AND WAIT .
            ENDIF.
          ELSEIF p_infty EQ '2001'.
            DATA: ls_2001 TYPE pa2001.
            MOVE-CORRESPONDING <t_fs> TO ls_2001.
            REPLACE ALL OCCURRENCES OF ':' IN ls_2001-beguz WITH ''.
            REPLACE ALL OCCURRENCES OF ':' IN ls_2001-enduz WITH ''.
            MOVE-CORRESPONDING ls_2001 TO <t_fs>.
          ELSEIF p_infty EQ '2006'.
            DATA :ls_2006 TYPE pa2006.
            MOVE-CORRESPONDING <t_fs> TO ls_2006.
            IF ls_2006-subty IS INITIAL.
              ls_2006-subty = ls_2006-ktart.
              MOVE-CORRESPONDING ls_2006 TO <t_fs> .
            ENDIF.
          ENDIF.
          DATA lv_operator TYPE pspar-actio.

          IF lv_modify IS INITIAL.
            lv_operator = 'INS'.
          ELSE.
            lv_operator = 'UPD'.
          ENDIF.

          CONCATENATE 'P' p_infty '-INFTY' INTO a.
          ASSIGN (a) TO <infty>.
          <infty> = p_infty.
          CLEAR return.

          CALL FUNCTION 'HR_INFOTYPE_OPERATION'
            EXPORTING
              infty         = p_infty
              number        = l_pernr
              validityend   = l_begda
              validitybegin = l_endda
              record        = <t_fs>
              operation     = lv_operator
*             tclas         = 'A'
              dialog_mode   = dmode
            IMPORTING
              return        = return
              key           = key.
          CLEAR : lv_operator.
          IF return-message IS INITIAL .
            IF lv_modify IS INITIAL.
              <fs>   = 'Kayıt Başarılı' .
              <icon> = '@08@'           .
              IF  p_infty EQ '0081'.
                DATA : ls_81 TYPE pa0081.
                MOVE-CORRESPONDING <t_fs> TO ls_81.
                TRY .
                    UPDATE pa0081 SET wdein = ls_81-wdein
                                   wdgrd = ls_81-wdgrd
                                  WHERE pernr EQ ls_81-pernr.
                  CATCH cx_root.

                ENDTRY.
              ENDIF.
            ELSE.
              <fs>   = 'Kayıt Güncellendi' .
              <icon> = '@0Z@'           .
            ENDIF.
          ELSE.
            <fs> = return-message .
            <icon> = '@0A@'       .

          ENDIF .
* personel numarasının lock'ını kaldırma ..
          CALL FUNCTION 'HR_EMPLOYEE_DEQUEUE'
            EXPORTING
              number = l_pernr.
        ELSE.
          <fs> = return-message .
          <icon> = '@0A@'       .
        ENDIF .
      ENDIF .
      MODIFY <dyn_table> FROM <wa> INDEX lv_index .
    ENDDO.

  ENDMETHOD.                    "handle_user_command_click1

  METHOD create_layout.
*
    gs_layout-zebra      = 'X'     .
    gs_layout-box_fname  = 'MARK'  .
    gs_layout-sel_mode   = 'A'     .
* Optimize Ayarı
    gs_layout-cwidth_opt = 'X'     .
* Toolbar Gizleme9
    gs_layout-no_toolbar = 'X'     .

  ENDMETHOD.                    "create_layout

  METHOD alv_initial.

    IF gr_alvgrid IS INITIAL .
      me->create_alv_from_container( ).
      me->display_alv( ).

    ELSE.
      me->display_alv( ).
      me->refresh_container_alv( ).
    ENDIF.

  ENDMETHOD.                    "alv_initial

  METHOD create_alv_from_container.

    CREATE OBJECT gr_ccontainer
      EXPORTING
        container_name              = gc_cname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

*----Creating ALV Grid instance
    CREATE OBJECT gr_alvgrid
      EXPORTING
        i_parent          = gr_ccontainer
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

  ENDMETHOD.                    "create_alv_from_container

  METHOD display_alv.

    gv_variante-report = sy-repid .

    CALL METHOD gr_alvgrid->set_table_for_first_display
      EXPORTING
        is_variant                    = gv_variante
        i_save                        = 'X'
        is_layout                     = gs_layout
*       it_toolbar_excluding          = gt_exclude
      CHANGING
        it_outtab                     = <dyn_table>
        it_fieldcatalog               = gt_fcat[]
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

  ENDMETHOD.                    "display_alv

  METHOD refresh_container_alv.

    CALL METHOD cl_gui_cfw=>flush.
    CALL METHOD gr_alvgrid->refresh_table_display.

  ENDMETHOD.                    "refresh_container_alv
ENDCLASS .                    "alv_class IMPLEMENTATION
