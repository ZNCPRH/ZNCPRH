*&---------------------------------------------------------------------*
*&  Include           ZP1685_P79_I003
*&---------------------------------------------------------------------*
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    METHODS : initialization,
      at_selection_screen,
      at_selection_screen_s_program,
      at_selection_screen_s_class,
      start_of_selection,
      end_of_selection.


  PROTECTED SECTION.

    DATA :
      gr_alv_tree        TYPE REF TO cl_gui_alv_tree,
      gr_toolbar         TYPE REF TO cl_gui_toolbar,
      gt_layout          TYPE lvc_t_layi,
      gs_layout          TYPE lvc_s_layi,
      gr_container       TYPE REF TO cl_gui_custom_container, "cl_gui_container
      gt_fieldcat        TYPE lvc_t_fcat,
      gs_fieldcat        TYPE lvc_s_fcat,
      gs_hier_hdr        TYPE treev_hhdr,
      gt_list_commentary TYPE slis_t_listheader,
      gs_list_commentary TYPE slis_listheader,
      gs_logo            TYPE sdydo_value,
      gs_variant         TYPE disvariant,
      gt_event           TYPE cntl_simple_events,
      gs_event           TYPE cntl_simple_event,
      gs_layout_node     TYPE lvc_s_layn,
      gv_image           TYPE salv_de_tree_image,
      gv_new_node_key    TYPE lvc_nkey,
      gt_solix           TYPE TABLE OF solix,

      gr_html_viewer     TYPE REF TO cl_gui_html_viewer,
      gr_html_container  TYPE REF TO cl_gui_custom_container.


  PRIVATE SECTION.
    METHODS :  get_document_data,
      create_hierarchy_header,
      create_tree_fieldcatalog,
      create_list_commentary,
      create_tree_variant,
      create_tree_nodes,
      add_tree_nodes IMPORTING new_node_key TYPE lvc_nkey
                               parent       TYPE char12
                               child        TYPE char12,
      initialize_gui_tree,
      add_button,
      set_gui_tree_events,
      expand_node,
      fill_criteria IMPORTING node_key TYPE lvc_nkey OPTIONAL,

      find_program IMPORTING program_name TYPE string"csequence
                             program_type TYPE string "csequence
                             doc_type     TYPE string
                             node_key     TYPE lvc_nkey OPTIONAL,
      get_dbtab_data  EXPORTING solix     TYPE ty_solix_tab,
      get_tabty_data  EXPORTING solix     TYPE ty_solix_tab,
      get_messcl_data EXPORTING solix     TYPE ty_solix_tab,
      get_xslt_data   EXPORTING solix     TYPE ty_solix_tab,
      get_source_code IMPORTING program_type TYPE string
                      EXPORTING solix        TYPE ty_solix_tab,
      get_object_info IMPORTING object_name    TYPE string
                                program_type   TYPE string
                                operation_type TYPE char3
                      EXPORTING info_data      TYPE zncprh_t006,

      gui_upload      EXPORTING u_solix   TYPE ty_solix-solix
                                file_name TYPE string,
      upload_document IMPORTING program_name TYPE string
                                program_type TYPE string OPTIONAL
                                out_source   TYPE char1 OPTIONAL
                                solix        TYPE ty_solix-solix
                      EXPORTING subrc        TYPE sy-subrc,

      delete_document IMPORTING node_key TYPE lvc_nkey
                                otype    TYPE char3
                      EXPORTING subrc    TYPE sy-subrc,

      update_document IMPORTING program_name TYPE string
                                program_type TYPE string
                                solix        TYPE ty_solix-solix
                      EXPORTING subrc        TYPE sy-subrc,

      read_document  IMPORTING node_key TYPE lvc_nkey,

      outsource_doc  IMPORTING node_key TYPE lvc_nkey,

      add_node        IMPORTING node_key     TYPE lvc_nkey
                                otype        TYPE zncprh_t005-otype
                                clear_flag   TYPE flag OPTIONAL
                                program_name TYPE string OPTIONAL
                                node_info    TYPE zncprh_t006 OPTIONAL
                                program_type TYPE string OPTIONAL
                      EXPORTING subrc        TYPE sy-subrc
                                node_exp     TYPE lvc_nkey,

      del_node        IMPORTING node_key TYPE lvc_nkey
                                otype    TYPE char3,




      handle_node_ctmenu_request
                  FOR EVENT node_context_menu_request OF cl_gui_alv_tree
        IMPORTING node_key
                  menu,

      handle_item_ctmenu_request
                  FOR EVENT item_context_menu_request OF cl_gui_alv_tree
        IMPORTING node_key
                  fieldname
                  menu,

      handle_node_ctmenu_selected
                  FOR EVENT node_context_menu_selected OF cl_gui_alv_tree
        IMPORTING node_key
                  fcode,

      handle_item_ctmenu_selected
                  FOR EVENT item_context_menu_selected OF cl_gui_alv_tree
        IMPORTING node_key
                  fieldname
                  fcode,

      handle_node_double_click
                  FOR EVENT node_double_click OF cl_gui_alv_tree
        IMPORTING node_key
                  sender,

      handle_item_double_click
                  FOR EVENT item_double_click OF cl_gui_alv_tree
        IMPORTING node_key
                  fieldname,

      handle_button_click
                  FOR EVENT button_click OF cl_gui_alv_tree
        IMPORTING node_key
                  fieldname,
      handle_on_function_selected
                  FOR EVENT function_selected OF cl_gui_toolbar
        IMPORTING fcode.

ENDCLASS.                    "lcl_report DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_convert DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_convert DEFINITION FRIENDS lcl_report. "INHERITING FROM lcl_report.
  PUBLIC SECTION.
    METHODS : html_header       IMPORTING program_type TYPE string
                                          object_name  TYPE any
                                EXPORTING html_header  TYPE ty_html,
      html_footer       CHANGING  html_footer  TYPE ty_html,

      html_prog_body    IMPORTING source_code  TYPE ty_source_data
                                  program_type TYPE string
                                  program_name TYPE string
                        EXPORTING solix_tab    TYPE ty_solix-solix,
      html_dbtab_body   IMPORTING source_tab TYPE STANDARD TABLE
                                  table_type TYPE string
                                  table_name TYPE tabname
                        EXPORTING solix_tab  TYPE ty_solix-solix,
      html_tabty_body   IMPORTING source_str TYPE ty_dd40l
                                  table_type TYPE string
                                  table_name TYPE typename
                        EXPORTING solix_tab  TYPE ty_solix-solix,
      html_mclas_body   IMPORTING source_tab   TYPE STANDARD TABLE
                                  program_type TYPE string
                                  mclass_name  TYPE arbgb
                        EXPORTING solix_tab    TYPE ty_solix-solix,
      html_xslt_body    IMPORTING source_tab   TYPE STANDARD TABLE
                                  program_type TYPE string
                                  xslt_name    TYPE tadir-obj_name
                        EXPORTING solix_tab    TYPE ty_solix-solix.


  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS : convert_solix   IMPORTING html_table TYPE ty_html
                              EXPORTING solix_tab  TYPE ty_solix-solix.

ENDCLASS.                    "lcl_convert DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.
  METHOD initialization.
    "Initialization

    trtable  = 'Table/Structure'.
    trtabtyp = 'Table Types'.
    tptable  = 'Table Name'.
    tptabtyp = 'Table Type Name'.
    trfunc   = 'Function Module'.
    tpfname  = 'Function Name'.
    trxslt   = 'Transformation'.
    tfgroup  = 'Function Group'.
    trclass  = 'Classes'.
    tpcname  = 'Class name'.
    tmname   = 'Class Name'.
    tprog    = 'Programs'.
    trpname  = 'Program Name'.
    tpxslt   = 'Xslt Name'.
    tpmes    = 'Message Class'.

  ENDMETHOD.                    "initialization

  METHOD at_selection_screen.
    "At Selection Screen

  ENDMETHOD.                    "at_selection_screen

  METHOD at_selection_screen_s_program.

    CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
      EXPORTING
        object_type           = 'PROG'
        object_name           = soprog-low
        suppress_selection    = 'X'
        use_alv_grid          = ''
        without_personal_list = ''
      IMPORTING
        object_name_selected  = soprog-low
      EXCEPTIONS
        cancel                = 1.

  ENDMETHOD.                    "at_selection_screen_s_program

  METHOD at_selection_screen_s_class.

    CALL FUNCTION 'F4_DD_ALLTYPES'
      EXPORTING
        object               = soclass-low
        suppress_selection   = 'X'
        display_only         = ''
        only_types_for_clifs = 'X'
      IMPORTING
        result               = soclass-low.

  ENDMETHOD.                    "at_selection_screen_s_class

  METHOD start_of_selection.
    "Start of Selection

    me->get_document_data( ).
    me->create_tree_fieldcatalog( ).
    me->create_list_commentary( ).
    me->create_hierarchy_header( ).
    me->create_tree_variant( ).
    me->initialize_gui_tree( ).
    me->add_button( ).
    me->set_gui_tree_events( ).
    me->create_tree_nodes( ).
