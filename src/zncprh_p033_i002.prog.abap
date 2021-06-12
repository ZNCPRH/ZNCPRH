*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P033_I002
*&---------------------------------------------------------------------*

CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    CONSTANTS:
      gc_title1  TYPE string        VALUE 'Splitter',
      gc_tab_s82 TYPE dd02l-tabname VALUE 'ZNCPRH_S026',
      gc_tab_s83 TYPE dd02l-tabname VALUE 'ZNCPRH_S027',
      gc_repid   TYPE sy-repid      VALUE sy-repid.

    DATA: gs_layout_up    TYPE        lvc_s_layo,
          gs_layout_down  TYPE        lvc_s_layo,
          gc_scrfname     TYPE        scrfname VALUE 'CONT01',
          gref_alv_up     TYPE REF TO cl_gui_alv_grid,
          gref_alv_down   TYPE REF TO cl_gui_alv_grid,
          gc_container    TYPE REF TO cl_gui_custom_container,
          gs_variant_up   TYPE        disvariant,
          gs_variant_down TYPE        disvariant,
          g_cont_up       TYPE REF TO cl_gui_container,
          g_cont_down     TYPE REF TO cl_gui_container,
          g_splitter      TYPE REF TO cl_gui_splitter_container.

    DATA: gt_fcat_up        TYPE lvc_t_fcat,
          gt_fcat_down      TYPE lvc_t_fcat,
          gt_functions_up   TYPE ui_functions,
          gt_functions_down TYPE ui_functions.

    METHODS:set_initial,
      get_data,
      get_all_data IMPORTING delete_key TYPE boolean OPTIONAL,
      call_screen,
      create_layo_and_fcat  IMPORTING sname       TYPE dd02l-tabname
                                      celltab_key TYPE boolean OPTIONAL
                            CHANGING  layout      TYPE lvc_s_layo OPTIONAL
                                      fcat        TYPE lvc_t_fcat OPTIONAL,
      exculude_tb           CHANGING   functions     TYPE ui_functions,
      set_variant_options,
      display_alv           IMPORTING layout    TYPE lvc_s_layo
                                      variant   TYPE disvariant
                                      functions TYPE ui_functions
                            CHANGING  gref      TYPE REF TO cl_gui_alv_grid
                                      table     TYPE STANDARD TABLE
                                      fcat      TYPE lvc_t_fcat,
      refresh_screen IMPORTING key TYPE char1 OPTIONAL.

  PROTECTED SECTION.
    DATA : gc_green  TYPE icon-id      VALUE '@5B@',
           gc_red    TYPE icon-id      VALUE '@5C@',
           gc_dsr    TYPE icon-id      VALUE '@0J@', "Açıklama
           gc_init   TYPE icon-id      VALUE '@00@', "X kapat
           gc_ok     TYPE icon-id      VALUE '@01@', "seçildi
           gc_detail TYPE icon-id      VALUE '@16@', "detaylar
           gc_del    TYPE icon-id      VALUE '@11@', " sil
           gc_tgreen TYPE icon-id      VALUE '@08@',
           gc_tyel   TYPE icon-id      VALUE '@09@',
           gc_tred   TYPE icon-id      VALUE '@0A@',
           gc_prt    TYPE icon-id      VALUE '@0X@'.

  PRIVATE    SECTION.
    METHODS : create_cc,
      set_event,
      set_mod CHANGING  fcat        TYPE lvc_t_fcat,
      handle_toolbar_header        FOR EVENT toolbar      OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,
      handle_user_command_header FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      handle_data_changed          FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,
      hotspot_click_header        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id  es_row_no,
      hotspot_click_item        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id  es_row_no,
      handle_data_changed_finished FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING et_good_cells.

ENDCLASS.

