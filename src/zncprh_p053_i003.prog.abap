*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P053_I003
*&---------------------------------------------------------------------*
CLASS lcl_main IMPLEMENTATION.
  METHOD get_data.

    DATA : lt_out   TYPE TABLE OF z0445_s001.

    SELECT '@00@' AS icon,
           mara~matnr,
           mara~ersda,
           mara~ernam,
           mara~laeda ,
           mara~aenam,
           mara~vpsta,
           mara~matkl,
           mara~mtart
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE @lt_out
      WHERE matnr IN @s_matnr.

    gt_out = VALUE #(
     FOR ls_out IN lt_out
                     (  icon = ls_out-icon
                        matnr = ls_out-matnr
                        ersda = ls_out-ersda
                        ernam = ls_out-ernam
                        laeda = ls_out-laeda
                        aenam = ls_out-aenam
                        vpsta = ls_out-vpsta
                        matkl = ls_out-matkl
                        mtart = ls_out-mtart
                        line_color =  COND #( WHEN ls_out-mtart = 'FERT' THEN 'C510' ELSE space )
                        colortab = COND #( WHEN ls_out-mtart = 'HAWA' THEN
                                   VALUE #( ( fname = 'MATNR'
                                              color-col = 1
                                              color-int = 1
                                              color-inv = 1
                                            )
                                          )
                                         )

                      )
                    ).

  ENDMETHOD.

  METHOD container_alv.
    me->alv_initialization(
                   EXPORTING  iv_tabnam = iv_tabnam iv_strucnam = iv_strucnam ).
  ENDMETHOD.                    "container_alv

  METHOD create_layout.

    ch_layout =
     VALUE #(  cwidth_opt = 'X'
               zebra      = 'X'
               sel_mode   = 'D'
               ctab_fname  = 'COLORTAB'
               info_fname = 'LINE_COLOR'
              "excp_led = 'X'
              "excp_fname = 'IZLEME'
              "stylefname = 'CELLTAB'
              "edit       = 'X'
              "stylefname  = 'CELLSTYLE'
              "excp_rolln = 'LVC_EXROL'
              "lights_tabname  = 'I_LIGHTS'
              "no_toolbar = 'X' "toolbar yokoldu
              "no_keyfix  = 'X' "scrol özelliği kazandı
            ).
  ENDMETHOD.                    "create_layout

  METHOD alv_initialization.
    DATA : lt_exclude TYPE ui_functions.
    DATA(ls_layout) = me->create_layout( ).

    IF gc_alvgrid IS INITIAL.
      me->create_alv_from_container( ).
      me->exclude_tb_functions( CHANGING ct_exc = lt_exclude ).
      me->set_container_alv_properties( ).

      CALL METHOD g_object->display_alv(
        EXPORTING
          iv_tabnam   = iv_tabnam
          iv_strucnam = iv_strucnam
          iv_layout   = ls_layout
          it_exclude  = lt_exclude ).

*      CALL METHOD gc_alvgrid->register_edit_event
*        EXPORTING
**         i_event_id = cl_gui_alv_grid=>mc_evt_modified."Change event
*          i_event_id = cl_gui_alv_grid=>mc_evt_enter."Enter event

    ELSE.
      me->exclude_tb_functions( CHANGING ct_exc = lt_exclude ).
      me->set_container_alv_properties( ).
      g_object->display_alv(
                  EXPORTING iv_tabnam   = iv_tabnam
                            iv_strucnam = iv_strucnam
                            iv_layout   = ls_layout
                            it_exclude  = lt_exclude ).
      me->refresh_table( ).
    ENDIF.
  ENDMETHOD.                    "alv_initialization

  METHOD create_alv_from_container.
*    CREATE OBJECT gc_container
*      EXPORTING
*        container_name              = gc_cc_name "gv_cname
*      EXCEPTIONS
*        cntl_error                  = 1
*        cntl_system_error           = 2
*        create_error                = 3
*        lifetime_error              = 4
*        lifetime_dynpro_dynpro_link = 5
*        OTHERS                      = 6.

    CREATE OBJECT gc_alvgrid
      EXPORTING