*    me->expand_node( ).

  ENDMETHOD.                    "start_of_selection

  METHOD end_of_selection.
    "End of Selection

    CALL SCREEN 0100.

  ENDMETHOD.                    "end_of_selection


  METHOD get_document_data.

    SELECT : * FROM zncprh_t004 INTO TABLE gt_t022,
             * FROM zncprh_t005 INTO TABLE gt_t023,
             * FROM zncprh_t006 INTO TABLE gt_t024.

  ENDMETHOD.                    "get_document_data

  METHOD create_hierarchy_header.

    gs_hier_hdr-heading   = 'Nesne Adı'.
    gs_hier_hdr-width     = '45'.
    gs_hier_hdr-width_pix = space.

  ENDMETHOD.                    "create_hierarchy_header

  METHOD create_tree_fieldcatalog.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = 'ZNCPRH_T006'
      CHANGING
        ct_fieldcat      = gt_fieldcat.

    LOOP AT gt_fieldcat INTO gs_fieldcat.

      gs_fieldcat-colddictxt   = 'M'.
      gs_fieldcat-outputlen    = 25.

      CASE gs_fieldcat-fieldname.
        WHEN 'UTIME'.

          gs_fieldcat-reptext = 'Değişiklik Tarihi'.
          gs_fieldcat-seltext = 'Değişiklik Tarihi'.
          gs_fieldcat-scrtext_l = 'Değişiklik Tarihi'.
          gs_fieldcat-scrtext_m = 'Değişiklik Tarihi'.
          gs_fieldcat-scrtext_s = 'Değ.Tarihi'.

      ENDCASE.

      MODIFY gt_fieldcat FROM gs_fieldcat.
      CLEAR gs_fieldcat.
    ENDLOOP.

  ENDMETHOD.                    "create_tree_components

  METHOD create_list_commentary.

    gs_list_commentary-typ  = 'H'.
    gs_list_commentary-info = 'Test'.
    APPEND gs_list_commentary TO gt_list_commentary.
    CLEAR gs_list_commentary.

    gs_list_commentary-typ = 'S'.
    WRITE sy-datum TO gs_list_commentary-info.
    APPEND gs_list_commentary TO gt_list_commentary.
    CLEAR gs_list_commentary.

    gs_list_commentary-typ  = 'S'.
    gs_list_commentary-info = 'Çalıştıran :  ' && sy-uname.
    APPEND gs_list_commentary TO gt_list_commentary.
    CLEAR gs_list_commentary.

  ENDMETHOD.                    "create_list_commentary

  METHOD create_tree_variant.

    gs_variant-report = sy-repid.

  ENDMETHOD.                    "create_tree_variant

  METHOD initialize_gui_tree.

    CREATE OBJECT gr_container
      EXPORTING
        container_name = 'CONTAINER'.

    CREATE OBJECT gr_alv_tree
      EXPORTING
        parent              = gr_container
        node_selection_mode = cl_gui_column_tree=>node_sel_mode_multiple
        item_selection      = 'X'.


    CALL METHOD gr_alv_tree->set_table_for_first_display
      EXPORTING
        is_variant          = gs_variant
        i_save              = 'A'
        is_hierarchy_header = gs_hier_hdr
        it_list_commentary  = gt_list_commentary
        i_logo              = 'PRQ_DETAY'
      CHANGING
        it_outtab           = gt_t024_tree
        it_fieldcatalog     = gt_fieldcat.


  ENDMETHOD.                    "initialize_gui_tree

  METHOD create_tree_nodes.

    CONSTANTS : lc_node_key TYPE lvc_nkey VALUE '          0'.

    DATA : lv_relat_node_key TYPE lvc_nkey,
           lv_node_text      TYPE lvc_value,
           ls_node_layout    TYPE lvc_s_layn.

    DATA : ls_t023_ctn TYPE zncprh_t005.

    LOOP AT gt_t023 INTO ls_t023_ctn WHERE parent = lc_node_key.

      CASE ls_t023_ctn-otype.
        WHEN 'FLD'.
          ls_node_layout-exp_image = '@FO@'.
          ls_node_layout-n_image   = '@FN@'.
        WHEN 'DOC'.
          ls_node_layout-exp_image = '@AR@'.
          ls_node_layout-n_image   = '@AR@'.
      ENDCASE.

      lv_node_text = ls_t023_ctn-name1.

      CALL METHOD gr_alv_tree->add_node
        EXPORTING
          i_relat_node_key = ''
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_node_layout   = ls_node_layout
          i_node_text      = lv_node_text
        IMPORTING
          e_new_node_key   = gv_new_node_key.

      me->add_tree_nodes(
        EXPORTING
          new_node_key = gv_new_node_key
          parent       = ls_t023_ctn-parent
          child        = ls_t023_ctn-child ).

    ENDLOOP.

  ENDMETHOD.                    "create_tree_nodes

  METHOD add_tree_nodes.

    DATA : ls_t023_atn     TYPE zncprh_t005,
           ls_t024_atn     TYPE zncprh_t006,
           lv_new_node_key TYPE lvc_nkey,
           lv_node_text    TYPE lvc_value,
           ls_node_layout  TYPE lvc_s_layn.

    LOOP AT gt_t023 INTO ls_t023_atn WHERE parent = child.

      READ TABLE gt_t024 INTO ls_t024_atn WITH KEY progname = ls_t023_atn-name1.

      CASE ls_t023_atn-otype.
        WHEN 'FLD'.
          ls_node_layout-exp_image = '@FO@'.
          ls_node_layout-n_image   = '@FN@'.
        WHEN 'DOC'.
          ls_node_layout-exp_image = '@AR@'.
          ls_node_layout-n_image   = '@AR@'.
      ENDCASE.

      lv_node_text = ls_t023_atn-name1.

      CALL METHOD gr_alv_tree->add_node
        EXPORTING
          i_relat_node_key = new_node_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = ls_t024_atn
          is_node_layout   = ls_node_layout
          i_node_text      = lv_node_text
        IMPORTING
          e_new_node_key   = lv_new_node_key.

      CLEAR ls_t024_atn.

      IF ls_t023_atn-otype = 'FLD'.
        gs_node_key-parent = ls_t023_atn-parent.
        gs_node_key-child  = ls_t023_atn-child.
        gs_node_key-name1  = lv_node_text.
        gs_node_key-mnfld = ls_t023_atn-parent.
        gs_node_key-otype = ls_t023_atn-otype.
        APPEND gs_node_key TO gt_node_key.
        CLEAR gs_node_key.

      ENDIF.

      gs_tree_key-parent = new_node_key."Tree key sorununun çözümü
      gs_tree_key-child  = lv_new_node_key.
      gs_tree_key-name1  = lv_node_text.
      gs_tree_key-mnfld = ls_t023_atn-mnfld.
      gs_tree_key-otype = ls_t023_atn-otype.
      APPEND gs_tree_key TO gt_tree_key.
      CLEAR gs_tree_key.

      me->add_tree_nodes(
        EXPORTING
          new_node_key = lv_new_node_key
          parent       = ls_t023_atn-parent
          child        = ls_t023_atn-child  ).

    ENDLOOP.


  ENDMETHOD.                    "add_tree_nodes

  METHOD expand_node.

    CALL METHOD gr_alv_tree->expand_node
      EXPORTING
        i_node_key = gv_new_node_key.