CLASS lcl_report IMPLEMENTATION.
  METHOD set_initial.
    create_cc( ).
    set_event( ).
  ENDMETHOD.
  METHOD  create_cc.
    IF gc_container IS INITIAL."container objesini yaratma
      CREATE OBJECT gc_container
        EXPORTING
          container_name              = gc_scrfname "container adı
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.

      "Oluşturduğumuz Container'ı 2 satıra böldük.
      CREATE OBJECT g_splitter
        EXPORTING
          parent  = gc_container
          rows    = 2
          columns = 1.

      "ilksatır
      CALL METHOD g_splitter->get_container
        EXPORTING
          row       = 1
          column    = 1
        RECEIVING
          container = g_cont_up.
      "ikinci satır
      CALL METHOD g_splitter->get_container
        EXPORTING
          row       = 2
          column    = 1
        RECEIVING
          container = g_cont_down.

      "Gridlerini tanımladık.
      gref_alv_up   = NEW cl_gui_alv_grid( i_parent = g_cont_up ).
      gref_alv_down = NEW cl_gui_alv_grid( i_parent = g_cont_down ).

    ENDIF.
  ENDMETHOD.
  METHOD set_event.
    IF gref_alv_up IS NOT INITIAL..
      SET HANDLER : hotspot_click_header       FOR gref_alv_up.
      SET HANDLER : handle_toolbar_header      FOR gref_alv_up.
      SET HANDLER : handle_user_command_header FOR gref_alv_up.
    ENDIF.
    IF gref_alv_down IS NOT INITIAL.
      SET HANDLER : hotspot_click_item           FOR gref_alv_down.
      SET HANDLER : handle_data_changed_finished FOR gref_alv_down.
    ENDIF.
  ENDMETHOD.
  METHOD get_data.

    SELECT '@00@' AS check,
        t02~*,t03~*
      FROM zncprh_t002 AS t02
      INNER JOIN zncprh_t003 AS t03 ON t02~kytno EQ t03~kytno
      INTO TABLE @DATA(lt_join).

    IF lines( lt_join ) <> 0.
      LOOP AT lt_join INTO DATA(ls_join).
        gs_header = CORRESPONDING #( ls_join-t02 ).
        gs_header-check = ls_join-check.
        COLLECT gs_header INTO gt_header.
        gs_item = CORRESPONDING #( ls_join-t03 ).

        APPEND gs_item TO gt_item_default.
        CLEAR : gs_header,gs_item.
      ENDLOOP.

    ENDIF.
  ENDMETHOD
  .
  METHOD get_all_data.
    CASE delete_key.
      WHEN abap_false.
        LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
          <fs_header>-check = gc_ok.
          <fs_header>-rowcolor = 'C310'. "Sarı
        ENDLOOP.
        "Kullanılacak ana item dataları.
        gt_item = VALUE #( FOR ls IN gt_item_default
                    ( CORRESPONDING #(  ls )  ) ).
        IF lines( gt_item ) <> 0.
          SORT gt_item BY kytno itmno ASCENDING.
        ELSE.
          CLEAR : gs_item.
        ENDIF.
      WHEN abap_true.
        LOOP AT gt_header ASSIGNING <fs_header>.
          <fs_header>-check = gc_init.
          <fs_header>-rowcolor = ''.
        ENDLOOP.
        CLEAR : gt_item[], gt_item.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD call_screen.
    CALL SCREEN '1362'.
  ENDMETHOD.                    "prepare_alv
  METHOD create_layo_and_fcat.
**--------------------------------------------------------------
**  layout
**--------------------------------------------------------------
    layout-sel_mode   = 'D'."mark alanı
    layout-zebra      = 'X'."zebra
    layout-cwidth_opt = 'X'."genişlik
    CASE celltab_key.
      WHEN abap_true.
        layout-stylefname = 'CELLTAB'.
      WHEN abap_false.
      WHEN OTHERS.
    ENDCASE.
    layout-info_fname = 'ROWCOLOR'.
**--------------------------------------------------------------
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = sname
*       i_internal_tabname     = 'GT_HEADER'
      CHANGING
        ct_fieldcat            = fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      gr_report->set_mod( CHANGING fcat   = fcat ).
    ENDIF.

  ENDMETHOD.
  METHOD exculude_tb.
**--------------------------------------------------------------
** Functions Closed
**--------------------------------------------------------------
    APPEND: cl_gui_alv_grid=>mc_fc_graph      TO functions,
            cl_gui_alv_grid=>mc_fc_info       TO functions,
            cl_gui_alv_grid=>mc_fc_print_back TO functions,
            cl_gui_alv_grid=>mc_fc_print_prev TO functions,
            cl_gui_alv_grid=>mc_fc_subtot     TO functions,
            cl_gui_alv_grid=>mc_fc_detail     TO functions,
            cl_gui_alv_grid=>mc_fc_views      TO functions,
*            cl_gui_alv_grid=>mc_fc_loc_move_row TO functions,
            "Edit işlem butonları gizlendi.
            cl_gui_alv_grid=>mc_fc_loc_append_row TO functions,
            cl_gui_alv_grid=>mc_fc_loc_copy TO functions,
            cl_gui_alv_grid=>mc_fc_loc_copy_row TO functions,
            cl_gui_alv_grid=>mc_fc_loc_cut TO functions,
            cl_gui_alv_grid=>mc_fc_loc_delete_row TO functions,
            cl_gui_alv_grid=>mc_fc_loc_insert_row TO functions,
            cl_gui_alv_grid=>mc_fc_loc_move_row TO functions,
            cl_gui_alv_grid=>mc_fc_loc_paste TO functions,
            cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO functions,
            cl_gui_alv_grid=>mc_fc_loc_undo TO functions.


  ENDMETHOD.
  METHOD set_variant_options.
    gs_variant_up-report = sy-repid.
    gs_variant_up-handle = '0001'.
    gs_variant_down-report = sy-repid.
    gs_variant_down-handle = '0002'.
  ENDMETHOD.
  METHOD display_alv.
    CALL METHOD gref->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.

*    CALL METHOD gref->register_edit_event
*      EXPORTING
*        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

    CALL METHOD gref->set_table_for_first_display
      EXPORTING
        is_variant                    = variant
        i_save                        = 'A'
        is_layout                     = layout
        it_toolbar_excluding          = functions
      CHANGING
        it_outtab                     = table
        it_fieldcatalog               = fcat
*       it_sort                       = gt_sort
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.


    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = gref.

  ENDMETHOD.                    "set_pf_status
  METHOD refresh_screen.
    DATA : ls_stable TYPE lvc_s_stbl.
    ls_stable-row = 'X'.
    ls_stable-col = 'X'.

    CASE key.
      WHEN abap_true.
        gref_alv_up->check_changed_data( ).
        IF gref_alv_up IS BOUND.
          gref_alv_up->refresh_table_display( is_stable = ls_stable ).
        ENDIF.
      WHEN abap_false.
        gref_alv_up->check_changed_data( ).
        gref_alv_down->check_changed_data( ).
        IF gref_alv_up IS BOUND.
          gref_alv_up->refresh_table_display( is_stable = ls_stable ).
        ENDIF.
        IF gref_alv_down IS BOUND.
          gref_alv_down->refresh_table_display( is_stable = ls_stable ).
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.                    "refresh_screen
  METHOD handle_toolbar_header.
    DATA: ls_toolbar TYPE stb_button.
    ls_toolbar-function = 'XSELECTALL'.
    ls_toolbar-text     = TEXT-016.
    ls_toolbar-icon     = icon_select_all.
    ls_toolbar-disabled = space.
    APPEND ls_toolbar TO e_object->mt_toolbar.
    CLEAR ls_toolbar.
    CLEAR ls_toolbar.
    ls_toolbar-function = 'XDESLCTALL'.
    ls_toolbar-text     = TEXT-017.
    ls_toolbar-icon     = icon_deselect_all.
    ls_toolbar-disabled = space.
    APPEND ls_toolbar TO e_object->mt_toolbar.
    CLEAR ls_toolbar.
  ENDMETHOD.
  METHOD handle_user_command_header.
    CASE e_ucomm.
      WHEN 'XSELECTALL'.
        me->get_all_data( ).
      WHEN 'XDESLCTALL'.
        me->get_all_data( EXPORTING delete_key = abap_true ).
    ENDCASE.
    me->refresh_screen( ).
  ENDMETHOD.
  METHOD handle_data_changed.

  ENDMETHOD.
  METHOD handle_data_changed_finished.
  ENDMETHOD.
  METHOD hotspot_click_header.
    DATA : lv_kytno     TYPE char10.
    DATA: lv_key(1).
    READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_row>) INDEX e_row_id.
    CASE e_column_id.
      WHEN 'CHECK'.
        CASE <fs_row>-check.
          WHEN gc_ok.
            <fs_row>-check = gc_init.
            <fs_row>-rowcolor = ''.
            DELETE gt_item WHERE kytno = <fs_row>-kytno.
          WHEN gc_init.
            <fs_row>-check = gc_ok.
            <fs_row>-rowcolor = 'C310'. "Sarı

            gt_item_main = VALUE #( FOR ls IN gt_item_default
                          WHERE ( kytno = <fs_row>-kytno )
                             ( CORRESPONDING #(  ls )  ) ).
            LOOP AT gt_item_main INTO gs_item.
              APPEND gs_item TO gt_item.
            ENDLOOP.
            SORT gt_item BY kytno itmno ASCENDING.
            me->refresh_screen( EXPORTING key = lv_key ).
          WHEN OTHERS.
        ENDCASE.
    ENDCASE.

  ENDMETHOD.
  METHOD hotspot_click_item.
  ENDMETHOD.
  METHOD set_mod.

    LOOP AT fcat ASSIGNING FIELD-SYMBOL(<fcat_all>).
      CASE <fcat_all>-fieldname.

        WHEN 'CHECK'.
          <fcat_all>-hotspot   = abap_true.
          <fcat_all>-icon   = abap_true.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