*       i_parent          = gc_container
        i_parent          = cl_gui_container=>screen0
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
  ENDMETHOD.                    "create_alv_from_container

  METHOD exclude_tb_functions.
** Ekranda görünmesini istemediğimiz butonları ekleriz.
    APPEND :
     cl_gui_alv_grid=>mc_fc_graph             TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_info              TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_print_back        TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_copy_row      TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_copy          TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_insert_row    TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_append_row    TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_cut           TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_delete_row    TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_paste         TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO  ct_exc  ,
*   cl_gui_alv_grid=>mc_mb_view              TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_loc_undo          TO  ct_exc  ,
     cl_gui_alv_grid=>mc_fc_print             TO  ct_exc  ,
*   cl_gui_alv_grid=>mc_fc_find_more         TO  ct_exc ,
*   cl_gui_alv_grid=>mc_mb_filter            TO  ct_exc ,
*   cl_gui_alv_grid=>mc_fc_sum               TO  ct_exc ,
*   cl_gui_alv_grid=>mc_mb_sum               TO  ct_exc ,
*   cl_gui_alv_grid=>mc_fc_sort_asc          TO  ct_exc ,
*   cl_gui_alv_grid=>mc_fc_sort_dsc          TO  ct_exc ,
*   cl_gui_alv_grid=>mc_fc_find              TO  ct_exc ,
*   cl_gui_alv_grid=>mc_fc_subtot            TO  ct_exc ,
*   cl_gui_alv_grid=>mc_mb_export            TO  ct_exc ,
     cl_gui_alv_grid=>mc_fc_info              TO  ct_exc ,
*   cl_gui_alv_grid=>mc_fc_views             TO  ct_exc ,
*   cl_gui_alv_grid=>mc_mb_variant           TO  ct_exc ,
     cl_gui_alv_grid=>mc_fc_detail            TO  ct_exc .
  ENDMETHOD.                    "exclude_tb_functions

  METHOD set_container_alv_properties.
    SET HANDLER me->handle_user_command  FOR gc_alvgrid.
    SET HANDLER me->handle_toolbar       FOR gc_alvgrid.
    SET HANDLER me->handle_data_changed  FOR gc_alvgrid.
    SET HANDLER me->handle_double_click  FOR gc_alvgrid.
    SET HANDLER me->handle_hotspot_click FOR gc_alvgrid.
    SET HANDLER me->handle_top_of_page   FOR gc_alvgrid.

  ENDMETHOD.                    "set_container_alv_properties

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'SAVE'.
**Kayıt atma bapi çalıştırma vs işlemleri burada yapılır.
**İşleme göre buton ismi handle_toolbar üzerinden değiştirilebilir
        DATA(rt_rows) = me->get_selected_rows( ).
        LOOP AT rt_rows INTO DATA(ls_rows).
          TRY.
              DATA(ls_out) = gt_out[ ls_rows-index ].
**>İşlem sonucuna göre GT_LOG dolduruluyor
**Log dolduruken kullanılan parametreler
**hardcode olmayacak bapiden dönen parametreler ile dolacak
              ls_out-icon       = '@8O@'.
              APPEND VALUE #( type = 'E'
                              id   = '00'
                              number     = 001
                              message_v1 = 'İşlem başarısız'
                              matnr      = ls_out-matnr
                              ) TO gt_log.
**<
              MODIFY gt_out FROM ls_out INDEX ls_rows-index TRANSPORTING icon.
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
        ENDLOOP.
    ENDCASE.
    me->refresh_table( ).
  ENDMETHOD.                    "on_user_command

  METHOD handle_data_changed.

    TRY.
        DATA(ls_good_cells) = er_data_changed->mt_good_cells[ fieldname = 'MTART' ].

