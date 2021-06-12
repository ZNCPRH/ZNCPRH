*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P042_I003
*&---------------------------------------------------------------------*

class class DEFINITION.
  PUBLIC SECTION.
    METHODS : selects,
              pj01_fieldcatalog,
              container_alv,
              pj01_alv,

              pj01r_fieldcatalog,
              pj01r_alv,
              update_pj01r_dates,
              change_pj01r_data,
              exclude_functions,
              switch_edit_pj01r,
              handle_double_click
                             FOR EVENT double_click OF cl_gui_alv_grid
                                      IMPORTING
                                      e_column
                                      es_row_no
                                      sender,
              hotspot_click  FOR EVENT hotspot_click
                                      OF cl_gui_alv_grid
                                      IMPORTING
                                      e_row_id
                                      e_column_id,
              handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
                                      IMPORTING
                                      e_object
                                      e_interactive,
              handle_user_command
                             FOR EVENT user_command OF cl_gui_alv_grid
                                      IMPORTING
                                      e_ucomm,
              handle_data_changed
                             FOR EVENT data_changed OF cl_gui_alv_grid
                                      IMPORTING
                                      er_data_changed,
              handle_data_changed_finished
                             FOR EVENT data_changed_finished OF
                                      cl_gui_alv_grid
                                      IMPORTING
                                      e_modified
                                      et_good_cells.
ENDCLASS.

CLASS class IMPLEMENTATION.
  METHOD selects. "Select İşlemleri
    SELECT pjid pjnm FROM /BNT/PJ01 INTO CORRESPONDING FIELDS OF TABLE
                          gt_pj01 WHERE pjid IN s_pjid.
    SELECT domvalue_l ddtext FROM dd07v INTO TABLE gt_rltp
                            WHERE domname = '/BNT/RLTP' AND
                                  ddlanguage = 'T'.
    SELECT pernr ename FROM pa0001 INTO TABLE gt_ename.

  ENDMETHOD.

  METHOD pj01_fieldcatalog. "PJ01 İçin Fieldcatalog
    CLEAR :  gs_fcat_pj01, gt_fcat_pj01, gs_layout.
    gs_fcat_pj01-FIELDNAME = 'PJID'.
    gs_fcat_pj01-TABNAME = '/BNT/PJ01'.
    gs_fcat_pj01-SELTEXT = 'Proje ID'.
    gs_fcat_pj01-REPTEXT = 'Proje ID'.
    gs_fcat_pj01-KEY = 'X'.
    gs_fcat_pj01-HOTSPOT = 'G'.  "PJID İçin Hotspot
    APPEND gs_fcat_pj01 TO gt_fcat_pj01.
    CLEAR gs_fcat_pj01.

    gs_fcat_pj01-FIELDNAME = ' PJNM'.
    gs_fcat_pj01-TABNAME = '/BNT/PJ01'.
    gs_fcat_pj01-SELTEXT = 'Proje Açıklaması'.
    gs_fcat_pj01-REPTEXT = 'Proje Açıklaması'.
    APPEND gs_fcat_pj01 TO gt_fcat_pj01.
    CLEAR gs_fcat_pj01.

    gs_layout-CWIDTH_OPT = 'X'.

  ENDMETHOD.

  METHOD pj01r_fieldcatalog. "PJ01R İçin Fieldcatalog
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME = '/BNT/PJ01R'
      CHANGING
        CT_FIELDCAT      = gt_fcat_pj01r.

    gs_fcat_pj01r-FIELDNAME = 'ENAME'.
    gs_fcat_pj01r-SELTEXT = 'Personelin Adı ve Soyadı'.
    gs_fcat_pj01r-REPTEXT = 'Personelin Adı ve Soyadı'.
    gs_fcat_pj01r-COL_POS = '4'.
    APPEND gs_fcat_pj01r to gt_fcat_pj01r.
    CLEAR gs_fcat_pj01r.

    gs_fcat_pj01r-FIELDNAME = 'RLTP_DDTEXT'.
    gs_fcat_pj01r-SELTEXT = 'Rol Tipi Açıklaması'.
    gs_fcat_pj01r-REPTEXT = 'Rol Tipi Açıklaması'.
    gs_fcat_pj01r-COL_POS = '6'.
    APPEND gs_fcat_pj01r to gt_fcat_pj01r.
    CLEAR gs_fcat_pj01r.

    gs_fcat_pj01r-FIELDNAME = 'ENDDATE_REFRESH'.
    gs_fcat_pj01r-SELTEXT = 'Tarih Güncelleme Kontrolü'.
    gs_fcat_pj01r-REPTEXT = 'Tarih Güncelleme Kontrolü'.
    gs_fcat_pj01r-CHECKBOX = 'X'.
    gs_fcat_pj01r-COL_POS = '1'.
    APPEND gs_fcat_pj01r to gt_fcat_pj01r.
    CLEAR gs_fcat_pj01r.

    LOOP AT gt_fcat_pj01r INTO gs_fcat_pj01r.
      IF gs_fcat_pj01r-FIELDNAME ne 'ENAME' AND
         gs_fcat_pj01r-FIELDNAME ne 'RLTP_DDTEXT'.
        gs_fcat_pj01r-EDIT = 'X'.
        MODIFY gt_fcat_pj01r FROM gs_fcat_pj01r.
        CLEAR gs_fcat_pj01r.
      ENDIF.
    ENDLOOP.

    gs_refresh-row = 'X'.
    gs_refresh-col = 'X'.

  ENDMETHOD.

  METHOD exclude_functions.

    gs_exclude_pj01 = cl_gui_alv_grid=>MC_FC_INFO.
    APPEND gs_exclude_pj01 TO gt_exclude_pj01.
    CLEAR gs_exclude_pj01.

    gs_exclude_pj01 = cl_gui_alv_grid=>MC_MB_SUM.
    APPEND gs_exclude_pj01 TO gt_exclude_pj01.
    CLEAR gs_exclude_pj01.

