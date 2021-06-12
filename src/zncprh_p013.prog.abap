*&---------------------------------------------------------------------*
*& Report ZNCPRH_P013
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p013.


DATA: it_flight TYPE TABLE OF sflight.

DATA: ok_code LIKE sy-ucomm,
      save_ok LIKE sy-ucomm.

DATA:
  g_container   TYPE scrfname VALUE 'CONTROL',
  o_dyndoc_id   TYPE REF TO cl_dd_document,
  o_splitter    TYPE REF TO cl_gui_splitter_container,
  o_parent_grid TYPE REF TO cl_gui_container,
  o_parent_top  TYPE REF TO cl_gui_container,
  o_html_cntrl  TYPE REF TO cl_gui_html_viewer,
  o_down_grid   TYPE REF TO cl_gui_container,
  g_grid        TYPE REF TO cl_gui_alv_grid.

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION .
  PUBLIC SECTION .
    METHODS:
*Event Handler for Top of page
      top_of_page FOR EVENT top_of_page
                  OF cl_gui_alv_grid
        IMPORTING e_dyndoc_id,
      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id  es_row_no .
ENDCLASS.             "lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_HANDLER IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD top_of_page.
* Top-of-page event
    PERFORM event_top_of_page USING o_dyndoc_id.

  ENDMETHOD.                            "top_of_page

  METHOD handle_hotspot_click..
    IF e_column_id EQ 'SEATSOCC'.
      FREE o_dyndoc_id.
* Create TOP-Document
      CREATE OBJECT o_dyndoc_id
        EXPORTING
          style = 'ALV_GRID'.
* Top-of-page event
      PERFORM event_top_of_pageupd USING o_dyndoc_id e_row_id.
    ENDIF.
  ENDMETHOD.                    "handle_hotspot_click
ENDCLASS.       "LCL_EVENT_HANDLER IMPLEMENTATION


DATA: g_custom_container TYPE REF TO cl_gui_custom_container,
      g_handler          TYPE REF TO lcl_event_handler. "handler

START-OF-SELECTION.
  SELECT *
  FROM sflight
  UP TO 20 ROWS
  INTO TABLE it_flight.

END-OF-SELECTION.

  IF NOT it_flight[] IS INITIAL.
    CALL SCREEN 100.
  ELSE.
*    MESSAGE i002 WITH 'NO DATA FOR THE SELECTION'(004).
  ENDIF.
*----------------------------------------------------------------------*
*  MODULE STATUS_0100 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'GUI'.
  SET TITLEBAR 'TITLE'.
  IF g_custom_container IS INITIAL.
    PERFORM create_and_init_alv.
  ENDIF.
ENDMODULE.                 " STATUS_0100  OUTPUT
*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_and_init_alv .


  DATA: lt_fcat TYPE                  slis_t_fieldcat_alv,
        ls_fcat TYPE                  slis_fieldcat_alv.

  DATA: lt_fcat_l          TYPE                  lvc_t_fcat.
  FIELD-SYMBOLS <fs_fcat>  TYPE LINE OF          lvc_t_fcat.

  CREATE OBJECT g_custom_container
    EXPORTING
      container_name = g_container.

* Create TOP-Document
  CREATE OBJECT o_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.
* Create Splitter for custom_container
  CREATE OBJECT o_splitter
    EXPORTING
      parent  = g_custom_container
      rows    = 2
      columns = 1.
  CALL METHOD o_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = o_parent_top.

  CALL METHOD o_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = o_parent_grid.

* Set height for g_parent_html
  CALL METHOD o_splitter->set_row_height
    EXPORTING
      id     = 1
      height = 20.

  CALL METHOD o_splitter->set_row_height
    EXPORTING
      id     = 2
      height = 40.

  CREATE OBJECT g_grid
    EXPORTING
      i_parent = o_parent_grid.
  CREATE OBJECT g_handler.

  SET HANDLER g_handler->top_of_page          FOR g_grid.
  SET HANDLER g_handler->handle_hotspot_click FOR g_grid .
*Calling the Method for ALV output

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name   = sy-repid
      i_structure_name = 'SFLIGHT'
      i_inclname       = sy-repid
    CHANGING
      ct_fieldcat      = lt_fcat
    EXCEPTIONS
      error_message    = 1
      OTHERS           = 2.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = lt_fcat
    IMPORTING
      et_fieldcat_lvc = lt_fcat_l
    TABLES
      it_data         = it_flight.

  READ TABLE lt_fcat_l ASSIGNING <fs_fcat> WITH KEY fieldname = 'SEATSOCC'.
  <fs_fcat>-hotspot = 'X'.


  CALL METHOD g_grid->set_table_for_first_display
    CHANGING
      it_fieldcatalog = lt_fcat_l
      it_outtab       = it_flight[].