*        TRY.
*            DATA(ls_out) = gt_out[ ls_good_cells-row_id ].
*          CATCH cx_sy_itab_line_not_found.
*            RETURN.
*        ENDTRY.

        er_data_changed->modify_cell(
          EXPORTING
            i_row_id    = ls_good_cells-row_id       " Row ID
            i_tabix     = ls_good_cells-tabix        " Row Index
            i_fieldname = ls_good_cells-fieldname    " Field Name
            i_value     = ls_good_cells-value
        ).
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

*    er_data_changed->add_protocol_entry(
*      EXPORTING
*        i_msgid     = '00'    " Message ID
*        i_msgty     = 'W'    " Message Type
*        i_msgno     = '001'    " Message No.
**      i_msgv1     =     " Message Variable1
**      i_msgv2     =     " Message Variable2
**      i_msgv3     =     " Message Variable3
**      i_msgv4     =     " Message Variable4
*        i_fieldname = 'MTART'    " Field Name
*        i_row_id    = ls_good_cells-row_id    " RowID
*        i_tabix     = ls_good_cells-tabix    " Table Index
*    ).
  ENDMETHOD.

  METHOD handle_double_click.

    TRY.
        DATA(ls_out) = gt_out[ es_row_no-row_id ].
        IF e_column = 'ICON'.
          DATA(ls_handle) = me->open_log( ).
          me->close_and_show_log( iv_matnr  = ls_out-matnr
                                        is_handle = ls_handle ).
        ELSEIF e_column = 'MATNR'.
          IF ls_out-matnr  = '@00@'.
            MODIFY gt_out FROM ls_out INDEX es_row_no-row_id .
            me->refresh_table( ).
          ENDIF.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD handle_hotspot_click.
    IF e_column_id = 'MATNR'.
      TRY.
          DATA(ls_out) = gt_out[ e_row_id-index ].
          SET PARAMETER ID 'MAT' FIELD ls_out-matnr.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD refresh_table.