*--------------------------------------------------------------------*

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_APPEND_ROW.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_UNDO.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_DELETE_ROW.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_INSERT_ROW.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_PASTE.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_COPY.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_COPY_ROW.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_DETAIL.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_PRINT.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_CUT.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_LOC_PASTE_NEW_ROW.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_TO_OFFICE.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_VIEWS.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_MB_EXPORT.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_MB_VARIANT.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_FIND_MORE.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_FILTER.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_FIND.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_REFRESH.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_SEND.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_INFO.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_GRAPH.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_MB_SUM.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.
*
    gs_exclude_pj01r = cl_gui_alv_grid=>MC_MB_SUBTOT.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

    gs_exclude_pj01r = cl_gui_alv_grid=>MC_FC_PC_FILE.
    APPEND gs_exclude_pj01r TO gt_exclude_pj01r.
    CLEAR gs_exclude_pj01r.

  ENDMETHOD.

  METHOD container_alv. "Konteynırı Parçalama

    CREATE OBJECT gr_custom_container
      EXPORTING
        container_name = 'CONTAINER'.
    CREATE OBJECT gr_splitter
      EXPORTING
        ALIGN   = 15    " Alignment
        PARENT  = gr_custom_container    " Parent Contai
        ROWS    = 1   " Number of Rows to be display
        COLUMNS = 2.   " Number of Columns to be Display

    CALL METHOD gr_splitter->get_container
      EXPORTING
        ROW       = 1   " Row
        COLUMN    = 1   " Column
      RECEIVING
        CONTAINER = gr_pj01_container.    " Container

    CALL METHOD gr_splitter->get_container
      EXPORTING
        ROW       = 1  " Row
        COLUMN    = 2    " Column
      RECEIVING
        CONTAINER = gr_pj01r_container.    " Container

    CALL METHOD gr_splitter->set_column_width
      EXPORTING
        ID    = 1    " Column ID
        WIDTH = '42'.  " NPlWidth

  ENDMETHOD.

  METHOD pj01_alv. "PJ01 İçin Grid Alv

    CREATE OBJECT gr_pj01_grid
      EXPORTING
        I_PARENT = gr_pj01_container.

    CALL METHOD gr_pj01_grid->set_table_for_first_display
      EXPORTING
        IS_LAYOUT            = gs_layout    " Layout
        IT_TOOLBAR_EXCLUDING = gt_exclude_pj01
      CHANGING
        IT_OUTTAB            = gt_pj01    " Output Table
        IT_FIELDCATALOG      = gt_fcat_pj01.     " Field Catalog

    SET HANDLER cl->hotspot_click            FOR gr_pj01_grid.

  ENDMETHOD.

  METHOD hotspot_click. "PJ01 İçin Hotspotu Yakalama

    CLEAR: gs_pj01, gt_pj01r_alv, gt_pj01r.

    READ TABLE gt_pj01 INTO gs_pj01 INDEX E_ROW_ID-INDEX.

    SELECT * FROM /BNT/PJ01R INTO CORRESPONDING FIELDS OF TABLE
                             gt_pj01r WHERE pjid EQ gs_pj01-pjid.
    LOOP AT gt_pj01r INTO gs_pj01r.
      MOVE-CORRESPONDING gs_pj01r TO gs_pj01r_alv.
      READ TABLE gt_ename INTO gs_ename WITH KEY
                                  pernr = gs_pj01r_alv-BPID.
      gs_pj01r_alv-ENAME = gs_ename-ename.
      READ TABLE gt_rltp INTO gs_rltp WITH KEY
                                 domvalue_l = gs_pj01r_alv-RLTP.
      gs_pj01r_alv-RLTP_DDTEXT = gs_rltp-DDTEXT.
      APPEND gs_pj01r_alv TO gt_pj01r_alv.
      CLEAR : gs_pj01r_alv, gs_rltp, gs_ename.
    ENDLOOP.

    cl->PJ01R_ALV( ).
  ENDMETHOD.

  METHOD handle_toolbar. "PJ01R Toolbar'ı İçin Buton
    CLEAR gs_toolbar.
    MOVE 3 TO gs_toolbar-BUTN_TYPE.
    APPEND gs_toolbar to e_object->MT_TOOLBAR.

    CLEAR gs_toolbar.
    MOVE 'EDIT' TO gs_toolbar-function.
    MOVE 'Görüntüle <-> Değiştir'(111) TO gs_toolbar-QUICKINFO.