*
  CALL METHOD o_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea.

* Processing events
  CALL METHOD g_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = o_dyndoc_id.

ENDFORM.                     "CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*&      Form  EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM event_top_of_page USING   dg_dyndoc_id TYPE REF TO cl_dd_document.


  DATA : dl_text(255) TYPE c.  "Text

  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text         = 'Flight Details'
      sap_style    = cl_dd_area=>heading
      sap_fontsize = cl_dd_area=>large
      sap_color    = cl_dd_area=>list_heading_int.

  CALL METHOD dg_dyndoc_id->add_gap
    EXPORTING
      width = 200.

* Run Date
  dl_text = 'Run Date :'.

  CALL METHOD o_dyndoc_id->add_text
    EXPORTING
      text         = dl_text
      sap_emphasis = cl_dd_area=>heading
      sap_color    = cl_dd_area=>list_heading_int.

  CLEAR dl_text.
  CALL METHOD dg_dyndoc_id->add_gap
    EXPORTING
      width = 2.
* Move date
  WRITE sy-datum TO dl_text.

  CALL METHOD o_dyndoc_id->add_text
    EXPORTING
      text         = dl_text
      sap_emphasis = cl_dd_area=>heading
      sap_color    = cl_dd_area=>list_negative_inv.

* Add new-line
  CALL METHOD dg_dyndoc_id->new_line.
  CLEAR : dl_text.

  dl_text = 'Tıklanan :'.

  CALL METHOD o_dyndoc_id->add_text
    EXPORTING
      text         = dl_text
      sap_emphasis = cl_dd_area=>heading
      sap_color    = cl_dd_area=>list_heading_int.

  CLEAR dl_text.
  CALL METHOD dg_dyndoc_id->add_gap
    EXPORTING
      width = 3.

* Add new-line
  CALL METHOD dg_dyndoc_id->new_line.

  PERFORM display.

*  CALL METHOD dg_dyndoc_id->add_text
*    EXPORTING
*      text         = 'Flight Details'
*      sap_style    = cl_dd_area=>heading
*      sap_fontsize = cl_dd_area=>large
*      sap_color    = cl_dd_area=>list_heading_int.
*
*  CALL METHOD dg_dyndoc_id->add_gap
*    EXPORTING
*      width = 200.
*
*  CALL METHOD o_dyndoc_id->add_picture
*    EXPORTING
*      picture_id = 'ENJOYSAP_LOGO'.
*
** Add new-line
*  CALL METHOD dg_dyndoc_id->new_line.
*
*  CALL METHOD dg_dyndoc_id->new_line.
*
*
*  CLEAR : dl_text.
*
** program ID
*  dl_text = 'Program Name :'.
*
*  CALL METHOD dg_dyndoc_id->add_gap.
*
*  CALL METHOD o_dyndoc_id->add_text
*    EXPORTING
*      text         = dl_text
*      sap_emphasis = cl_dd_area=>heading
*      sap_color    = cl_dd_area=>list_heading_int.
*
*  CLEAR dl_text.
*
*  dl_text = sy-repid.
*
*  CALL METHOD o_dyndoc_id->add_text
*    EXPORTING
*      text         = dl_text
*      sap_emphasis = cl_dd_area=>heading
*      sap_color    = cl_dd_area=>list_negative_inv.
*
** Add new-line
*  CALL METHOD dg_dyndoc_id->new_line.
*
*
*  CLEAR : dl_text.
*
*
** program ID
*  dl_text = 'User Name :'.
*
*  CALL METHOD dg_dyndoc_id->add_gap.
*
*  CALL METHOD o_dyndoc_id->add_text
*    EXPORTING
*      text         = dl_text
*      sap_emphasis = cl_dd_area=>heading
*      sap_color    = cl_dd_area=>list_heading_int.
*
*  CLEAR dl_text.
*
*  dl_text = sy-uname.
*
*  CALL METHOD o_dyndoc_id->add_text
*    EXPORTING
*      text         = dl_text
*      sap_emphasis = cl_dd_area=>heading
*      sap_color    = cl_dd_area=>list_negative_inv.
*
** Add new-line
*  CALL METHOD dg_dyndoc_id->new_line.
*
*
*  CLEAR : dl_text.
*
** Run Date
*  dl_text = 'Run Date :'.
*
*
*  CALL METHOD o_dyndoc_id->add_text
*    EXPORTING
*      text         = dl_text
*      sap_emphasis = cl_dd_area=>heading
*      sap_color    = cl_dd_area=>list_heading_int.
*
*  CLEAR dl_text.
*  CALL METHOD dg_dyndoc_id->add_gap
*    EXPORTING
*      width = 2.
** Move date
*  WRITE sy-datum TO dl_text.
*
*  CALL METHOD o_dyndoc_id->add_text
*    EXPORTING
*      text         = dl_text
*      sap_emphasis = cl_dd_area=>heading
*      sap_color    = cl_dd_area=>list_negative_inv.
*
** Add new-line
*  CALL METHOD dg_dyndoc_id->new_line.
*
*  CLEAR : dl_text.
*
**Time
*  dl_text = 'Time :'.
*
*  CALL METHOD dg_dyndoc_id->add_gap.
*
*  CALL METHOD o_dyndoc_id->add_text
*    EXPORTING
*      text         = dl_text
*      sap_emphasis = cl_dd_area=>heading
*      sap_color    = cl_dd_area=>list_heading_int.
*
*  CLEAR dl_text.
*
** Move time
*  WRITE sy-uzeit TO dl_text.
*
*  CALL METHOD o_dyndoc_id->add_text
*    EXPORTING
*      text         = dl_text
*      sap_emphasis = cl_dd_area=>heading
*      sap_color    = cl_dd_area=>list_negative_inv.
*
** Add new-line
*  CALL METHOD dg_dyndoc_id->new_line.
*
*
*  PERFORM display.

