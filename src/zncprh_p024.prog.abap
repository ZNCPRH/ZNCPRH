*&---------------------------------------------------------------------*
*& Report ZNCPRH_P024
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p024.

INCLUDE ole2incl.

TABLES : pa0001,
         pa0105,
         pa0770.

DATA : BEGIN OF gs_data,
         pernr      TYPE persno,
         ename      TYPE emnam,
         tarih(10),
         onay       TYPE emnam,
         merni      TYPE ptr_merni,
         usrid      TYPE sysid,
         usrid_long TYPE comm_id_long,
       END OF gs_data,
       gt_data  LIKE TABLE OF gs_data,
       ename    TYPE emnam,
       gv_ucomm TYPE sy-ucomm.

DATA : BEGIN OF gs_word,
         name  TYPE  text50,
         value TYPE  text1000,
       END OF gs_word,
       gt_word LIKE TABLE OF gs_word.

DATA: gs_find  TYPE ole2_object,
*       gs_replace TYPE ole2_object,
      gs_range TYPE ole2_object,
*       gs_footer  TYPE ole2_object,
      found    TYPE i.
SELECTION-SCREEN BEGIN OF BLOCK b1.
PARAMETERS : p_pernr TYPE persno OBLIGATORY MATCHCODE OBJECT prem.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF SCREEN 100.
SELECTION-SCREEN BEGIN OF BLOCK b2.
PARAMETERS : p_tarih TYPE dats OBLIGATORY,
             p_onay  TYPE emnam OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF SCREEN 100.

INITIALIZATION.

AT SELECTION-SCREEN ON BLOCK b1.

  SELECT COUNT( * ) FROM pa0001 UP TO 1 ROWS WHERE pernr = p_pernr.

  IF sy-subrc NE 0.
    MESSAGE 'Bu personel numarasına ait personel yok!' TYPE 'W'.
    STOP.
  ENDIF.
  SELECT SINGLE p01~pernr  ename
                merni  usrid  usrid_long
                 FROM pa0001 AS p01
           INNER JOIN pa0105 AS p15
                   ON p01~pernr EQ p15~pernr
           INNER JOIN pa0770 AS p77
                   ON p01~pernr EQ p77~pernr
  INTO CORRESPONDING FIELDS OF gs_data
                WHERE p01~pernr EQ p_pernr.

  gs_data-pernr = 1362.
  gs_data-ename = 'Necip Reha Ertuğ'.
  gs_data-merni = '18233188600'.
  gs_data-usrid = 'P1362'.
  gs_data-usrid_long = 'necip.ertug@detaysoft.com'.
*  IF sy-subrc NE 0.
*    MESSAGE 'Bu personele ait bilgiler bulunamadı!' TYPE 'W'.
*    STOP.
*  ENDIF.

AT SELECTION-SCREEN ON BLOCK b2.
  gs_data-onay = p_onay.
  CONCATENATE p_tarih+6(2) '.' p_tarih+4(2) '.' p_tarih(4) INTO gs_data-tarih.

AT SELECTION-SCREEN OUTPUT.



START-OF-SELECTION.

  CALL SELECTION-SCREEN 100.

  PERFORM set_word.
  CALL SCREEN 0200.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  get_word
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_word.

  CLASS c_oi_errors DEFINITION LOAD.
  CLASS cl_gui_cfw DEFINITION LOAD.
  DATA: container TYPE REF TO cl_gui_custom_container.
  DATA: item_url(256).
  DATA: control TYPE REF TO i_oi_container_control.
  DATA: link_server_decl TYPE REF TO i_oi_link_server.
  DATA: retcode       TYPE soi_ret_string,
        document_type TYPE soi_document_type
*                          VALUE soi_doctype_excel97_sheet.
                          VALUE soi_doctype_word97_document.
  DATA: proxy TYPE REF TO i_oi_document_proxy.
  DATA: bds_instance  TYPE REF TO cl_bds_document_set,
        doc_uris      TYPE sbdst_uri,
        wa_doc_uris   LIKE LINE OF doc_uris,
*        doc_components   TYPE sbdst_components,
        doc_signature TYPE sbdst_signature.
*        wa_doc_signature LIKE LINE OF doc_signature.

  retcode = c_oi_errors=>ret_ok.
  IF control IS INITIAL.
    DATA: b_has_activex.

    CALL FUNCTION 'GUI_HAS_ACTIVEX'
      IMPORTING
        return = b_has_activex.
    IF b_has_activex IS INITIAL.
      MESSAGE 'No Windows GUI' TYPE 'I'.EXIT.
    ENDIF.

    CALL METHOD c_oi_container_control_creator=>get_container_control
      IMPORTING
        control = control
        retcode = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    CREATE OBJECT container
      EXPORTING
        container_name = 'CONTAINER'.

    CALL METHOD control->init_control
      EXPORTING
        r3_application_name      = 'İletişim Bilgileri'
        inplace_enabled          = ''
        inplace_scroll_documents = 'X'
        parent                   = container
        register_on_close_event  = 'X'
        register_on_custom_event = 'X'
      IMPORTING
        retcode                  = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    CALL METHOD control->get_link_server
      IMPORTING
        link_server = link_server_decl
        retcode     = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

    CALL METHOD link_server_decl->start_link_server
      IMPORTING
        retcode = retcode.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.