*    MOVE 'Değiştir'(112) TO gs_toolbar-text.
    MOVE ICON_TOGGLE_DISPLAY_CHANGE to gs_toolbar-ICON.
    MOVE ' ' TO gs_toolbar-DISABLED.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 'SAVE' TO gs_toolbar-function.
    MOVE 'Verileri Kaydet'(111) TO gs_toolbar-QUICKINFO.
*    MOVE 'Kaydet'(112) TO gs_toolbar-text.
    MOVE ICON_SYSTEM_SAVE to gs_toolbar-ICON.
    MOVE ' ' TO gs_toolbar-DISABLED.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    MOVE 'DATES' TO gs_toolbar-function.
    MOVE 'Bitiş Tarihini Güncelle'(111) TO gs_toolbar-QUICKINFO.
*    MOVE 'Bitiş Tarihi Güncelle'(112) TO gs_toolbar-text.
    MOVE ICON_DATE to gs_toolbar-ICON.
    MOVE ' ' TO gs_toolbar-DISABLED.
    APPEND gs_toolbar TO e_object->mt_toolbar.



  ENDMETHOD.

  METHOD pj01r_alv. "PJ01R Alv

    IF gr_pj01r_grid IS INITIAL.

      CREATE OBJECT gr_pj01r_grid
        EXPORTING
          I_PARENT = gr_pj01r_container.

      CALL METHOD gr_pj01r_grid->set_table_for_first_display
        EXPORTING
          IS_LAYOUT            = gs_layout
          IT_TOOLBAR_EXCLUDING = gt_exclude_pj01r
        CHANGING
          IT_OUTTAB            = gt_pj01r_alv     " Output
          IT_FIELDCATALOG      = gt_fcat_pj01r.    " Field

      SET HANDLER cl->handle_user_command          FOR gr_pj01r_grid.
      SET HANDLER cl->handle_toolbar               FOR gr_pj01r_grid.
      SET HANDLER cl->handle_data_changed          FOR gr_pj01r_grid.
      SET HANDLER cl->handle_data_changed_finished FOR gr_pj01r_grid.
      SET HANDLER cl->handle_double_click          FOR gr_pj01r_grid.

      gr_pj01r_grid->activate_display_protocol( space ).

      CALL METHOD gr_pj01r_grid->set_ready_for_input
        EXPORTING
          i_ready_for_input = 0.

      CALL METHOD gr_pj01r_grid->register_edit_event
        EXPORTING
          I_EVENT_ID = cl_gui_alv_grid=>mc_evt_modified.    " Event ID

      CALL METHOD gr_pj01r_grid->set_toolbar_interactive.

    ELSE.

      CALL METHOD gr_pj01r_grid->refresh_table_display
        EXPORTING
          IS_STABLE = gs_refresh.   " With Stable Rows/Columns

    ENDIF.

  ENDMETHOD.

  METHOD handle_data_changed.

    DATA : ls_mod_cell TYPE lvc_s_modi.

    FIELD-SYMBOLS: <fs_table> TYPE table.

    IF er_data_changed->mt_mod_cells IS NOT INITIAL.
      LOOP AT er_data_changed->mt_mod_cells INTO ls_mod_cell
                              WHERE FIELDNAME EQ 'RLTP' OR
                                    FIELDNAME EQ 'BPID'.
        gv_pj01r_fname = ls_mod_cell-FIELDNAME.
        ASSIGN er_data_changed->mp_mod_rows->* TO <fs_table>.

        READ TABLE <fs_table> INTO gs_pj01r_alv INDEX sy-tabix.

        READ TABLE gt_ename INTO gs_ename
                        WITH KEY pernr = gs_pj01r_alv-BPID.
        gs_pj01r_alv-ENAME = gs_ename-ename.

        READ TABLE gt_rltp INTO gs_rltp
                       WITH KEY domvalue_l = gs_pj01r_alv-RLTP.
        gs_pj01r_alv-RLTP_DDTEXT = gs_rltp-DDTEXT.

        MODIFY gt_pj01r_alv INDEX ls_mod_cell-row_id
                             FROM gs_pj01r_alv
                     TRANSPORTING RLTP_DDTEXT
                                  ename.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.

        CLEAR : gs_pj01r_alv, gs_rltp, gs_ename.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD handle_data_changed_finished.

    CHECK gv_pj01r_fname EQ 'RLTP' OR
          gv_pj01r_fname EQ 'BPID'.
    CLEAR gv_pj01r_fname.

    cl->pj01r_alv( ).


  endmethod.

  METHOD handle_user_command. "PJ01R Toolbar Butonunu Yakalama
    CASE e_ucomm.
      WHEN 'SAVE'.
        cl->change_pj01r_data( ).
      WHEN 'DATES'.
        cl->update_pj01r_dates( ).
      WHEN 'EDIT'.
        cl->switch_edit_pj01r( ).
    ENDCASE.
  ENDMETHOD.

  METHOD handle_double_click.

    IF e_column-fieldname EQ 'ENDDATE_REFRESH' AND
      gr_pj01r_grid->is_ready_for_input( ) EQ 1.
      LOOP AT gt_pj01r_alv INTO gs_pj01r_alv.
        IF gs_pj01r_alv-enddate_refresh EQ ''.
          gs_pj01r_alv-enddate_refresh = 'X'.
        ELSE.
          gs_pj01r_alv-enddate_refresh = ''.
        ENDIF.
        MODIFY gt_pj01r_alv INDEX sy-tabix FROM gs_pj01r_alv
                                         TRANSPORTING enddate_refresh.
        CLEAR gs_pj01r_alv.
      ENDLOOP.
      cl->pj01r_alv( ).
    ENDIF.

  ENDMETHOD.
  METHOD switch_edit_pj01r.

    if gr_pj01r_grid->is_ready_for_input( ) eq 0.