ENDFORM.                    " EVENT_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display.

* Creating html control
  IF o_html_cntrl IS INITIAL.
    CREATE OBJECT o_html_cntrl
      EXPORTING
        parent = o_parent_top.
  ENDIF.
  CALL METHOD o_dyndoc_id->merge_document.
  o_dyndoc_id->html_control = o_html_cntrl.
* Display document
  CALL METHOD o_dyndoc_id->display_document
    EXPORTING
      reuse_control      = 'X'
      parent             = o_parent_top
    EXCEPTIONS
      html_display_error = 1.
  IF sy-subrc NE 0.
*    MESSAGE i999 WITH 'Error in displaying top-of-page'(036).
  ENDIF.
ENDFORM.                    " display

*&---------------------------------------------------------------------*
*&      Form  event_top_of_pageupd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DG_DYNDOC_ID  text
*----------------------------------------------------------------------*
FORM event_top_of_pageupd USING   dg_dyndoc_id TYPE REF TO cl_dd_document
                                  row_id       TYPE        lvc_s_row.

  DATA : dl_text(255) TYPE c.  "Text
  DATA ls_data LIKE LINE OF it_flight.
  READ TABLE it_flight INTO ls_data INDEX row_id-index.
  CHECK sy-subrc EQ 0.
  CALL METHOD dg_dyndoc_id->add_text
    EXPORTING
      text         = 'Uçuş Detayları'
      sap_style    = cl_dd_area=>heading
      sap_fontsize = cl_dd_area=>large
      sap_color    = cl_dd_area=>list_heading_int.

  CALL METHOD dg_dyndoc_id->add_gap
    EXPORTING
      width = 200.

* Run Date
  dl_text = 'Run Date :'.

  CALL METHOD o_dyndoc_id->add_text
    EXPORTING
      text         = dl_text
      sap_emphasis = cl_dd_area=>heading
      sap_color    = cl_dd_area=>list_heading_int.

  CLEAR dl_text.
  CALL METHOD dg_dyndoc_id->add_gap
    EXPORTING
      width = 2.
* Move date
  WRITE sy-datum TO dl_text.

  CALL METHOD o_dyndoc_id->add_text
    EXPORTING
      text         = dl_text
      sap_emphasis = cl_dd_area=>heading
      sap_color    = cl_dd_area=>list_negative_inv.

* Add new-line
  CALL METHOD dg_dyndoc_id->new_line.
  CLEAR : dl_text.

  dl_text = 'Tıklanan :' && ls_data-seatsocc.

  CALL METHOD o_dyndoc_id->add_text
    EXPORTING
      text         = dl_text
      sap_emphasis = cl_dd_area=>heading
      sap_color    = cl_dd_area=>list_heading_int.

  CLEAR dl_text.
  CALL METHOD dg_dyndoc_id->add_gap
    EXPORTING
      width = 3.

* Add new-line
  CALL METHOD dg_dyndoc_id->new_line.

  PERFORM display.

ENDFORM.                    " EVENT_TOP_OF_PAGE