* Fill the template
    IF  control IS NOT INITIAL.
      CALL METHOD control->get_document_proxy
        EXPORTING
          document_type  = document_type
        IMPORTING
          document_proxy = proxy
          retcode        = retcode.
      IF bds_instance IS INITIAL.
        CREATE OBJECT bds_instance.
      ENDIF.
      CALL METHOD bds_instance->get_with_url
        EXPORTING
          classname = 'ZNCPRH_P024'
          classtype = 'OT'
*         object_key = 'TEST1'
*         object_key = 'TEST2'
        CHANGING
          uris      = doc_uris
          signature = doc_signature.
      READ TABLE doc_uris INTO wa_doc_uris INDEX 1.
      item_url = wa_doc_uris-uri.
      IF  bds_instance IS NOT INITIAL.
        FREE bds_instance.
      ENDIF.
      CALL METHOD proxy->open_document
        EXPORTING
          open_inplace = 'X'
          document_url = item_url.
      CALL METHOD proxy->update_document_links
        IMPORTING
          retcode = retcode.
      CALL METHOD c_oi_errors=>show_message
        EXPORTING
          type = 'E'.
    ENDIF.
  ENDIF.

***  find documents
  CHECK  proxy IS NOT INITIAL.
*     straight ole automation
  DATA: document_cntl_handle TYPE cntl_handle.

  DATA: ocharacters  TYPE ole2_object.
*        orange       TYPE ole2_object,
*        oreplacement TYPE ole2_object,
*        ofind        TYPE ole2_object,
*        ofont        TYPE ole2_object.

  DATA: char_count    TYPE i,
        char_position TYPE i.
*            old_search_string LIKE search,
*        string_found  TYPE i,
*        color_index   TYPE i.

  CALL METHOD proxy->get_document_handle
    IMPORTING
      handle  = document_cntl_handle
      retcode = retcode.
  CALL METHOD c_oi_errors=>show_message
    EXPORTING
      type = 'E'.
*        get number of document characters.
  GET PROPERTY OF document_cntl_handle-obj
                 'characters' = ocharacters.
  GET PROPERTY OF ocharacters 'count' = char_count.
  char_position = 0.
*        old_search_string = search.

*     set range now
  IF char_position >= char_count.
    char_position = 0.
  ENDIF.

  GET PROPERTY OF document_cntl_handle-obj 'CONTENT' = gs_range.

  LOOP AT gt_word INTO gs_word.
    PERFORM replace_text USING gs_word-name gs_word-value.
  ENDLOOP.

  IF  bds_instance IS NOT INITIAL.
    FREE bds_instance.
  ENDIF.
  IF  proxy IS NOT INITIAL.
    FREE proxy.
  ENDIF.
  IF  control IS NOT INITIAL.
    FREE control.
  ENDIF.

  IF  link_server_decl IS NOT INITIAL.
    CALL METHOD link_server_decl->stop_link_server
      IMPORTING
        retcode = retcode.
    FREE link_server_decl.
  ENDIF.

*  LEAVE TO SCREEN 0.
ENDFORM.                    "get_word


*&---------------------------------------------------------------------*
*&      Form  SET_WORD
*&---------------------------------------------------------------------*
FORM set_word.

  gs_word-name = '<<TARIH>>'.
  gs_word-value = gs_data-tarih.
  APPEND gs_word TO gt_word.

  gs_word-name = '<<PERNR>>'.
  gs_word-value = gs_data-pernr.
  APPEND gs_word TO gt_word.

  gs_word-name = '<<MERNI>>'.
  gs_word-value = gs_data-merni.
  APPEND gs_word TO gt_word.

  gs_word-name = '<<ENAME>>'.
  gs_word-value = gs_data-ename.
  APPEND gs_word TO gt_word.

  gs_word-name = '<<USRID>>'.
  gs_word-value = gs_data-usrid.
  APPEND gs_word TO gt_word.

  gs_word-name = '<<USRID_LONG>>'.
  gs_word-value = gs_data-usrid_long.
  APPEND gs_word TO gt_word.

  gs_word-name = '<<ONAY>>'.
  gs_word-value = p_onay.
  APPEND gs_word TO gt_word.

  gs_word-name = '<<TEST>>'.
  gs_word-value = p_onay.
  APPEND gs_word TO gt_word.

ENDFORM.                    "set_word


*&---------------------------------------------------------------------*
*&      Form  replace_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FIND_TEXT     text
*      -->P_REPLACE_TEXT  text
*----------------------------------------------------------------------*
FORM replace_text USING p_find_text p_replace_text.

  GET PROPERTY OF gs_range 'FIND' = gs_find.
  CALL METHOD OF
    gs_find
    'Execute'
    EXPORTING
      #1 = p_find_text.
  GET PROPERTY OF gs_find 'Found' = found.
  IF found > 0.

    CALL METHOD OF
      gs_find
      'EXECUTE'
      EXPORTING
        #1  = p_find_text
        #2  = 'False'
        #3  = 'False'
        #4  = 'False'
        #5  = 'False'
        #6  = 'False'
        #7  = 'True'
        #8  = '1'
        #9  = 'True'
        #10 = p_replace_text
        #11 = '2'
        #12 = 'True'
        #13 = 'True'
        #14 = 'True'
        #15 = 'True'.

  ENDIF.

ENDFORM.                    "replace_text
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'GUI'.
*  SET TITLEBAR 'xxx'.
  PERFORM get_word.
ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