* set edit enabled cells ready for input
      CALL METHOD gr_pj01r_grid->set_ready_for_input
        EXPORTING
          i_ready_for_input = 1.
    else.
* lock edit enabled cells against input
      CALL METHOD gr_pj01r_grid->set_ready_for_input
        EXPORTING
          i_ready_for_input = 0.
    endif.

  ENDMETHOD.

  METHOD update_pj01r_dates.


    CALL FUNCTION 'F4_DATE'
      IMPORTING
        SELECT_DATE = gv_pj01r_date.   " selected date


    LOOP AT gt_pj01r_alv INTO gs_pj01r_alv.

      IF gs_pj01r_alv-enddate_refresh EQ 'X'.
        gs_pj01r_alv-enddt = gv_pj01r_date.
        MODIFY gt_pj01r_alv INDEX sy-tabix FROM gs_pj01r_alv
                                   TRANSPORTING enddt .
      ENDIF.
      CLEAR gs_pj01r_alv.
    ENDLOOP.

    cl->pj01r_alv( ).

  ENDMETHOD.

  METHOD change_pj01r_data. "Değiştirilen Datayı DB'ye Aktarma

    CALL METHOD gr_pj01r_grid->check_changed_data.

    DELETE /BNT/PJ01R FROM TABLE gt_pj01r.

    LOOP AT gt_pj01r_alv INTO gs_pj01r_alv.
      MOVE-CORRESPONDING gs_pj01r_alv TO gs_pj01r.
      INSERT /BNT/PJ01R FROM gs_pj01r.
      APPEND gs_pj01r TO gt_pj01r.
      DELETE gt_pj01r INDEX 1.
      CLEAR gs_pj01r.
    ENDLOOP.


    IF sy-subrc = 0.
      COMMIT WORK.
      MESSAGE 'Yapılan Değişiklikler Başarıyla Kaydedildi' TYPE 'I'
                                                   DISPLAY LIKE 'S'.
    ELSE.
      ROLLBACK WORK.
      MESSAGE 'Veriler Kaydedilemedi!' TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