** Row,Col Stable
    DATA(ls_stbl) = VALUE lvc_s_stbl( row = 'X'
                                      col = 'X' ).

    gc_alvgrid->refresh_table_display(
      EXPORTING
        is_stable  =  ls_stbl   " With Stable Rows/Columns
    i_soft_refresh =  'X'   " Without Sort, Filter, etc.
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.                    "refresh_table

  METHOD display_alv.
    DATA : lv_name(100),
           ls_variant TYPE disvariant.

    FIELD-SYMBOLS <gt> TYPE table .


    CONCATENATE iv_tabnam '[]' INTO lv_name .
    ASSIGN (lv_name) TO <gt> .

    ls_variant-report = sy-repid.

    DATA(rt_fcat) = me->modify_fcat( iv_strucnam ).

    CALL METHOD gc_alvgrid->set_table_for_first_display
      EXPORTING
        is_variant                    = ls_variant
        i_save                        = 'X'
        is_layout                     = iv_layout
        it_toolbar_excluding          = it_exclude
      CHANGING
        it_outtab                     = <gt>
        it_fieldcatalog               = rt_fcat[]
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    CALL METHOD gc_alvgrid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.

*  For Editable alv...
    CALL METHOD gc_alvgrid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

  ENDMETHOD.                    "display_alv

  METHOD handle_toolbar.
    DATA: ls_toolbar TYPE stb_button.

    MOVE 0                    TO ls_toolbar-butn_type.
    MOVE 'SAVE'               TO ls_toolbar-function.   "buton fonksiyon kodu
    MOVE icon_system_save     TO ls_toolbar-icon.       "buton iconu
    MOVE 'Kaydet'             TO ls_toolbar-quickinfo.  "buton açıklama
    MOVE 'Kaydet'             TO ls_toolbar-text.       "buton adı
    MOVE ' '                  TO ls_toolbar-disabled.   "butonu kapatır
    APPEND ls_toolbar         TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_toolbar

  METHOD modify_fcat.
    DATA : lv_name_strc TYPE dd02l-tabname.

    lv_name_strc = iv_strucnam.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
*       i_buffer_active        = 'X'
        i_structure_name       = lv_name_strc
*       i_client_never_display = 'X'
*       i_bypassing_buffer     =
      CHANGING
        ct_fieldcat            = rt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    LOOP AT rt_fcat ASSIGNING FIELD-SYMBOL(<fs_cat>).
      <fs_cat>-col_opt   = abap_true.

      CASE <fs_cat>-fieldname.
        WHEN 'ICON'.
*          <fs_cat>-scrtext_s = 'Durum'(002).
*          <fs_cat>-scrtext_m = 'Durum'(002).
*          <fs_cat>-scrtext_l = 'Durum'(002).
*          <fs_cat>-reptext   = 'Durum'(002).
          <fs_cat>-key       = abap_true.
        WHEN 'MATNR'.
          <fs_cat>-hotspot = 'X'.
        WHEN 'MTART'.
          <fs_cat>-edit      = abap_true.
        WHEN OTHERS.
*          do nothing.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_selected_rows.
    CALL METHOD gc_alvgrid->get_selected_rows
      IMPORTING
        et_index_rows = rt_rows.

  ENDMETHOD.

  METHOD close_and_show_log.

    DATA : l_s_display_profile TYPE          bal_s_prof,
           l_fcat              TYPE          bal_s_fcat,
           lt_mess_fcat        TYPE TABLE OF bal_s_fcat,
           l_s_log_filter      TYPE bal_s_lfil.

*-- Gösterilecek Alanlar
    l_fcat-ref_table = 'BAL_S_SHOW'.
    l_fcat-ref_field = 'MSGNUMBER' .
    l_fcat-col_pos   =  1          .
    APPEND l_fcat TO lt_mess_fcat     .
    l_fcat-ref_field = 'T_MSG'     .
    l_fcat-col_pos   =  2          .
    APPEND l_fcat TO lt_mess_fcat     .

    MOVE : lt_mess_fcat[] TO l_s_display_profile-mess_fcat    .

*- Görüntü Katalogu
    l_s_display_profile-show_all   = 'X'.
    l_s_display_profile-title      = 'Günlükleri görüntüle'.
    l_s_display_profile-pop_adjst  = 'X' .
    l_s_display_profile-langu      = 'T' .
    l_s_display_profile-start_col  = 5   .
    l_s_display_profile-start_row  = 5   .
    l_s_display_profile-end_col    = 90  .
    l_s_display_profile-end_row    = 30  .


    LOOP AT gt_log INTO DATA(ls_log) WHERE matnr = iv_matnr.
      me->add_log_data( i_type        = ls_log-type
                              i_id          = ls_log-id
                              i_number      = ls_log-number
                              i_message_v1  = ls_log-message_v1
                              i_message_v2  = ls_log-message_v2
                              i_message_v3  = ls_log-message_v3
                              i_message_v4  = ls_log-message_v4
                              is_handle     = is_handle
                            ).
    ENDLOOP.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile = l_s_display_profile
        i_s_log_filter      = l_s_log_filter.

*   Log`u Sil.
    CALL FUNCTION 'BAL_LOG_DELETE'
      EXPORTING
        i_log_handle = is_handle
      EXCEPTIONS
        OTHERS       = 0.

  ENDMETHOD.

  METHOD open_log.

    DATA : ls_log TYPE bal_s_log.

    ls_log-aluser      = sy-uname.
    ls_log-extnumber   = 1.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log
      IMPORTING
        e_log_handle            = rs_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

  METHOD add_log_data.
    DATA :  ls_message TYPE bal_s_msg.

    MOVE : i_type       TO ls_message-msgty ,
           i_id         TO ls_message-msgid ,
           i_number     TO ls_message-msgno ,
           i_message_v1 TO ls_message-msgv1 ,
           i_message_v2 TO ls_message-msgv2 ,
           i_message_v3 TO ls_message-msgv3 ,
           i_message_v4 TO ls_message-msgv4 .

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = is_handle
        i_s_msg          = ls_message
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

  METHOD handle_top_of_page.

  ENDMETHOD.
ENDCLASS.                    "lcl_main IMPLEMENTATION