*    CALL METHOD gr_alv_tree->column_optimize
*      EXPORTING
*        i_include_heading = 'X'.


  ENDMETHOD.                    "expand_node

  METHOD set_gui_tree_events.

    CALL METHOD gr_alv_tree->get_registered_events
      IMPORTING
        events = gt_event.


    gs_event-eventid = cl_gui_column_tree=>eventid_expand_no_children.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_checkbox_change.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_header_context_men_req.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_node_context_menu_req.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_item_context_menu_req.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_header_click.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_item_keypress.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_button_click.
    APPEND gs_event TO gt_event.
    gs_event-eventid = cl_gui_column_tree=>eventid_item_keypress.
    APPEND gs_event TO gt_event.

    CALL METHOD gr_alv_tree->set_registered_events
      EXPORTING
        events = gt_event.

    SET HANDLER me->handle_node_ctmenu_request  FOR gr_alv_tree.
    SET HANDLER me->handle_node_ctmenu_selected FOR gr_alv_tree.
    SET HANDLER me->handle_item_ctmenu_request  FOR gr_alv_tree.
    SET HANDLER me->handle_item_ctmenu_selected FOR gr_alv_tree.
    SET HANDLER me->handle_item_ctmenu_selected FOR gr_alv_tree.
    SET HANDLER me->handle_node_double_click    FOR gr_alv_tree.
    SET HANDLER me->handle_button_click         FOR gr_alv_tree.
    SET HANDLER me->handle_item_double_click    FOR gr_alv_tree.
    SET HANDLER me->handle_on_function_selected FOR gr_toolbar .


  ENDMETHOD.                    "set_gui_tree_events

  METHOD handle_node_double_click.

  ENDMETHOD.                    "handle_node_double_click

  METHOD handle_node_ctmenu_request.    "Icon Seçilirse

    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'INSERT_FOLDER'
        text  = 'Klasör Ekle'
        icon  = '@FP@'.

    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'DELETE_FOLDER'
        text  = 'Klasörü Sil'
        icon  = '@FN@'.

    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'INSERT_DOCUMENT'
        text  = 'Doküman Ekle'
        icon  = '@FP@'.

    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'DELETE_DOCUMENT'
        text  = 'Dokümanı Sil'
        icon  = '@FN@'.



  ENDMETHOD.                    "handle_node_ctmenu_request

  METHOD handle_node_ctmenu_selected.    "Icon Seçilirse

    DATA : lv_name1_ctmenu TYPE string VALUE 'Dış Kaynak',
           lv_node_text_mn TYPE lvc_value.

    CALL METHOD gr_alv_tree->get_outtab_line
      EXPORTING
        i_node_key  = node_key
      IMPORTING
        e_node_text = lv_node_text_mn.


    CASE fcode.
      WHEN 'INSERT_FOLDER'.
        READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = lv_node_text_mn.

        IF  gs_tree_key-mnfld NE 'X' "OR
             "gs_tree_key-name1 EQ lv_name1_ctmenu )
        AND gs_tree_key-otype NE 'DOC'.
          me->add_node(
            EXPORTING
              node_key = node_key
              program_type = 'SUBFLD'
              otype    = 'FLD' ).
        ELSE.
          MESSAGE 'Sadece izin verilen birim içerisinde klasör oluşturulabilir' TYPE 'I'.
        ENDIF.

      WHEN 'DELETE_FOLDER'.
        READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = lv_node_text_mn.

        IF gs_tree_key-mnfld NE 'X'.
          me->del_node(
            EXPORTING
              node_key = node_key
              otype    = 'FLD' ).
        ELSE.
          MESSAGE 'Klasör en üst birime bağlı ise silinemez' TYPE 'I'.
        ENDIF.

      WHEN 'INSERT_DOCUMENT'.
        READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = lv_node_text_mn.
        IF gs_tree_key-name1 = lv_name1_ctmenu OR
          ( gs_tree_key-otype NE 'DOC' AND
            gs_tree_key-mnfld NE 'X' ).
          me->outsource_doc( node_key  ).
        ELSE.
          MESSAGE 'Sadece izin verilen birime doküman eklenebilir' TYPE 'I'.
        ENDIF.
      WHEN 'DELETE_DOCUMENT'.
        me->del_node(
           EXPORTING
             node_key = node_key
             otype    = 'DOC' ).
    ENDCASE.

  ENDMETHOD.                    "handle_node_ctmenu_selected

  METHOD handle_item_ctmenu_request.    "Text Seçilirse

    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'INSERT_FOLDER'
        text  = 'Klasör Ekle'
        icon  = '@FP@'.

    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'DELETE_FOLDER'
        text  = 'Klasörü Sil'
        icon  = '@FN@'.

    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'INSERT_DOCUMENT'
        text  = 'Doküman Ekle'
        icon  = '@FP@'.

    CALL METHOD menu->add_function
      EXPORTING
        fcode = 'DELETE_DOCUMENT'
        text  = 'Dokümanı Sil'
        icon  = '@FN@'.

  ENDMETHOD.                    "handle_item_ctmenu_request

  METHOD handle_item_ctmenu_selected.    "Text

    DATA :lv_name1_ctmenu TYPE string VALUE 'Dış Kaynak',
          lv_node_text_mn TYPE lvc_value.

    CALL METHOD gr_alv_tree->get_outtab_line
      EXPORTING
        i_node_key  = node_key
      IMPORTING
        e_node_text = lv_node_text_mn.
    CASE fcode.
      WHEN 'INSERT_FOLDER'.
        READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = lv_node_text_mn.

        IF  gs_tree_key-mnfld NE 'X' "OR
             "gs_tree_key-name1 EQ lv_name1_ctmenu )
        AND gs_tree_key-otype NE 'DOC'.
          me->add_node(
            EXPORTING
              node_key = node_key
              program_type = 'SUBFLD'
              otype    = 'FLD' ).
        ELSE.
          MESSAGE 'Sadece izin verilen birim içerisinde klasör oluşturulabilir' TYPE 'I'.
        ENDIF.

      WHEN 'DELETE_FOLDER'.

        READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = lv_node_text_mn.

        IF gs_tree_key-mnfld NE 'X'.
          me->del_node(
            EXPORTING
              node_key = node_key
              otype    = 'FLD' ).
        ELSE.
          MESSAGE 'Klasör en üst birime bağlı ise silinemez' TYPE 'I'.
        ENDIF.

      WHEN 'INSERT_DOCUMENT'.
        READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = lv_node_text_mn.
        IF gs_tree_key-name1 = lv_name1_ctmenu OR
          ( gs_tree_key-otype NE 'DOC' AND
            gs_tree_key-mnfld NE 'X' ).
          me->outsource_doc( node_key  ).
        ELSE.
          MESSAGE 'Sadece izin verilen birime doküman eklenebilir' TYPE 'I'.
        ENDIF.
      WHEN 'DELETE_DOCUMENT'.
        me->del_node(
           EXPORTING
             node_key = node_key
             otype    = 'DOC' ).
    ENDCASE.

  ENDMETHOD.                    "handle_item_ctmenu_selected

  METHOD add_button.

    CALL METHOD gr_alv_tree->get_toolbar_object
      IMPORTING
        er_toolbar = gr_toolbar.

    CHECK gr_toolbar IS NOT INITIAL.


    CALL METHOD gr_toolbar->add_button
      EXPORTING
        fcode     = 'ADD'
        icon      = '@0Y@'
        butn_type = '0'
        text      = 'Yedekle'
        quickinfo = 'Uygulama Yedekle'.

  ENDMETHOD.                    "add_button

  METHOD handle_button_click.

  ENDMETHOD.                    "handle_button_click

  METHOD handle_on_function_selected.


    CASE fcode.

      WHEN 'ADD'.

        CALL SELECTION-SCREEN 500 STARTING AT 30 35.
        IF sy-subrc <> 0.
          LEAVE TO SCREEN 100.
        ELSE.
          me->fill_criteria(  ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.                    "handle_on_function_selected

  METHOD handle_item_double_click.

    gv_down_flag = space.

    me->read_document( node_key )."Doküman Okuma

  ENDMETHOD.                    "handle_item_double_click

  METHOD fill_criteria.
    DATA : lv_program_name  TYPE string,
           lv_program_type  TYPE string,
           lv_document_type TYPE string.

    IF r_table EQ 'X'.

      MOVE 'DBTAB' TO lv_program_type.

    ELSEIF rtabtype EQ 'X'.

      MOVE 'TABTY' TO lv_program_type.

    ELSEIF rmess EQ 'X'.

      MOVE 'MSCLAS' TO lv_program_type.

    ELSEIF rfunc EQ 'X'.

      IF sofname IS NOT INITIAL.

        MOVE 'FMNAM' TO lv_program_type.

      ELSEIF sofgroup IS NOT INITIAL.

        MOVE 'FMGRP' TO lv_program_type.

      ENDIF.

    ELSEIF rxslt EQ 'X'.

      MOVE 'XSLT' TO lv_program_type.

    ELSEIF rclass EQ 'X'.

      MOVE 'CLASS' TO lv_program_type.

    ELSEIF rprog EQ 'X'.

      MOVE 'PROGR' TO lv_program_type.

    ENDIF.

    me->find_program(
      EXPORTING
        program_name = lv_program_name
        program_type = lv_program_type
        doc_type     = lv_document_type
        node_key     = node_key ).

  ENDMETHOD.                    "fill_criteria

  METHOD find_program.

    DATA :
      lv_subrc     TYPE sy-subrc,
      ls_t022_data TYPE zncprh_t004,
      ls_t023_data TYPE zncprh_t005,
      ls_t024_data TYPE zncprh_t006,
      ls_node_key  TYPE ty_node_key,
      lv_operation TYPE char3,
      lv_node_key  TYPE lvc_nkey,
      lt_solix_tab TYPE ty_solix_tab,
      ls_solix_tab TYPE ty_solix.

    CASE program_type.

      WHEN 'DBTAB'."DB Table or Structure
        me->get_dbtab_data(
          IMPORTING
            solix      = lt_solix_tab ).

      WHEN 'TABTY'."Table Type
        me->get_tabty_data(
          IMPORTING
            solix      = lt_solix_tab ).

      WHEN 'MSCLAS'."Message Class
        me->get_messcl_data(
          IMPORTING
            solix = lt_solix_tab ).

      WHEN 'FMNAM'."Function Modules
        me->get_source_code(
          EXPORTING
            program_type = 'FMNAM'
          IMPORTING
            solix        = lt_solix_tab ).

      WHEN 'FMGRP'."Function Group
        me->get_source_code(
          EXPORTING
            program_type = 'FUGR'
          IMPORTING
            solix        = lt_solix_tab ).

      WHEN 'XSLT'. "Transformation
        me->get_xslt_data(
          IMPORTING
            solix = lt_solix_tab ).

      WHEN 'CLASS'."Classs
        me->get_source_code(
          EXPORTING
            program_type = 'CLAS'
          IMPORTING
            solix        = lt_solix_tab ).

      WHEN 'PROGR'."Program or Include Program
        me->get_source_code(
          EXPORTING
            program_type = 'PROG'
          IMPORTING
            solix        = lt_solix_tab ).

    ENDCASE.


    LOOP AT lt_solix_tab INTO ls_solix_tab.

      CLEAR gs_tree_key.

      READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = ls_solix_tab-program_name.

      IF gs_tree_key IS NOT INITIAL.
        me->update_document(
          EXPORTING
            program_name = ls_solix_tab-program_name
            program_type = ls_solix_tab-program_type
            solix        = ls_solix_tab-solix
          IMPORTING
            subrc        = lv_subrc ).
        lv_operation = 'UPD'.

      ELSE.
        me->upload_document(
          EXPORTING
            program_name = ls_solix_tab-program_name
*          program_type = ls_solix_tab-program_type"Gerekli değil
            solix        = ls_solix_tab-solix
          IMPORTING
            subrc        = lv_subrc ).
        lv_operation = 'INS'.
      ENDIF.
      IF lv_subrc = 0.

        me->get_object_info(
          EXPORTING
            object_name = ls_solix_tab-program_name
            program_type = ls_solix_tab-program_type
            operation_type = lv_operation
          IMPORTING
            info_data    = ls_t024_data ).
        IF lv_operation = 'INS'.
          me->add_node(
            EXPORTING
              node_key     = lv_node_key
              otype        = 'DOC'
              program_name = ls_solix_tab-program_name
              program_type = ls_solix_tab-program_type
              node_info    = ls_t024_data
              clear_flag   = space
            IMPORTING
              subrc        = lv_subrc  ).

          IF lv_subrc = 0.
            INSERT zncprh_t006 FROM ls_t024_data.
            APPEND ls_t024_data TO gt_t024.
            CLEAR ls_t024_data.
          ENDIF.
        ELSEIF lv_operation = 'UPD'.
          MODIFY zncprh_t006 FROM ls_t024_data.
          MODIFY gt_t024 FROM ls_t024_data
                 TRANSPORTING progname
                              subc
                              docty
                              cnam
                              cdat
                              utime
                  WHERE progname = ls_t024_data-progname.
          CALL METHOD gr_alv_tree->frontend_update.

        ENDIF.

      ELSEIF lv_subrc <> 0.
        MESSAGE 'Doküman yedekleme işlemi başarısız!!' TYPE 'E'.

      ENDIF.
    ENDLOOP.



  ENDMETHOD.                    "find_program

  METHOD get_dbtab_data.

    DATA : lt_dd02l       TYPE STANDARD TABLE OF dd02l,
           lt_dd03p_n     TYPE STANDARD TABLE OF dd03p,
           ls_dd02l       TYPE dd02l,
           ls_dd02v_n     TYPE dd02v,
           lv_language    TYPE sy-langu VALUE 'EN',
           ls_gotstate    TYPE dcobjif-gotstate,
           lv_tabtype     TYPE string,
           ls_solix_dbtab TYPE ty_solix.


    SELECT * FROM dd02l INTO TABLE lt_dd02l WHERE tabname IN sotable.

    LOOP AT lt_dd02l INTO ls_dd02l.

      CALL FUNCTION 'DD_INT_TABL_GET'
        EXPORTING
          tabname        = ls_dd02l-tabname
          langu          = lv_language
        IMPORTING
          gotstate       = ls_gotstate
          dd02v_n        = ls_dd02v_n
        TABLES
          dd03p_n        = lt_dd03p_n
        EXCEPTIONS
          internal_error = 1.

      CASE ls_dd02l-tabclass.
        WHEN 'TRANSP'.
          lv_tabtype = 'DBTAB'.
        WHEN 'INTTAB'.
          lv_tabtype = 'STRUC'.
      ENDCASE.

      gr_convert->html_dbtab_body(
        EXPORTING
          table_name = ls_dd02l-tabname
          source_tab = lt_dd03p_n
          table_type = lv_tabtype
        IMPORTING
          solix_tab  = ls_solix_dbtab-solix ).

      ls_solix_dbtab-program_name = ls_dd02l-tabname.
      ls_solix_dbtab-program_type = lv_tabtype.
      APPEND ls_solix_dbtab TO solix.
      CLEAR : ls_solix_dbtab, ls_dd02l.

    ENDLOOP.

  ENDMETHOD.                    "get_dbtab_data

  METHOD get_tabty_data.

    DATA : lt_dd40l       TYPE STANDARD TABLE OF ty_dd40l,
           ls_dd40l       TYPE ty_dd40l,
           ls_solix_tabty TYPE ty_solix.


    SELECT * FROM dd40l AS a
        INNER JOIN dd40t AS b
        ON a~typename = b~typename
       INTO CORRESPONDING FIELDS OF TABLE lt_dd40l WHERE a~typename IN sotabtyp.


    LOOP AT lt_dd40l INTO ls_dd40l.

      gr_convert->html_tabty_body(
        EXPORTING
          table_name = ls_dd40l-typename
          source_str = ls_dd40l
          table_type = 'TABTY'
        IMPORTING
          solix_tab  = ls_solix_tabty-solix ).

      ls_solix_tabty-program_name = ls_dd40l-typename.
      ls_solix_tabty-program_type = 'TABTY'.
      APPEND ls_solix_tabty TO solix.
      CLEAR : ls_dd40l, ls_solix_tabty.

    ENDLOOP.

  ENDMETHOD.                    "get_tabty_data

  METHOD get_messcl_data.
    DATA : lt_t100        TYPE STANDARD TABLE OF t100,
           ls_t100        TYPE t100,
           ls_solix_mclas TYPE ty_solix.

    CLEAR lt_t100.

    SELECT * FROM t100 INTO TABLE lt_t100
       WHERE sprsl = 'TR' AND
             arbgb = pmname.

    gr_convert->html_mclas_body(
      EXPORTING
        mclass_name  = pmname
        source_tab   = lt_t100
        program_type = 'MSCLAS'
      IMPORTING
        solix_tab    =  ls_solix_mclas-solix ).

    ls_solix_mclas-program_name = pmname.
    ls_solix_mclas-program_type = 'MSCLAS'.
    APPEND ls_solix_mclas TO solix.
    CLEAR : ls_solix_mclas.

  ENDMETHOD.                    "get_messcl_data

  METHOD get_xslt_data.

    TYPES : BEGIN OF ty_xslt,
              obj_name TYPE tadir-obj_name,
            END OF ty_xslt.

    DATA : lt_xslt       TYPE STANDARD TABLE OF ty_xslt,
           ls_xslt       TYPE ty_xslt,
           ls_solix_xslt TYPE ty_solix.

    DATA : lt_source_xslt    TYPE o2pageline_table,
           ls_attribute_xslt TYPE  o2xsltattr,
           ls_soxslt         LIKE LINE OF soxslt,
           lv_fdpos          TYPE i.

    SELECT * FROM tadir INTO CORRESPONDING FIELDS OF TABLE lt_xslt WHERE obj_name IN soxslt.

    LOOP AT lt_xslt INTO ls_xslt.
*
*      SEARCH ls_xslt-obj_name FOR '='.
*      lv_fdpos = sy-fdpos.
*      ls_xslt-name = ls_xslt+0(lv_fdpos).

      cl_o2_api_xsltdesc=>load( EXPORTING p_xslt_desc     = ls_xslt-obj_name
                                IMPORTING p_source        = lt_source_xslt
                                      p_attributes        = ls_attribute_xslt
                                 EXCEPTIONS
                                       not_existing       = 1
                                       permission_failure = 2
                                       error_occured      = 3
                                       version_not_found  = 4 ).



      gr_convert->html_xslt_body(
        EXPORTING
          xslt_name    = ls_xslt-obj_name
          source_tab   = lt_source_xslt
          program_type = 'XSLT'
        IMPORTING
          solix_tab    = ls_solix_xslt-solix ).

      ls_solix_xslt-program_name = ls_xslt-obj_name.
      ls_solix_xslt-program_type = 'XSLT'.
      APPEND ls_solix_xslt TO solix.
      CLEAR : lv_fdpos, ls_xslt, ls_solix_xslt.

    ENDLOOP.


  ENDMETHOD.                    "get_xslt_data

  METHOD get_source_code.

    DATA : lt_tfdir      TYPE STANDARD TABLE OF tfdir,
           lt_seoclass   TYPE STANDARD TABLE OF seoclass,
           lt_enlfdir    TYPE STANDARD TABLE OF enlfdir,
           lt_trdir      TYPE STANDARD TABLE OF trdir,
           lt_source     TYPE STANDARD TABLE OF string,
           lt_incl_tab   TYPE STANDARD TABLE OF tadir-obj_name,
           lt_source_tab TYPE STANDARD TABLE OF ty_source_data,
           ls_incl_tab   LIKE LINE OF lt_incl_tab,
           ls_tfdir      TYPE tfdir,
           ls_seoclass   TYPE seoclass,
           ls_enlfdir    TYPE enlfdir,
           ls_trdir      TYPE trdir,
           ls_source     TYPE string,
           ls_source_tab TYPE ty_source_data.

    DATA : lv_program_name TYPE string,
           ls_repid        TYPE sy-repid,
           ls_program_name TYPE string,
           ls_solix        TYPE ty_solix.


    DATA :BEGIN OF ls_progname,
            programname  TYPE sy-repid,
            program_type TYPE string,
          END OF ls_progname,

          lt_progname LIKE STANDARD TABLE OF ls_progname.


    CASE program_type.
      WHEN 'CLAS'."Eğer Global Classsa
        SELECT * FROM seoclass INTO TABLE lt_seoclass WHERE clsname IN soclass.
        LOOP AT lt_seoclass INTO ls_seoclass.
          ls_progname-programname = ls_seoclass-clsname.
          ls_progname-program_type = 'CLAS'.
          APPEND ls_progname TO lt_progname.
          CLEAR ls_seoclass.
        ENDLOOP.

      WHEN 'FMNAM'."Eğer Foknsiyon Modülüyse
        SELECT * FROM tfdir INTO TABLE lt_tfdir WHERE funcname IN sofname.
        LOOP AT lt_tfdir INTO ls_tfdir.
          CONCATENATE ls_tfdir-pname+3(27) 'U' ls_tfdir-include INTO ls_progname-programname.
          ls_progname-program_type = 'FMNAM'.
          APPEND ls_progname TO lt_progname.
          CLEAR ls_tfdir.
        ENDLOOP.

      WHEN 'FUGR'."Eğer Fonksiyon Grubuysa
        SELECT * FROM enlfdir INTO TABLE lt_enlfdir WHERE area IN sofgroup.
        LOOP AT lt_enlfdir INTO ls_enlfdir.
          ls_progname-programname = ls_enlfdir-area.
          ls_progname-program_type = 'FUGR'.
          APPEND ls_progname TO lt_progname.
          CLEAR ls_enlfdir.
        ENDLOOP.

      WHEN 'PROG'."Eğer Programsa
        SELECT * FROM trdir INTO TABLE lt_trdir WHERE name IN soprog
                                                  AND subc = '1'.
        LOOP AT lt_trdir INTO ls_trdir.
          ls_progname-programname = ls_trdir-name.
          ls_progname-program_type = 'PROG'.
          APPEND ls_progname TO lt_progname.
          CLEAR ls_progname.
          ls_repid = ls_trdir-name.

          CALL FUNCTION 'RS_GET_ALL_INCLUDES' "Varsa Include'ları oku
            EXPORTING
              program      = ls_repid
            TABLES
              includetab   = lt_incl_tab
            EXCEPTIONS
              not_existent = 1
              no_program   = 2
              OTHERS       = 3.

          LOOP AT lt_incl_tab INTO ls_incl_tab.
            IF ls_incl_tab NS '%_HR' AND"Yapıyı PNP'den ayır
               ls_incl_tab NS 'PNP' AND
               ls_incl_tab NS 'PAY_SCREEN'.
              ls_progname-programname = ls_incl_tab.
              ls_progname-program_type = 'INCL'.
              APPEND ls_progname TO lt_progname.
              CLEAR ls_progname.
            ENDIF.
          ENDLOOP.

        ENDLOOP.

    ENDCASE.

    LOOP AT lt_progname INTO ls_progname.

      CASE ls_progname-program_type.
        WHEN 'PROG' OR 'INCL' OR 'FMNAM'.
          READ REPORT ls_progname-programname INTO lt_source."Program Kodunu Oku
*          ENDIF.
        WHEN OTHERS.
          cl_reca_rs_services=>get_source( "Class'ın Kodunu Oku
           EXPORTING
             id_objtype = ls_progname-program_type   " Object Type (CLAS, INTF, FUGR, or PROG)
             id_objname = ls_progname-programname    " Object Name
           IMPORTING
             et_source  = lt_source ).   " Source Text
      ENDCASE.
      ls_source_tab-program_name = ls_progname-programname.
      ls_source_tab-program_type = ls_progname-program_type.
      ls_source_tab-source_code  = lt_source.
      MOVE ls_progname-programname TO  ls_program_name.
      gr_convert->html_prog_body( "Kodu Html Yapısı İçerisine Yerleştir
        EXPORTING
          source_code = ls_source_tab
          program_type = ls_progname-program_type
          program_name = ls_program_name
        IMPORTING
          solix_tab   = ls_solix-solix ).

      ls_solix-program_name = ls_progname-programname.
      ls_solix-program_type = ls_progname-program_type.
      APPEND ls_solix TO solix .
      CLEAR: ls_solix , ls_source_tab, lt_source.
    ENDLOOP.

  ENDMETHOD.                    "get_source_code


  METHOD upload_document.

    CONSTANTS lc_general   TYPE sofd-folrg  VALUE 'B'.

    DATA : lt_objhdr    TYPE TABLE OF solisti1,
           ls_objhdr    LIKE LINE OF lt_objhdr,
           lt_solix     TYPE TABLE OF solix,
           lv_extension TYPE soodk-objtp,
           ls_folder_id TYPE soodk,
           ls_doc_data  TYPE sodocchgi1,
           ls_docinfo   TYPE sofolenti1,
           lv_doc_id    TYPE sofolenti1-doc_id,
           ls_t022      TYPE zncprh_t004,
           ls_rolea     TYPE borident,
           ls_roleb     TYPE borident,
           ls_document  TYPE sofolenti1.


    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET' "SRGBTBREL, INSTID_B'nin ilk kısmını üret
      EXPORTING
        region    = lc_general  "General
      IMPORTING
        folder_id = ls_folder_id.

    IF out_source = 'X'."Dokümanın adı ve uzantısı
      ls_doc_data-obj_descr = program_name.
    ELSE.
      ls_doc_data-obj_descr = program_name && '.html'.
    ENDIF.

    ls_doc_data-obj_name = 'MESSAGE'.
    ls_doc_data-obj_langu = 'EN'.
    lv_extension = 'BIN'.

    CONCATENATE '&SO_FILENAME=' ls_doc_data-obj_descr INTO ls_objhdr-line.
    APPEND ls_objhdr TO lt_objhdr.
    CLEAR ls_objhdr.
    ls_objhdr-line = 'SO_FORMAT=BIN'.
    APPEND ls_objhdr TO lt_objhdr.

    CALL FUNCTION 'SO_DOCUMENT_INSERT_API1' "Dokümanı SAP'e aktar
      EXPORTING
        folder_id     = ls_folder_id    " ID of folder in which document is to be created
        document_data = ls_doc_data    " Document attributes (general header)
        document_type = lv_extension   " Document Class
      IMPORTING
        document_info = ls_docinfo   " Complete attributes of document
      TABLES
        object_header = lt_objhdr   " Header data for document (spec.header)
        contents_hex  = solix.    " Document contents (binary)

    IF sy-subrc = 0.

      "SRGBTBREL => INSTID_A Alanı
      ls_rolea-objkey = program_name.
      ls_rolea-objtype = 'REPORT'.

      "SRGBTBREL => INSTID_B, TYPEID_B
      ls_roleb-objkey  = ls_docinfo-doc_id.
      ls_roleb-objtype = 'MESSAGE'.

      CALL FUNCTION 'BINARY_RELATION_CREATE_COMMIT' "Doküman aktarıldıysa Commit'le
        EXPORTING
          obj_rolea      = ls_rolea    " Role Object A
          obj_roleb      = ls_roleb   " Role Object B
          relationtype   = 'ATTA'    " Relationship type
        EXCEPTIONS
          no_model       = 1
          internal_error = 2
          unknown        = 3
          OTHERS         = 4.

      subrc = sy-subrc.

      lv_doc_id = ls_roleb-objkey.

      CALL FUNCTION 'SO_DOCUMENT_READ_API1' "Dokümanı oku
        EXPORTING
          document_id                = lv_doc_id
        IMPORTING
          document_data              = ls_document
        EXCEPTIONS
          document_id_not_exist      = 1
          operation_no_authorization = 2
          x_error                    = 3
          OTHERS                     = 4.


      ls_t022-creat_date = ls_document-creat_date.
      ls_t022-creat_name = ls_document-creat_name.
      ls_t022-last_acces = ls_document-last_acces.
      ls_t022-obj_descr  = ls_document-obj_descr.
      ls_t022-obj_name   = ls_document-obj_name.
      ls_t022-obj_type   = ls_document-obj_type.
      ls_t022-instid_a   = ls_rolea-objkey.
      ls_t022-instid_b   = ls_roleb-objkey.
      ls_t022-chang_name = ls_document-chang_name.
      ls_t022-typeid_a   = ls_rolea-objtype.
      ls_t022-typeid_b   = ls_roleb-objtype.
      ls_t022-reltype    = 'ATTA'.
      ls_t022-catid_a    = 'BO'.
      ls_t022-catid_b    = 'BO'.


      INSERT zncprh_t004 FROM ls_t022."Z'li Tabloya Yolla
      APPEND ls_t022 TO gt_t022.

    ELSEIF sy-subrc <> 0.

      subrc = sy-subrc.

      MESSAGE 'Program yedekleme işlemi başarısız!' TYPE 'E'.

    ENDIF.

  ENDMETHOD.                    "upload_document

  METHOD delete_document.

    DATA : ls_objec_ddoc    TYPE sibflporb,
           lt_objec_ddoc    TYPE sibflporbt,
           lt_links_a_ddoc  TYPE obl_t_link,
           ls_links_a_ddoc  LIKE LINE OF lt_links_a_ddoc,
           ls_rdoc_id_ddoc  TYPE sofolenti1-doc_id,
           lt_links_b_ddoc  TYPE obl_t_link,
           ls_object_a_ddoc TYPE sibflporb,
           ls_object_b_ddoc TYPE sibflporb,
           ls_reltype_ddoc  TYPE oblreltype,
           ls_rolea_ddoc    TYPE borident,
           ls_roleb_ddoc    TYPE borident,
           lv_reltype_ddoc  TYPE breltyp-reltype,
           lv_del_id_ddoc   TYPE sofolenti1-doc_id.

    DATA : ls_t022_del        TYPE zncprh_t004,
           ls_child_del       TYPE zncprh_t005,
           ls_t023_del        TYPE zncprh_t005,
           ls_t024_del        TYPE zncprh_t006,
           lv_node_text_del   TYPE lvc_value,
           lt_item_layout_del TYPE lvc_t_layi,
           ls_node_layout_del TYPE lvc_s_layn.

    CALL METHOD gr_alv_tree->get_outtab_line "Treeden node'keye karşılık gelen alanı al
      EXPORTING
        i_node_key     = node_key
      IMPORTING
        e_node_text    = lv_node_text_del
        et_item_layout = lt_item_layout_del
        es_node_layout = ls_node_layout_del.


    CLEAR gs_tree_key.
    READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = lv_node_text_del."Text' ile iTabdan
    "parent ve childi al
    CASE gs_tree_key-otype.

      WHEN 'FLD'.

        LOOP AT gt_t023 INTO ls_t023_del WHERE child  = gs_tree_key-child
                                           OR parent  = gs_tree_key-child.

          READ TABLE gt_t022 INTO ls_t022_del WITH KEY instid_a = ls_t023_del-name1.

          IF sy-subrc = 0.
            ls_objec_ddoc-instid = ls_t022_del-instid_a.
            ls_objec_ddoc-typeid = ls_t022_del-typeid_a.
            ls_objec_ddoc-catid  = ls_t022_del-catid_a.
            APPEND ls_objec_ddoc TO lt_objec_ddoc.
            CLEAR : ls_objec_ddoc, ls_t022_del.
          ENDIF.

        ENDLOOP.

      WHEN 'DOC'.

        READ TABLE gt_t022 INTO ls_t022_del TRANSPORTING ALL FIELDS
                                                WITH KEY instid_a = lv_node_text_del.

        ls_objec_ddoc-instid = ls_t022_del-instid_a.
        ls_objec_ddoc-typeid = ls_t022_del-typeid_a.
        ls_objec_ddoc-catid  = ls_t022_del-catid_a.
        APPEND ls_objec_ddoc TO lt_objec_ddoc.
        CLEAR : ls_objec_ddoc, ls_t022_del.

    ENDCASE.

    IF lt_objec_ddoc IS NOT INITIAL.
      TRY.

          CALL METHOD cl_binary_relation=>read_links_of_objects
            EXPORTING
              it_objects = lt_objec_ddoc
            IMPORTING
              et_links_a = lt_links_a_ddoc
              et_links_b = lt_links_b_ddoc.

        CATCH cx_obl_parameter_error .
        CATCH cx_obl_internal_error .
        CATCH cx_obl_model_error .
      ENDTRY.

      LOOP AT lt_links_a_ddoc INTO ls_links_a_ddoc.

        lv_del_id_ddoc = ls_links_a_ddoc-instid_b.

        CALL FUNCTION 'SO_DOCUMENT_DELETE_API1'
          EXPORTING
            unread_delete              = 'X'
            document_id                = lv_del_id_ddoc
          EXCEPTIONS
            document_not_exist         = 1
            operation_no_authorization = 2
            parameter_error            = 3
            x_error                    = 4
            enqueue_error              = 5
            OTHERS                     = 6.

        IF sy-subrc <> 0.
          subrc = sy-subrc.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSEIF sy-subrc = 0.

*   *SRGBTBREL => INSTID_A, TYPEID_A
          ls_rolea_ddoc-objkey  = ls_links_a_ddoc-instid_a.
          ls_rolea_ddoc-objtype = ls_links_a_ddoc-typeid_a.

*   *SRGBTBREL => INSTID_B, TYPEID_B
          ls_roleb_ddoc-objkey  = ls_links_a_ddoc-instid_b.
          ls_roleb_ddoc-objtype = ls_links_a_ddoc-typeid_b.

*   *SRBGTBREL => RELTYPE
          lv_reltype_ddoc = ls_links_a_ddoc-reltype.

          CALL FUNCTION 'BINARY_RELATION_DELETE_COMMIT'
            EXPORTING
              obj_rolea          = ls_rolea_ddoc    " Role Object A
              obj_roleb          = ls_roleb_ddoc   " Role Object B
              relationtype       = lv_reltype_ddoc    " Relationship type
            EXCEPTIONS
              entry_not_existing = 1
              internal_error     = 2
              no_relation        = 3
              no_role            = 4
              OTHERS             = 5.

          IF sy-subrc <> 0.
            subrc = sy-subrc.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

          ELSEIF sy-subrc = 0.

            DELETE FROM zncprh_t004"Z'li Tablodan kaydı sil
             WHERE instid_b = ls_links_a_ddoc-instid_b.

          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CASE gs_tree_key-otype.
      WHEN 'FLD'.

        LOOP AT gt_t023 INTO ls_t023_del WHERE child  = gs_tree_key-child
                               OR parent  = gs_tree_key-child.

          DELETE FROM zncprh_t005
           WHERE name1 = ls_t023_del-name1.
          DELETE gt_t023 WHERE name1 = ls_t023_del-name1.

          DELETE FROM zncprh_t006
                WHERE progname = ls_t023_del-name1.

          DELETE gt_t024 WHERE progname = ls_t023_del-name1.

          CLEAR ls_t023_del.

        ENDLOOP.

      WHEN 'DOC'.

        DELETE FROM zncprh_t005
              WHERE name1 = ls_t023_del-name1.

        DELETE gt_t023 WHERE name1 = ls_t023_del-name1.

        DELETE FROM zncprh_t006
              WHERE progname = ls_t023_del-name1.

        DELETE gt_t024 WHERE progname = ls_t023_del-name1.

    ENDCASE.

    COMMIT WORK AND WAIT.

  ENDMETHOD.                    "delete_document

  METHOD update_document.
    DATA : ls_document_id_upd   TYPE sofolenti1-doc_id,
           ls_document_data_upd TYPE sofolenti1,
           ls_doc_data_upd      TYPE sodocchgi1,
           ls_t022_upd          TYPE zncprh_t004,
           lv_popup_return(1).


    IF gv_upd_flag IS INITIAL.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Uyarı Mesajı'
          text_question  = 'Var olan dokümanların üzerine yazmak ister misiniz? '
          text_button_1  = 'Evet' "
          text_button_2  = 'Hayır'
          default_button = '1'
        IMPORTING
          answer         = lv_popup_return.
      " Return values: '1', '2', 'A'
    ENDIF.

    CASE lv_popup_return.
      WHEN '1'.
        gv_upd_flag = 'X'.

        READ TABLE gt_t022  INTO ls_t022_upd
                               WITH KEY instid_a = program_name.

        MOVE ls_t022_upd-instid_b TO ls_document_id_upd.

        CALL FUNCTION 'SO_DOCUMENT_READ_API1' "Dokümanı Oku
          EXPORTING
            document_id   = ls_document_id_upd
          IMPORTING
            document_data = ls_document_data_upd.


        MOVE-CORRESPONDING ls_document_data_upd TO ls_doc_data_upd.

        CALL FUNCTION 'SO_DOCUMENT_UPDATE_API1'
          EXPORTING
            document_id   = ls_document_id_upd
            document_data = ls_doc_data_upd                                                                                                                                           " document_type = lv_doc_type
          TABLES
            contents_hex  = solix.

        subrc = sy-subrc.

        IF subrc = 0.

          UPDATE zncprh_t004 SET chang_date = sy-datum
                                 chang_name = sy-uname
              WHERE instid_a = ls_t022_upd-instid_a.
        ENDIF.

      WHEN '2' OR 'A'.

        gv_upd_flag = 'X'.
        MESSAGE 'İşlem kullanıcı tarafından iptal edildi' TYPE 'I'.

    ENDCASE.

  ENDMETHOD.                    "update_document


  METHOD read_document.

    DATA : lt_incl_tab_read      TYPE TABLE OF tadir-obj_name,
           lt_objectheader_rdoc  TYPE TABLE OF solisti1,
           lt_objectcontent_rdoc TYPE TABLE OF solisti1,
           lt_content_hex_rdoc   TYPE TABLE OF solix,
           lt_objcontab_rdoc     TYPE TABLE OF soli,
           lt_objec_rdoc         TYPE sibflporbt,
           lt_links_a_rdoc       TYPE obl_t_link,
           lt_links_b_rdoc       TYPE obl_t_link,
           ls_incl_tab_read      LIKE LINE OF lt_incl_tab_read,
           ls_objec_rdoc         TYPE sibflporb,
           ls_links_a_rdoc       LIKE LINE OF lt_links_a_rdoc,
           ls_rdoc_id_rdoc       TYPE sofolenti1-doc_id,
           ls_document_rdoc      TYPE sofolenti1,
           ls_objectheader_rdoc  TYPE solisti1,
           ls_objectcontent_rdoc TYPE solisti1,
           ls_objcontab_rdoc     TYPE soli.

    DATA : ls_t023_read        TYPE zncprh_t005,
           ls_child_read       TYPE zncprh_t005,
           ls_t022_read        TYPE zncprh_t004,
           ls_t024_read        TYPE zncprh_t006,
           lv_node_text_read   TYPE lvc_value,
           lt_item_layout_read TYPE lvc_t_layi,
           ls_node_layout_read TYPE lvc_s_layn.

    DATA : lv_str1(255),
           lv_str2(255),
           lv_path(255),
           lv_type(3),
           lv_path_s     TYPE string,
           ls_repid_read TYPE sy-repid.

    CALL METHOD gr_alv_tree->get_outtab_line
      EXPORTING
        i_node_key     = node_key
      IMPORTING
        e_node_text    = lv_node_text_read
        et_item_layout = lt_item_layout_read
        es_node_layout = ls_node_layout_read.

    READ TABLE gt_t023 TRANSPORTING ALL FIELDS INTO ls_child_read
                             WITH KEY name1 = lv_node_text_read.

    CASE ls_child_read-otype.

      WHEN 'FLD'.

        LOOP AT gt_t023 INTO ls_t023_read WHERE child  = ls_child_read-child
                                           OR parent  = ls_child_read-child.
          IF ls_t023_read-parent = '          3'.
            ls_repid_read = ls_t023_read-name1.
            CALL FUNCTION 'RS_GET_ALL_INCLUDES'
              EXPORTING
                program      = ls_repid_read
              TABLES
                includetab   = lt_incl_tab_read
              EXCEPTIONS
                not_existent = 1
                no_program   = 2
                OTHERS       = 3.
          ENDIF.

          READ TABLE gt_t022 INTO ls_t022_read WITH KEY instid_a = ls_t023_read-name1.
          IF sy-subrc = 0.


            ls_objec_rdoc-instid = ls_t022_read-instid_a.
            ls_objec_rdoc-typeid = ls_t022_read-typeid_a.
            ls_objec_rdoc-catid  = ls_t022_read-catid_a.
            APPEND ls_objec_rdoc TO lt_objec_rdoc.
            CLEAR : ls_objec_rdoc, ls_t022_read.

            IF lt_incl_tab_read IS NOT INITIAL.

              LOOP AT lt_incl_tab_read INTO ls_incl_tab_read.

                IF ls_incl_tab_read NS '%_HR' AND"Yapıyı PNP'den ayır
                   ls_incl_tab_read NS 'PNP' AND
                   ls_incl_tab_read NS 'PAY_SCREEN'.

                  READ TABLE gt_t022 INTO ls_t022_read WITH KEY instid_a = ls_incl_tab_read.

                  ls_objec_rdoc-instid = ls_t022_read-instid_a.
                  ls_objec_rdoc-typeid = ls_t022_read-typeid_a.
                  ls_objec_rdoc-catid  = ls_t022_read-catid_a.
                  APPEND ls_objec_rdoc TO lt_objec_rdoc.
                  CLEAR : ls_incl_tab_read, ls_t022_read.
                ENDIF.

              ENDLOOP.

            ENDIF.
          ENDIF.

        ENDLOOP.

      WHEN 'DOC'.

        READ TABLE gt_t022 INTO ls_t022_read TRANSPORTING ALL FIELDS
                                                WITH KEY instid_a = lv_node_text_read.


        ls_objec_rdoc-instid = ls_t022_read-instid_a.
        ls_objec_rdoc-typeid = ls_t022_read-typeid_a.
        ls_objec_rdoc-catid  = ls_t022_read-catid_a.
        APPEND ls_objec_rdoc TO lt_objec_rdoc.
        CLEAR : ls_objec_rdoc, ls_t022_read.

        READ TABLE gt_t024 INTO ls_t024_read WITH KEY progname = lv_node_text_read.

        IF ls_t024_read-subc = 'Yürütülebilir Program'.
          ls_repid_read = ls_t024_read-progname.

          CALL FUNCTION 'RS_GET_ALL_INCLUDES'
            EXPORTING
              program      = ls_repid_read
            TABLES
              includetab   = lt_incl_tab_read
            EXCEPTIONS
              not_existent = 1
              no_program   = 2
              OTHERS       = 3.

          IF lt_incl_tab_read IS NOT INITIAL.

            LOOP AT lt_incl_tab_read INTO ls_incl_tab_read.
              IF ls_incl_tab_read NS '%_HR' AND"Yapıyı PNP'den ayır
                 ls_incl_tab_read NS 'PNP' AND
                 ls_incl_tab_read NS 'PAY_SCREEN'.

                READ TABLE gt_t022 INTO ls_t022_read WITH KEY instid_a = ls_incl_tab_read.

                ls_objec_rdoc-instid = ls_t022_read-instid_a.
                ls_objec_rdoc-typeid = ls_t022_read-typeid_a.
                ls_objec_rdoc-catid  = ls_t022_read-catid_a.
                APPEND ls_objec_rdoc TO lt_objec_rdoc.
                CLEAR : ls_incl_tab_read, ls_t022_read.
              ENDIF.
            ENDLOOP.

          ENDIF.

        ENDIF.

    ENDCASE.

    TRY.

        CALL METHOD cl_binary_relation=>read_links_of_objects
          EXPORTING
            it_objects = lt_objec_rdoc
          IMPORTING
            et_links_a = lt_links_a_rdoc
            et_links_b = lt_links_b_rdoc.

      CATCH cx_obl_parameter_error .
      CATCH cx_obl_internal_error .
      CATCH cx_obl_model_error .

    ENDTRY.

    LOOP AT lt_links_a_rdoc INTO ls_links_a_rdoc.
      MOVE ls_links_a_rdoc-instid_b TO ls_rdoc_id_rdoc.

      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          document_id                = ls_rdoc_id_rdoc
        IMPORTING
          document_data              = ls_document_rdoc
        TABLES
          object_header              = lt_objectheader_rdoc
          object_content             = lt_objectcontent_rdoc
          contents_hex               = lt_content_hex_rdoc
        EXCEPTIONS
          document_id_not_exist      = 1
          operation_no_authorization = 2
          x_error                    = 3
          OTHERS                     = 4.

      LOOP AT lt_objectcontent_rdoc INTO ls_objectcontent_rdoc.
        ls_objcontab_rdoc-line = ls_objectcontent_rdoc-line.
        APPEND ls_objcontab_rdoc TO lt_objcontab_rdoc.
        CLEAR ls_objectcontent_rdoc.
      ENDLOOP.

      IF gv_down_flag IS INITIAL.
        gv_down_flag = 'X'.
        CLEAR lv_path_s.
        CALL METHOD cl_gui_frontend_services=>directory_browse
          EXPORTING
            window_title    = 'İndirilecek konumu seçiniz'
            initial_folder  = 'C:\'
          CHANGING
            selected_folder = lv_path_s.

      ENDIF.

      LOOP AT lt_objectheader_rdoc INTO ls_objectheader_rdoc.
        IF ls_objectheader_rdoc-line CS 'SO_FILENAME'.
          SPLIT ls_objectheader_rdoc-line AT '=' INTO lv_str1 lv_str2.
          CONCATENATE lv_path_s '\' ls_links_a_rdoc-instid_a '\' lv_str2 INTO lv_path.
        ELSEIF ls_objectheader_rdoc-line CS 'SO_FORMAT'.
          SPLIT ls_objectheader_rdoc-line AT '=' INTO lv_str1 lv_str2.
          lv_type = lv_str2.
        ENDIF.
      ENDLOOP.
      IF lv_type IS INITIAL.
        lv_type = 'BIN'.
      ENDIF.


      CALL FUNCTION 'SO_OBJECT_DOWNLOAD'
        EXPORTING
          filetype         = lv_type
          path_and_file    = lv_path
          no_dialog        = 'X'
        TABLES
          objcont          = lt_objcontab_rdoc
        EXCEPTIONS
          file_write_error = 1
          invalid_type     = 2
          x_error          = 3
          kpro_error       = 4
          OTHERS           = 5.

      CLEAR : lt_objcontab_rdoc, lt_objectheader_rdoc.

      IF sy-subrc <> 0.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.                    "read_document

  METHOD add_node.

    DATA : lv_add_node_key     TYPE lvc_nkey,
           lv_add_node_text    TYPE lvc_value,
           lv_node_folder_text TYPE lvc_value,
           ls_add_node_layout  TYPE lvc_s_layn,
           ls_t023_add         TYPE zncprh_t005,
           lv_node_flag        TYPE flag,
           lv_add_node_key_fl  TYPE lvc_nkey,
           lv_name1            TYPE zncprh_t005-name1.


    DATA : lv_text TYPE trm080-text.

    IF otype = 'FLD'.
      CALL FUNCTION 'TRM_POPUP_TEXT_INPUT'
        EXPORTING
          sourcetext   = 'Ad Giriniz'
          titel        = 'Text Alanı'
          start_column = 25
          start_row    = 6
        CHANGING
          targettext   = lv_text.

    ELSE.
      lv_text = program_name.
    ENDIF.

    IF lv_text IS NOT INITIAL OR otype = 'DOC'.

      CASE otype.
        WHEN 'FLD'.

          lv_add_node_text = lv_text.
          ls_add_node_layout-exp_image = '@FN@'.
          ls_add_node_layout-n_image   = '@FO@'.

        WHEN 'DOC'.

          lv_add_node_text = program_name.
          ls_add_node_layout-exp_image = '@AR@'.
          ls_add_node_layout-n_image   = '@AR@'.

      ENDCASE.

      IF clear_flag = 'X'.
        CLEAR lv_node_flag.
      ENDIF.

      CASE program_type.
        WHEN 'FMNAM'.
          lv_name1 = 'Function Module'.
        WHEN 'FUGR'.
          lv_name1 = 'Function Group'.
        WHEN 'CLAS'.
          lv_name1 = 'Class'.
        WHEN 'PROG'.
          lv_name1 = 'Program'.
        WHEN 'INCL'.
          lv_name1 = 'Include Program'.
        WHEN 'MSCLAS'.
          lv_name1 = 'Message Class'.
        WHEN 'DBTAB'.
          lv_name1 = 'Database Tables'.
        WHEN 'STRUC'.
          lv_name1 = 'Structures'.
        WHEN 'TABTY'.
          lv_name1 = 'Table Types'.
        WHEN 'XSLT'.
          lv_name1 = 'Transformations'.
        WHEN 'Dış Kaynak'.
          lv_name1 = 'Dış Kaynak'.
        WHEN 'SUBFLD'.
          CALL METHOD gr_alv_tree->get_outtab_line
            EXPORTING
              i_node_key  = node_key
            IMPORTING
              e_node_text = lv_node_folder_text.

          lv_name1    = lv_node_folder_text.
      ENDCASE.

      CLEAR gs_tree_key.
      READ TABLE gt_tree_key INTO gs_tree_key WITH KEY name1 = lv_name1.

      IF gs_tree_key IS NOT INITIAL.
        lv_add_node_key = gs_tree_key-child.
      ELSE.
        lv_add_node_key = node_key.
      ENDIF.

      CALL METHOD gr_alv_tree->add_node
        EXPORTING
          i_relat_node_key = lv_add_node_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = node_info
          is_node_layout   = ls_add_node_layout
          i_node_text      = lv_add_node_text
        IMPORTING
          e_new_node_key   = gv_new_node_key.

      CALL METHOD gr_alv_tree->frontend_update.

      IF lv_node_flag IS INITIAL.
        lv_node_flag = 'X'.
        MOVE gv_new_node_key TO node_exp.
      ENDIF.
    ENDIF.

    IF sy-subrc = 0.

      SELECT SINGLE MAX( idxnm ) FROM zncprh_t005 INTO ls_t023_add-idxnm.

      ls_t023_add-idxnm = ls_t023_add-idxnm + 1.

      READ TABLE gt_node_key INTO gs_node_key WITH KEY name1 = lv_name1.

      IF gs_node_key IS NOT INITIAL.


        MOVE : gs_node_key-child   TO ls_t023_add-parent,
               gv_new_node_key     TO ls_t023_add-child ,
               otype               TO ls_t023_add-otype .

      ELSE.

        MOVE : lv_add_node_key     TO ls_t023_add-parent,
               gv_new_node_key     TO ls_t023_add-child ,
               otype               TO ls_t023_add-otype .

      ENDIF.

      MOVE : lv_add_node_key     TO gs_tree_key-parent,
             gv_new_node_key     TO gs_tree_key-child ,
             lv_add_node_text    TO gs_tree_key-name1 ,
             otype               TO gs_tree_key-otype .

      APPEND gs_tree_key TO gt_tree_key.

      CASE otype.
        WHEN 'FLD'.
          MOVE lv_text TO ls_t023_add-name1.
        WHEN 'DOC'.
          MOVE  program_name TO ls_t023_add-name1.
      ENDCASE.

      CONDENSE : ls_t023_add-idxnm,
                 ls_t023_add-name1,
                 ls_t023_add-otype NO-GAPS.


      INSERT zncprh_t005 FROM ls_t023_add.
      APPEND ls_t023_add TO gt_t023.

    ENDIF.



  ENDMETHOD.                    "add_node

  METHOD del_node.

    DATA : lv_subrc    TYPE sy-subrc,
           ls_del_node TYPE ty_node_key.

    READ TABLE gt_tree_key INTO gs_tree_key WITH KEY child = node_key.

    IF gs_tree_key-parent NE '          1'.
      me->delete_document(
        EXPORTING
          node_key = node_key
          otype    = otype
        IMPORTING
          subrc    = lv_subrc ).

      IF lv_subrc = 0.
        CALL METHOD gr_alv_tree->delete_subtree
          EXPORTING
            i_node_key = node_key.    " Node to be Deleted

        CALL METHOD gr_alv_tree->frontend_update.

      ENDIF.
    ELSE.
      MESSAGE 'Ana birime bağlı klasörler silinemez!' TYPE 'I'.
    ENDIF.



  ENDMETHOD.                    "del_node

  METHOD outsource_doc.

    DATA : lt_solix    TYPE ty_solix-solix,
           lv_filename TYPE string,
           lv_subrc    TYPE sy-subrc,
           ls_t024_os  TYPE zncprh_t006.

    me->gui_upload(
      IMPORTING
        u_solix   = lt_solix
        file_name = lv_filename  ).

    me->upload_document(
      EXPORTING
        program_name = lv_filename
        solix        = lt_solix
      IMPORTING
        subrc        = lv_subrc ).

    IF lv_subrc = 0.

      me->get_object_info(
        EXPORTING
          object_name = lv_filename
          program_type = 'DOC'
          operation_type = 'INS'
        IMPORTING
          info_data    = ls_t024_os ).

      me->add_node(
        EXPORTING
          node_key     = node_key
          otype        = 'DOC'
*          clear_flag   =
          program_name = lv_filename
          node_info    = ls_t024_os
          program_type = 'Dış Kaynak' ).
      INSERT zncprh_t006 FROM ls_t024_os.
      CLEAR ls_t024_os.

    ENDIF.

  ENDMETHOD.                    "outsource_doc

  METHOD gui_upload.

    DATA : lv_filename TYPE string,
           lv_path     TYPE string.

    CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
      EXPORTING
        window_title = 'Doküman Yükleme Ekranı'
      IMPORTING
        filename     = lv_filename
        fullpath     = lv_path.


    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename = lv_filename
        filetype = 'BIN'
      TABLES
        data_tab = u_solix.

    file_name = lv_filename.

  ENDMETHOD.                    "gui_upload

  METHOD get_object_info.

    CASE program_type.
      WHEN 'FMNAM'."Function Module
        info_data-subc = 'Fonksiyon Modülü'.
      WHEN 'FUGR'."Function Group
        info_data-subc = 'Fonksiyon Grubu'.
      WHEN 'CLAS'."Class
        info_data-subc = 'Global Class'.
      WHEN 'PROG'."'Program'
        info_data-subc = 'Yürütülebilir Program'.
      WHEN 'INCL'."Include Program
        info_data-subc = 'Include Program'.
      WHEN 'MSCLAS'."Message Class
        info_data-subc = 'Mesaj Classı'.
      WHEN 'DBTAB'.
        info_data-subc = 'Veritabanı Tablosu'.
      WHEN 'STRUC'."Database Tables
        info_data-subc = 'Structure'.
      WHEN 'TABTY'."Table Types
        info_data-subc = 'Table Type'.
      WHEN 'XSLT'.
        info_data-subc = 'Transformation'.
    ENDCASE.

    info_data-cdat = sy-datum.
    info_data-cnam = sy-uname.
    info_data-utime = sy-uzeit.
    info_data-progname = object_name.
    IF program_type IS NOT INITIAL.
      info_data-docty = 'HTML'.
    ELSE.
      info_data-docty = 'Dış kaynak'.
    ENDIF.

  ENDMETHOD.                    "get_html_head


ENDCLASS.                    "lcl_report IMPLEMENTATION
