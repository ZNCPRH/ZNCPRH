class ZNCPRH_CL002 definition
  public
  final
  create public .

public section.

  class-methods SEND_MAIL_001
    importing
      !I_GROUPMAIL type SO_OBJ_NAM optional
      !IT_RECEIVER type ZNCPRH_TT003
      !IP_CONTENT type RSSCE-TDNAME optional
      !T_P type ZNCPRH_TT004 optional
      !I_SENDER type AD_SMTPADR
      !IT_ATTACHMENTS type ZNCPRH_TT005 optional
      !I_LANGU type SY-LANGU optional
      !COMMIT type FC_ACTIV optional
      !HTML_STRING type STRING optional
    exporting
      !T_RETURN type FMFG_T_BAPIRETURN
    changing
      !SUBJECT type SO_OBJ_DES optional
      !IT_TEXT type BCSY_TEXT optional .
  class-methods SEND_MAIL_WITH_IMAGE
    importing
      !IT_RECEIVER type ZNCPRH_TT006
      !IP_CONTENT type RSSCE-TDNAME optional
      !IT_BODY_TEXT type BCSY_TEXT optional
      !T_P type ZNCPRH_TT007 optional
      !I_SENDER type AD_SMTPADR
      !IT_ATTACHMENTS type ZNCPRH_TT008 optional
      !I_LANGU type SY-LANGU default SY-LANGU
      !ADD_SENDER_TO_BCC type CHAR1 default ''
      !I_SUBJECT type SO_OBJ_DES optional
      !IP_CONTENT_TDID type TDID default 'ST'
      !PTAB type ZNCPRH_TT009 optional
      !IV_NEXT_DAY type DATS optional
      !IV_NEXT_TIM type TIMS optional
    exporting
      !T_RETURN type FMFG_T_BAPIRETURN .
  class-methods GET_MAIL_MIME_IMAGE
    changing
      value(CH_CO_HELPER) type ref to CL_GBT_MULTIRELATED_SERVICE optional .
  class-methods GET_FCAT_MAIL
    importing
      !IV_TABNAME type TABNAME
    changing
      !CH_FCAT type LVC_T_FCAT .
  class-methods ITAB_FCAT_MAIL_CONTENT
    importing
      !ITAB type DATA
      !FCAT type LVC_T_FCAT
      !MESSAGE type STRING
    exporting
      !EV_HTML type STRING .
  class-methods SEND_MAIL_BASIC
    importing
      value(IP_REC) type BCSY_SMTPA optional
      value(IP_REC_CC) type BCSY_SMTPA optional
      value(IP_BODY) type SRM_T_SOLISTI1 optional
      value(IP_SENDER) type SO_REC_EXT optional
      value(IP_SIZE) type I
      value(IP_SIZE2) type I
      value(IP_CONTENT_HEX) type SOLIX_TAB
      value(IP_CONTENT_HEX2) type SOLIX_TAB .
protected section.
private section.
ENDCLASS.



CLASS ZNCPRH_CL002 IMPLEMENTATION.


METHOD get_fcat_mail.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      i_structure_name       = iv_tabname
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_BYPASSING_BUFFER     =
*     I_INTERNAL_TABNAME     =
    CHANGING
      ct_fieldcat            = ch_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMETHOD.


  METHOD get_mail_mime_image.

    DATA : lo_mime_helper TYPE REF TO cl_gbt_multirelated_service .
    DATA : gv_mr_api TYPE REF TO if_mr_api .
    DATA : url TYPE string.
    DATA : lv_obj_len TYPE so_obj_len .
    DATA : is_folder TYPE boole_d,
           content   TYPE xstring,
           loio      TYPE skwf_io.

    DATA : l_obj_len         TYPE i,
           lv_graphic_length TYPE i,
           l_offset          TYPE i,
           l_length          TYPE i,
           l_diff            TYPE i,
           gr_xstr           TYPE xstring,
           l_filename        TYPE string,
           l_content_id      TYPE mime_cntid.

    DATA : lt_solix TYPE STANDARD TABLE OF solix,
           ls_solix LIKE LINE OF lt_solix.

    DATA : lt_content TYPE bcsy_text .
    DATA : ls_content TYPE soli .
*=======================================================================
    DEFINE convert_pic .
      gv_mr_api = cl_mime_repository_api=>if_mr_api~get_api( ) .
      CONCATENATE '/SAP/PUBLIC/' &1 INTO url.
      CALL METHOD gv_mr_api->get
        EXPORTING
          i_url                  = url
          i_check_authority      = space
        IMPORTING
          e_is_folder            = is_folder
          e_content              = content
          e_loio                 = loio
        EXCEPTIONS
          parameter_missing      = 1
          error_occured          = 2
          not_found              = 3
          permission_failure     = 4
          OTHERS                 = 5
              .
      IF sy-subrc <> 0. EXIT . ENDIF.
      l_obj_len = xstrlen( content ) .
      lv_graphic_length = xstrlen( content ) .

      CLEAR gr_xstr .
      gr_xstr = content(l_obj_len) .
      l_offset = 0 .
      l_length = 255 .

      CLEAR lt_solix[] .

      WHILE l_offset < lv_graphic_length.
        l_diff = lv_graphic_length - l_offset .
        IF l_diff > l_length .
          ls_solix-line = gr_xstr+l_offset(l_length) .
        ELSE .
          ls_solix-line = gr_xstr+l_offset(l_diff) .
        ENDIF.
        APPEND ls_solix TO lt_solix .
        ADD l_length TO l_offset .
      ENDWHILE.

      l_filename   = &1 .
      l_content_id = &1 .

      lv_obj_len = l_obj_len .
      CALL METHOD lo_mime_helper->add_binary_part
        EXPORTING
          content      = lt_solix
          filename     = l_filename
          extension    = 'JPG'
          content_type = 'image/jpg'
          length       = lv_obj_len
          content_id   = l_content_id.

      CLEAR : gv_mr_api, is_folder, content, loio, l_obj_len,
              lv_graphic_length, l_obj_len.

    END-OF-DEFINITION.
*=======================================================================

    CREATE OBJECT lo_mime_helper .
    convert_pic 'hroneucx.png'. "mime dosya adı

    ch_co_helper = lo_mime_helper .

  ENDMETHOD.


METHOD itab_fcat_mail_content.

  FIELD-SYMBOLS <f_table> TYPE ANY TABLE.
  FIELD-SYMBOLS <f_data> TYPE any.
  FIELD-SYMBOLS <f_val> TYPE any.
  FIELD-SYMBOLS <f_tot> TYPE any.
  DATA ls_fcat TYPE lvc_s_fcat.
  DATA lv_text TYPE string.
  DATA lv_head TYPE string.
  DATA lv_html TYPE string.
  DATA lv_total TYPE string.
  DATA lv_item TYPE string.
  DATA lv_header TYPE string.
  DATA lv_obj_head TYPE so_obj_des.
  DATA lt_receiver TYPE bcsy_smtpa.
  DATA lv_mail TYPE ad_smtpadr.
  DATA lv_tabix TYPE sy-tabix.
  DATA lv_tabix_fc TYPE sy-tabix.
  DATA : BEGIN OF ls_totals ,
           fieldname TYPE lvc_fname,
           total     TYPE char50,
         END OF ls_totals.
  DATA : ls_totals_temp LIKE ls_totals.
  DATA lt_totals LIKE TABLE OF ls_totals.
  ASSIGN itab TO <f_table>[].
  CHECK <f_table>[] IS ASSIGNED AND
  fcat[] IS NOT INITIAL. " AND
  " lt_receiver[] IS NOT INITIAL.
  "Get Internal Table Value
  CLEAR : lv_tabix , lv_tabix_fc , lv_html , lv_header , lv_total ,
  lv_item .
  lv_total = lv_total && '<tr bgcolor = "#00FF00" >'."toplam sat˝r˝
  lv_total = lv_total && '<td class="centerText">' &&
  'Toplam:' && '</td>'.
  LOOP AT <f_table> ASSIGNING <f_data>.
    lv_tabix = sy-tabix.
    lv_item = lv_item && '<tr bgcolor = "#E6E6FF" >'.
    LOOP AT fcat INTO ls_fcat.
      lv_tabix_fc = sy-tabix.
      ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <f_data> TO <f_val>.
      CHECK <f_val> IS ASSIGNED. ".AND ls_fcat-no_out NE 'X'.
      IF ls_fcat-no_out NE 'X'.
        IF ls_fcat-scrtext_l NE space.
          lv_header = ls_fcat-scrtext_l .
        ELSEIF ls_fcat-scrtext_m NE space.
          lv_header = ls_fcat-scrtext_m .
        ELSEIF ls_fcat-scrtext_s NE space.
          lv_header = ls_fcat-scrtext_s .
        ELSE.
          lv_header = ls_fcat-fieldname.
        ENDIF.
        IF lv_tabix EQ 1."›lk sat˝r iÁin sadece ba˛l˝klar˝ almam˝z yeterli
          lv_head = lv_head && '<th class="header">' && lv_header
          && '</th> '.
        ENDIF.
        lv_item = lv_item && '<td class="centerText">' &&
        <f_val> && '</td>'.
      ENDIF.
      IF ls_fcat-do_sum EQ 'X'."Dip toplam varm˝ ? varsa toplatal˝m
        IF <f_tot> IS ASSIGNED.
          READ TABLE lt_totals TRANSPORTING NO FIELDS WITH KEY fieldname = ls_fcat-fieldname .
          IF sy-subrc NE 0.
            ADD <f_val> TO ls_totals-total.
            ls_totals-fieldname = ls_fcat-fieldname.
            APPEND ls_totals TO lt_totals.
            CLEAR ls_totals.
          ELSE.
            LOOP AT lt_totals INTO ls_totals
            WHERE fieldname = ls_fcat-fieldname ..
              ADD <f_val> TO ls_totals-total.
              MODIFY lt_totals FROM ls_totals TRANSPORTING total.
            ENDLOOP.
          ENDIF.
          " <f_tot> = <f_tot> + <f_val>.
        ELSE.
          "ASSIGN <f_val> TO <f_tot>.
          READ TABLE lt_totals TRANSPORTING NO FIELDS WITH KEY fieldname = ls_fcat-fieldname .
          IF sy-subrc NE 0.
            ADD <f_val> TO ls_totals-total.
            ls_totals-fieldname = ls_fcat-fieldname.
            APPEND ls_totals TO lt_totals.
            CLEAR ls_totals.
          ELSE.
            LOOP AT lt_totals INTO ls_totals
            WHERE fieldname = ls_fcat-fieldname ..
              ADD <f_val> TO ls_totals-total.
              MODIFY lt_totals FROM ls_totals TRANSPORTING total.
            ENDLOOP.
          ENDIF.
        ENDIF.
        "son sat˝rdayken hesapla yazd˝r
        IF lv_tabix EQ lines( <f_table>[] ).
          READ TABLE lt_totals INTO ls_totals
          WITH KEY fieldname = ls_fcat-fieldname .
          ASSIGN ls_totals-total TO <f_tot>.
          IF <f_tot> IS ASSIGNED.
            lv_total = lv_total && '<td class="centerText">' &&
            <f_tot> && '</td>'.
          ENDIF.
        ENDIF.
      ELSE."toplam yoksa bo˛luk atal˝m! "ilk sutun iÁin toplam yazd˝k!
        IF lv_tabix EQ lines( <f_table>[] ) AND lv_tabix_fc NE 1.
          lv_total = lv_total && '<td class="centerText">' &&
          '' && '</td>'.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF sy-subrc EQ 0.
      lv_item = lv_item && '</tr>'.
      IF lv_tabix EQ lines( <f_table>[] ).
        lv_total = lv_total && '</tr>'.
      ENDIF.
    ENDIF.
    CLEAR : lv_tabix_fc.
  ENDLOOP.
  "Ready HTML Mail Content
  CONCATENATE lv_html
  '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> '
  ' <style> '
  ' .header{text-align:center; font-size:15px; color:#FFF;'
  ' font-family:Tahoma, '
  'Geneva, sans-serif; '
  'background-color:#2889FF; border-bottom-style:solid;}'
  '.header2{text-align:center; font-size:15px; color:#FFF;'
  ' font-family:Tahoma,'
  'Geneva, sans-serif; padding-bottom:10px;'
  'background-color:#2889FF; border-bottom-style:solid; }'
  '.centerText{ '
  ' text-align: center; } '
  '.total{ text-align:center;'
  'font-size:18px; color:#333; '
  'font-family:Tahoma, Geneva, sans-serif;'
  'background-color:#F90; border-bottom-style:outset; line-height:25px;}'
  '.ftext{ padding-left:15px; font-family:Tahoma, Geneva, sans-serif;'
  'font-stretch:ultra-condensed; color:#03F; font-size:10px;}'
  '.err{ padding-left:10px; font-family:Tahoma, Geneva, sans-serif;'
  ' font-stretch:ultra-condensed; color:#900; font-size:20px;}'
  '.tbl tr { text-align:center; font-weight:bold;'
  " ' background-color:#E6E6FF;'"com@burak
  'color:#000; font-size:15px; line-height:30px;}'
  '.tbl tr:hover {background-color:#CCC; padding-left:4px;}.tbl td {}'
  '.tbl tr:nth-child(odd) { background-color:#EFEFEF; }'
  '.tbl th, td { border: 2px solid black; border-collapse: collapse; }'
  '</style> '
  '<p> <font color="black"> '
  message
  '</font></p>'
  '<table class="tbl" cellpadding="0" cellspacing="0" "width:100%" >'
  ' <tr class="header"> ' lv_head '</tr> '
  INTO lv_html.
  "Dip toplam al˝nm˝˛sa tabloya ekletelim !
  READ TABLE fcat TRANSPORTING NO FIELDS WITH KEY do_sum = 'X'.
  IF sy-subrc EQ 0 .
    lv_item = lv_item && lv_total.
  ENDIF.
  CONCATENATE lv_html lv_item
  '</table>'
  '<br> '
  '</div> ' INTO lv_html.
  ev_html = lv_html.

ENDMETHOD.


METHOD send_mail_001.
  DATA : lt_lines TYPE tlinetab,
         ls_line  TYPE tline.
  DATA : w_p     TYPE zncprh_s004,
         l_dg(5)              ,
         l_ds(5)              ,
         l_tabix LIKE sy-tabix,
         l_x(2)               ,
         tdline  TYPE tdline.

  DATA : document     TYPE REF TO cl_document_bcs,
         sent_to_all  TYPE os_boolean,
         send_request TYPE REF TO cl_bcs,
         sender       TYPE REF TO if_sender_bcs,
         recipient    TYPE REF TO if_recipient_bcs,
*         subject       TYPE so_obj_des             ,
         att_type     TYPE soodk-objtp VALUE 'HTM',
*         it_text       TYPE bcsy_text              ,
         wa_text      TYPE soli.

  DEFINE ap.
    APPEND wa_text TO it_text.
  END-OF-DEFINITION.

  DATA : BEGIN OF gs_data,
           solix  TYPE solix_tab,
           ext(3)               ,
           ftext  TYPE so_obj_des,
         END OF gs_data         .
  DATA : gt_data LIKE TABLE OF gs_data.

  DATA : ls_receiver TYPE zncprh_s003,
         l_receiver  TYPE comm_id_long.
  DATA : l_cc      TYPE os_boolean,
         l_bcc     TYPE os_boolean,
         l_xstring TYPE xstring.

  DATA : s_return TYPE bapireturn.

  DATA : lv_langu TYPE spras,
         lv_usrty TYPE usrty VALUE '0010'.

  lv_langu = i_langu.

  IF ip_content IS NOT INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'ST'
        language                = lv_langu
        name                    = ip_content
        object                  = 'TEXT'
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      s_return-type = 'W'.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              INTO s_return-message.
      APPEND s_return TO t_return.
      EXIT.
    ENDIF.
*  ENDIF.
    DATA :
           fname(20),
           l_id(2),
           flag,
           lv_for_url TYPE so_text255.
    FIELD-SYMBOLS <f> TYPE any.

    LOOP AT lt_lines INTO ls_line.
      CLEAR lv_for_url.
      MOVE sy-tabix TO l_tabix.
      CLEAR flag.
      CHECK flag NE 'X'.
      LOOP AT t_p INTO w_p.
*        CLEAR lv_for_url.
        CLEAR : l_dg , l_x.
        MOVE sy-tabix TO l_x.
        CONCATENATE '&'  l_x '&' INTO l_dg.

        IF lv_for_url IS INITIAL.
          lv_for_url = ls_line-tdline.
        ENDIF.
*        REPLACE ALL OCCURRENCES OF l_dg IN
*        ls_line-tdline WITH w_p-p.
        REPLACE ALL OCCURRENCES OF l_dg IN
        lv_for_url WITH w_p-p.
      ENDLOOP.
      IF l_tabix = 1.
        CONDENSE ls_line-tdline.
        subject = ls_line-tdline.
      ELSE.
*        wa_text = ls_line-tdline. ap.
        wa_text = lv_for_url. ap.
      ENDIF.
    ENDLOOP.

    DATA : cx_req_bcs TYPE REF TO cx_send_req_bcs,
           cx_add_bcs TYPE REF TO cx_address_bcs,
           cx_doc_bcs TYPE REF TO cx_document_bcs,
           lv_text    TYPE string.
    DATA : ls_attachments TYPE zncprh_s005.

    TRY.
        CALL METHOD cl_bcs=>create_persistent
          RECEIVING
            result = send_request.
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-type    = 'E'.
        s_return-message = lv_text.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.

    "HTML içerikler için
    DATA : v_subj(50),
           xhtml_string TYPE        xstring,
           t_hex        TYPE        solix_tab.
    IF html_string IS NOT INITIAL.
      " Html kodları işlenir...
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = html_string
        IMPORTING
          buffer = xhtml_string
        EXCEPTIONS
          failed = 1
          OTHERS = 2.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = xhtml_string
        TABLES
          binary_tab = t_hex.

      document = cl_document_bcs=>create_document(
      i_type    = 'HTM'
      i_hex    = t_hex
      i_subject = subject ).

    ELSE.

      TRY.
          CALL METHOD cl_document_bcs=>create_document
            EXPORTING
              i_type    = att_type
              i_subject = subject
              i_text    = it_text
            RECEIVING
              result    = document.
        CATCH cx_document_bcs INTO cx_doc_bcs.
          lv_text = cx_doc_bcs->get_text( ).
          s_return-message = lv_text.
          APPEND s_return TO t_return. CLEAR s_return.
      ENDTRY.

    ENDIF.

    LOOP AT it_attachments INTO ls_attachments.
      IF ls_attachments-soli[] IS NOT INITIAL.
        TRY.
            CALL METHOD document->add_attachment
              EXPORTING
                i_attachment_type    = ls_attachments-ext
                i_attachment_subject = ls_attachments-ftext
                i_att_content_hex    = ls_attachments-soli.
          CATCH cx_document_bcs INTO cx_doc_bcs.
            lv_text = cx_doc_bcs->get_text( ).
            s_return-message = lv_text.
*            s_Return-type    = 'E'.
            APPEND s_return TO t_return. CLEAR s_return.
        ENDTRY.
      ELSE.
        TRY.
            CALL METHOD document->add_attachment
              EXPORTING
                i_attachment_type    = ls_attachments-ext
                i_attachment_subject = ls_attachments-ftext
                i_att_content_text   = ls_attachments-solit.
          CATCH cx_document_bcs INTO cx_doc_bcs.
            lv_text = cx_doc_bcs->get_text( ).
            s_return-message = lv_text.
            APPEND s_return TO t_return. CLEAR s_return.
        ENDTRY.
      ENDIF.
    ENDLOOP.

    TRY.
        CALL METHOD send_request->set_document
          EXPORTING
            i_document = document.
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-message = lv_text.
*        s_Return-type    = 'E'.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.

    TRY.
        CALL METHOD cl_cam_address_bcs=>create_internet_address
          EXPORTING
            i_address_string = i_sender
          RECEIVING
            result           = sender.
      CATCH cx_address_bcs INTO cx_add_bcs.
        lv_text = cx_add_bcs->get_text( ).
        s_return-message = lv_text.
        s_return-type    = 'E'.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.

    TRY.
        CALL METHOD send_request->set_sender
          EXPORTING
            i_sender = sender.
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-message = lv_text.
        s_return-type    = 'E'.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.

    DATA : lv_tname(6).
    LOOP AT it_receiver INTO ls_receiver.
      IF ls_receiver-tclas EQ 'B'.
        lv_tname = 'PB0105'.
      ELSE.
        lv_tname = 'PA0105'.
      ENDIF.
      IF ls_receiver-mtext IS NOT INITIAL.
        l_receiver = ls_receiver-mtext.
      ELSE.
        SELECT SINGLE usrid_long FROM (lv_tname) INTO l_receiver
            WHERE pernr = ls_receiver-pernr
              AND subty EQ lv_usrty
              AND begda LE sy-datum
              AND endda GE sy-datum.
        IF sy-subrc NE 0.
*          CONCATENATE ls_receiver-pernr '- Mail adresi bulunamadı'
*                      INTO s_return-message
*                      SEPARATED BY space.
*          APPEND s_return TO t_return. CLEAR s_return.
          CHECK 1 = 2.
        ENDIF.
      ENDIF.

      IF  l_receiver IS INITIAL.
        s_return-message = 'Gönderilecek Mail Adresi Bulunamadı !'.
        s_return-type    = 'E'.
        APPEND s_return TO t_return. CLEAR s_return.
        RETURN.
      ENDIF.

      TRY.
          CALL METHOD cl_cam_address_bcs=>create_internet_address
            EXPORTING
              i_address_string = l_receiver
            RECEIVING
              result           = recipient.
        CATCH cx_address_bcs INTO cx_add_bcs.
          lv_text = cx_add_bcs->get_text( ).
          s_return-message = lv_text.
          s_return-type    = 'E'.
          APPEND s_return TO t_return. CLEAR s_return.
      ENDTRY.
      l_cc = l_bcc = ''.
      IF     ls_receiver-type EQ 'C'.
        l_cc  = 'X'.
      ELSEIF ls_receiver-type EQ 'B'.
        l_bcc = 'X'.
      ENDIF.


      TRY.
          CALL METHOD send_request->add_recipient
            EXPORTING
              i_recipient  = recipient
*             i_express    = 'X'
              i_copy       = l_cc
              i_blind_copy = l_bcc.
*              i_no_forward = 'X'.
        CATCH cx_send_req_bcs INTO cx_req_bcs.
          lv_text = cx_req_bcs->get_text( ).
          s_return-message = lv_text.
          s_return-type    = 'E'.
          APPEND s_return TO t_return. CLEAR s_return.
      ENDTRY.
    ENDLOOP.

    IF NOT i_groupmail IS INITIAL.
      recipient = cl_distributionlist_bcs=>getu_persistent(
               i_dliname = i_groupmail
               i_private = space ).

      TRY.
          CALL METHOD send_request->add_recipient
            EXPORTING
              i_recipient = recipient
              i_express   = 'X'.
        CATCH cx_send_req_bcs INTO cx_req_bcs.
          lv_text = cx_req_bcs->get_text( ).
          s_return-message = lv_text.
          s_return-type    = 'E'.
          APPEND s_return TO t_return. CLEAR s_return.
      ENDTRY.
    ENDIF.

    TRY.
        CALL METHOD send_request->set_send_immediately
          EXPORTING
            i_send_immediately = 'X'.
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-message = lv_text.
        s_return-type    = 'E'.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.

    TRY.
        CALL METHOD send_request->set_status_attributes
          EXPORTING
            i_requested_status = 'N'.
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-message = lv_text.
*        s_Return-type    = 'E'.
        APPEND s_return TO t_return. CLEAR s_return..
    ENDTRY.

    TRY.
        sent_to_all = send_request->send( i_with_error_screen = 'X' ).
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-type    = 'E'.
        s_return-message = lv_text.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.

    IF commit = 'X'.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.

ENDMETHOD.


  METHOD send_mail_basic.

    CLASS : cl_cam_address_bcs     DEFINITION LOAD          ,
        cl_abap_char_utilities DEFINITION LOAD          .

    DATA : lc_send_request  TYPE REF TO cl_bcs,
           lc_document      TYPE REF TO cl_document_bcs,
           lc_recipient     TYPE REF TO if_recipient_bcs,
           lc_bcs_exception TYPE REF TO cx_bcs,
           lc_sender        TYPE REF TO cl_cam_address_bcs.

    DATA : lv_sender_address TYPE adr6-smtp_addr,
           lv_sizee          TYPE sood-objlen,
           ls_text           TYPE soli,
           lt_text           TYPE soli_tab,
           lv_length         TYPE so_obj_len,
           it_rec            TYPE bcsy_smtpa,
           it_rec_cc         TYPE bcsy_smtpa,
           lv_status_mail    TYPE bcs_stml,
           ls_intadd         TYPE ad_smtpadr,
           lv_len            TYPE so_obj_len,
           lv_isim           TYPE so_obj_des,
           ls_body           TYPE solisti1,
           lv_header         TYPE so_obj_des,
           lv_sender         TYPE so_rec_ext.


    " To - Mail gidecek kişiler !
    LOOP AT ip_rec INTO  ls_intadd.
      APPEND ls_intadd TO it_rec.
      CLEAR ls_intadd.
    ENDLOOP.

    " CC - Mail gidecek kişiler !
    LOOP AT ip_rec_cc INTO  ls_intadd.
      APPEND ls_intadd TO it_rec_cc.
      CLEAR ls_intadd.
    ENDLOOP.

    " Mail İçeriği
    LOOP AT  ip_body INTO ls_body.
      CLEAR ls_text.
      ls_text-line = ls_body-line.
      APPEND ls_text TO lt_text.
    ENDLOOP.

    DESCRIBE TABLE lt_text LINES lv_length.
    lv_length = lv_length  * 255 .

    " Mail ekindeki excelin ismi
    lv_isim = 'Talep Raporu'.

    " Mail Başlık
    lv_header = 'Talep Raporu Bilgilendirme Maili'.
    lv_sender = ip_sender          .
    lv_sender_address = ip_sender  .

    TRY.
        lc_send_request = cl_bcs=>create_persistent( ).
        lc_sender = cl_cam_address_bcs=>create_internet_address( i_address_string = lv_sender_address ).
        CALL METHOD lc_send_request->set_sender
          EXPORTING
            i_sender = lc_sender.

        LOOP AT it_rec INTO ls_intadd.
          lc_recipient = cl_cam_address_bcs=>create_internet_address( ls_intadd ).
          CALL METHOD lc_send_request->add_recipient
            EXPORTING
              i_recipient  = lc_recipient
              i_express    = ''
              i_copy       = ''
              i_blind_copy = ''
              i_no_forward = ''.
        ENDLOOP.

* Add recipient with its respective attributes to send request
        LOOP AT it_rec_cc INTO ls_intadd.
          lc_recipient = cl_cam_address_bcs=>create_internet_address( ls_intadd ).
          CALL METHOD lc_send_request->add_recipient
            EXPORTING
              i_recipient  = lc_recipient
              i_express    = ''
              i_copy       = abap_true
              i_blind_copy = ''
              i_no_forward = ''.

        ENDLOOP.

* Build the Main Document
        lc_document = cl_document_bcs=>create_document(
            i_type        = 'HTM'
            i_subject     = lv_header
            i_length      = lv_length
            i_sensitivity = 'F'
            i_text        = lt_text
            i_sender      = lc_sender ) .

        lv_sizee = ip_size.

        IF NOT ip_content_hex IS INITIAL.

          lc_document->add_attachment(
            i_attachment_type      =  'xls'
            i_attachment_subject   =  lv_isim
            i_attachment_size      =  lv_sizee
            i_att_content_hex      =  ip_content_hex ).
          CLEAR lv_isim.

        ENDIF.


        IF NOT ip_content_hex2 IS INITIAL.
          CLEAR :lv_sizee,lv_isim.
          lv_sizee = ip_size2.
          lv_isim  = 'Erp İş Emri Raporu' .
          lc_document->add_attachment(
            i_attachment_type      =  'xls'
            i_attachment_subject   =  lv_isim
            i_attachment_size      =  lv_sizee
            i_att_content_hex      =  ip_content_hex2 ).
          CLEAR lv_isim.

        ENDIF.

        CALL METHOD lc_send_request->set_document( lc_document ).
        lv_status_mail = 'E'.

        CALL METHOD lc_send_request->set_status_attributes
          EXPORTING
            i_requested_status = 'E'
            i_status_mail      = lv_status_mail.
        lc_send_request->set_send_immediately( 'X' ).
        CALL METHOD lc_send_request->send( ).
        COMMIT WORK.

      CATCH cx_bcs INTO lc_bcs_exception.

    ENDTRY .

  ENDMETHOD.


METHOD send_mail_with_image.
  DATA : lt_lines TYPE tlinetab,
         ls_line  TYPE tline.
  DATA : w_p     TYPE zncprh_s007,
         l_dg(5)                 ,
         l_tabix LIKE sy-tabix,
         l_ds(5)                 ,
         tdline  TYPE tdline,
         l_x(2)                  .
  DATA lv_sendername  TYPE ad_smtpadr.
  DATA : document     TYPE REF TO cl_document_bcs,
         sent_to_all  TYPE os_boolean,
         send_request TYPE REF TO cl_bcs,
         sender       TYPE REF TO if_sender_bcs,
         recipient    TYPE REF TO if_recipient_bcs,
         sender_rec   TYPE REF TO if_recipient_bcs,
         subject      TYPE so_obj_des,
         att_type     TYPE soodk-objtp VALUE 'HTM',
         it_text      TYPE bcsy_text,
         wa_text      TYPE soli.

  DEFINE ap.
    APPEND wa_text TO it_text.
  END-OF-DEFINITION.

  DATA : BEGIN OF gs_data,
           solix  TYPE solix_tab,
           ext(3)               ,
           ftext  TYPE so_obj_des,
         END OF gs_data         .
  DATA : gt_data LIKE TABLE OF gs_data.

  DATA : ls_receiver TYPE zncprh_s006,
         l_receiver  TYPE comm_id_long.
  DATA : l_cc      TYPE os_boolean,
         l_bcc     TYPE os_boolean,
         l_xstring TYPE xstring.

  DATA : s_return TYPE bapireturn.

  DATA : lv_langu TYPE spras.
  DATA ls_02 TYPE pa0002.

  lv_langu = i_langu.

* i_langu boş değilse onu al
* i_langu boş ise, alıcı aday ise CV dilini al, alıcı personel ise
* 2 bilgi tipindeki dili al, oda yoksa TR yap
  IF i_langu IS INITIAL.
    lv_langu = sy-langu.
  ELSE.
    lv_langu = i_langu.
  ENDIF.

  "Dil TR değilse EN'yi al, local dili de aynı mailin altına ekle
*  IF lv_langu NE 'T'.
*    IF lv_langu NE 'E'.
  DATA(lv_langu2) = lv_langu. CLEAR lv_langu2.
*      lv_langu = 'E'.
*    ELSE.
*    ENDIF.
*  ENDIF.

  IF ip_content IS NOT INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = ip_content_tdid
        language                = lv_langu
        name                    = ip_content
        object                  = 'TEXT'
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      s_return-type = 'W'.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO s_return-message.
      APPEND s_return TO t_return.
      EXIT.
    ENDIF.
  ENDIF.

  DATA : s005      TYPE zncprh_s009,
         s004      TYPE zncprh_s010,
         fname(20),
         lv_str    TYPE i,
         l_id(2),
         flag.

  FIELD-SYMBOLS <f> TYPE any.

  LOOP AT lt_lines INTO ls_line.
    MOVE sy-tabix TO l_tabix.
    CLEAR flag.
    LOOP AT ptab INTO s005.
      CLEAR : l_dg , l_x.
      MOVE sy-tabix TO l_x.
      CONCATENATE '&t' l_x '&' INTO l_ds.
      FIND l_ds IN ls_line-tdline.
      IF sy-subrc EQ 0.
        flag = 'X'.
        tdline = ls_line-tdline.
        LOOP AT s005-data INTO s004.
          l_id = '1'.
          DO s005-count TIMES.
            CONCATENATE 'S004-VAL' l_id INTO fname.
            ASSIGN (fname) TO <f>.
            CHECK <f> IS ASSIGNED .
            ls_line-tdline = tdline.
            lv_str = strlen( <f> ) .
            IF lv_str GT 132 .
              ls_line-tdline = ''.
              wa_text = <f>(132). ap.
              lv_str = lv_str - 132 .
              wa_text = <f>+132(lv_str) . ap.
            ELSE.
              REPLACE ALL OCCURRENCES OF l_ds IN ls_line-tdline WITH <f>.
              wa_text = ls_line-tdline. ap.
            ENDIF.

            ADD 1 TO l_id. CONDENSE l_id.
          ENDDO.
          wa_text = s004-finish_line. ap.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
    CHECK flag NE 'X'.
    LOOP AT t_p INTO w_p.
      CLEAR : l_dg , l_x.
      MOVE sy-tabix TO l_x.
      CONCATENATE '&'  l_x '&' INTO l_dg.

      REPLACE ALL OCCURRENCES OF l_dg IN
      ls_line-tdline WITH w_p-p.
    ENDLOOP.
    IF l_tabix = 1.
      IF i_subject IS INITIAL.
        CONDENSE ls_line-tdline.
        subject = ls_line-tdline.
      ELSE.
        subject = i_subject.
        wa_text = ls_line-tdline. ap.
      ENDIF.
    ELSE.
*{Osahin 27.02.2021
*      IF ls_line-tdformat IS NOT INITIAL.
*        wa_text = ls_line-tdline. ap.
*      ELSE.
*        wa_text-line = wa_text-line &&  ls_line-tdline .
*      ENDIF .
      IF ls_line-tdformat IS NOT INITIAL.
        wa_text = ls_line-tdline. ap.
      ELSE.
        wa_text = it_text[ lines( it_text ) ].
        it_text[ lines( it_text ) ] = wa_text-line && ls_line-tdline.
      ENDIF.
*}Osahin 27.02.2021
    ENDIF.
  ENDLOOP.

  IF lv_langu2 IS NOT INITIAL AND ip_content IS NOT INITIAL.
    wa_text = '<br><br><br>'. ap.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = ip_content_tdid
        language                = lv_langu2
        name                    = ip_content
        object                  = 'TEXT'
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      s_return-type = 'W'.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO s_return-message.
      APPEND s_return TO t_return.
      EXIT.
    ENDIF.

    CLEAR : s005, s004, fname, l_id, flag.
    LOOP AT lt_lines INTO ls_line.
      MOVE sy-tabix TO l_tabix.
      CLEAR flag.
      LOOP AT ptab INTO s005.
        CLEAR : l_dg , l_x.
        MOVE sy-tabix TO l_x.
        CONCATENATE '&t' l_x '&' INTO l_ds.
        FIND l_ds IN ls_line-tdline.
        IF sy-subrc EQ 0.
          flag = 'X'.
          tdline = ls_line-tdline.
          LOOP AT s005-data INTO s004.
            l_id = '1'.
            DO s005-count TIMES.
              CONCATENATE 'S004-VAL' l_id INTO fname.
              ASSIGN (fname) TO <f>.
              REPLACE ALL OCCURRENCES OF l_ds IN
              ls_line-tdline WITH <f>.
              wa_text = ls_line-tdline. ap.
              ls_line-tdline = tdline.
              ADD 1 TO l_id. CONDENSE l_id.
            ENDDO.
            wa_text = s004-finish_line. ap.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
      CHECK flag NE 'X'.
      LOOP AT t_p INTO w_p.
        CLEAR : l_dg , l_x.
        MOVE sy-tabix TO l_x.
        CONCATENATE '&'  l_x '&' INTO l_dg.

        REPLACE ALL OCCURRENCES OF l_dg IN
        ls_line-tdline WITH w_p-p.
      ENDLOOP.
      IF l_tabix = 1.
        IF i_subject IS INITIAL.
          CONDENSE ls_line-tdline.
          subject = ls_line-tdline.
        ELSE.
          subject = i_subject.
          wa_text = ls_line-tdline. ap.
        ENDIF.
      ELSE.
        wa_text = ls_line-tdline. ap.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF it_body_text IS NOT INITIAL.
    it_text = it_body_text.
  ENDIF.

  IF subject IS INITIAL AND i_subject IS NOT INITIAL.
    subject = i_subject.
  ENDIF.

  DATA : cx_req_bcs TYPE REF TO cx_send_req_bcs,
         cx_add_bcs TYPE REF TO cx_address_bcs,
         cx_doc_bcs TYPE REF TO cx_document_bcs,
         lv_text    TYPE string.
  DATA : ls_attachments TYPE zncprh_s008.
**==========================================================
*      mail içerik top ve bottom kısmına resim ekleme
**==========================================================
*SO10 işlem kodunda aşağıdaki tag'ların eklenmeiş olması lazım
*<img alt="[image]" src="cid:image001.jpg"/>
*      içerikler...
*<img alt="[image]" src="cid:image002.jpg"/>
*==========================================================
  DATA : lo_mime_helper TYPE REF TO cl_gbt_multirelated_service .

  get_mail_mime_image(
    CHANGING
      ch_co_helper = lo_mime_helper
  ).

  CALL METHOD lo_mime_helper->set_main_html
    EXPORTING
      content  = it_text
      filename = 'sise.htm'.

  document =
  cl_document_bcs=>create_from_multirelated(
                 i_subject = subject
                 i_multirel_service = lo_mime_helper  ).

**==========================================================
  TRY.
      CALL METHOD cl_bcs=>create_persistent
        RECEIVING
          result = send_request.
    CATCH cx_send_req_bcs INTO cx_req_bcs.
      lv_text = cx_req_bcs->get_text( ).
      s_return-message = lv_text.
      APPEND s_return TO t_return. CLEAR s_return.
  ENDTRY.

*  TRY.
*      CALL METHOD cl_document_bcs=>create_document
*        EXPORTING
*          i_type    = att_type
*          i_subject = subject
*          i_text    = it_text
*        RECEIVING
*          result    = document.
*    CATCH cx_document_bcs INTO cx_doc_bcs.
*      lv_text = cx_doc_bcs->get_text( ).
*      s_return-message = lv_text.
*      APPEND s_return TO t_return. CLEAR s_return.
*  ENDTRY.

  LOOP AT it_attachments INTO ls_attachments.
    IF ls_attachments-soli[] IS NOT INITIAL.
      TRY.
          CALL METHOD document->add_attachment
            EXPORTING
              i_attachment_type    = ls_attachments-ext
              i_attachment_subject = ls_attachments-ftext
              i_att_content_hex    = ls_attachments-soli.
        CATCH cx_document_bcs INTO cx_doc_bcs.
          lv_text = cx_doc_bcs->get_text( ).
          s_return-message = lv_text.
          APPEND s_return TO t_return. CLEAR s_return.
      ENDTRY.
    ELSE.
      TRY.
          CALL METHOD document->add_attachment
            EXPORTING
              i_attachment_type    = ls_attachments-ext
              i_attachment_subject = ls_attachments-ftext
              i_att_content_text   = ls_attachments-solit.
        CATCH cx_document_bcs INTO cx_doc_bcs.
          lv_text = cx_doc_bcs->get_text( ).
          s_return-message = lv_text.
          APPEND s_return TO t_return. CLEAR s_return.
      ENDTRY.
    ENDIF.
  ENDLOOP.

  TRY.
      CALL METHOD send_request->set_document
        EXPORTING
          i_document = document.
    CATCH cx_send_req_bcs INTO cx_req_bcs.
      lv_text = cx_req_bcs->get_text( ).
      s_return-message = lv_text.
      APPEND s_return TO t_return. CLEAR s_return.
  ENDTRY.


*  IF i_sender EQ 'hrone-noreply@sisecam.com'.
*    lv_sendername = 'Şişecam HROne'.
*  ENDIF.

  TRY.
      CALL METHOD cl_cam_address_bcs=>create_internet_address
        EXPORTING
          i_address_string = i_sender
          i_address_name   = lv_sendername
        RECEIVING
          result           = sender.
    CATCH cx_address_bcs INTO cx_add_bcs.
      lv_text = cx_add_bcs->get_text( ).
      s_return-message = lv_text.
      APPEND s_return TO t_return. CLEAR s_return.
  ENDTRY.

  TRY.
      CALL METHOD send_request->set_sender
        EXPORTING
          i_sender = sender.
    CATCH cx_send_req_bcs INTO cx_req_bcs.
      lv_text = cx_req_bcs->get_text( ).
      s_return-message = lv_text.
      APPEND s_return TO t_return. CLEAR s_return.
  ENDTRY.

  DATA : lv_tname(6).
  LOOP AT it_receiver INTO ls_receiver.
    IF ls_receiver-dliname IS INITIAL.
      IF ls_receiver-tclas EQ 'B'.
        lv_tname = 'PB0105'.
      ELSE.
        lv_tname = 'PA0105'.
      ENDIF.
      IF ls_receiver-mtext IS NOT INITIAL.
        l_receiver = ls_receiver-mtext.
      ELSE.
        SELECT SINGLE usrid_long FROM (lv_tname) INTO l_receiver
        WHERE pernr = ls_receiver-pernr
        AND subty = '0010'
        AND begda LE sy-datum
        AND endda GE sy-datum.
        IF sy-subrc NE 0.
          CONCATENATE ls_receiver-pernr '- Mail adresi bulunamadı'
          INTO s_return-message
          SEPARATED BY space.
          APPEND s_return TO t_return. CLEAR s_return.
          CHECK 1 = 2.
        ENDIF.
      ENDIF.
      CHECK l_receiver IS NOT INITIAL.
      TRY.
          CALL METHOD cl_cam_address_bcs=>create_internet_address
            EXPORTING
              i_address_string = l_receiver
            RECEIVING
              result           = recipient.
        CATCH cx_address_bcs INTO cx_add_bcs.
          lv_text = cx_add_bcs->get_text( ).
          s_return-message = lv_text.
          APPEND s_return TO t_return. CLEAR s_return.
      ENDTRY.
      l_cc = l_bcc = ''.
      IF     ls_receiver-type EQ 'C'.
        l_cc  = 'X'.
      ELSEIF ls_receiver-type EQ 'B'.
        l_bcc = 'X'.
      ENDIF.

    ELSE.

      DATA : cx_address_bcs TYPE REF TO cx_address_bcs.
      TRY.
          recipient = cl_distributionlist_bcs=>getu_persistent(
                          i_dliname = ls_receiver-dliname
                          i_private = space ).
        CATCH cx_address_bcs INTO cx_address_bcs.
          lv_text = cx_address_bcs->if_message~get_text( ).
          s_return-message = lv_text.
          APPEND s_return TO t_return. CLEAR s_return.
      ENDTRY.
    ENDIF.

    TRY.
        CALL METHOD send_request->add_recipient
          EXPORTING
            i_recipient  = recipient
            i_express    = 'X'
            i_copy       = l_cc
            i_blind_copy = l_bcc
            i_no_forward = 'X'.
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-message = lv_text.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.
  ENDLOOP.

  IF add_sender_to_bcc EQ 'X'.
    TRY.
        CALL METHOD cl_cam_address_bcs=>create_internet_address
          EXPORTING
            i_address_string = i_sender
            i_address_name   = lv_sendername
          RECEIVING
            result           = sender_rec.
      CATCH cx_address_bcs INTO cx_add_bcs.
        lv_text = cx_add_bcs->get_text( ).
        s_return-message = lv_text.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.
    TRY.
        CALL METHOD send_request->add_recipient
          EXPORTING
            i_recipient  = sender_rec
            i_express    = 'X'
*           i_copy       = l_cc
            i_blind_copy = 'X'
            i_no_forward = 'X'.
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-message = lv_text.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.

  ENDIF.

  DATA: lv_timestamp  TYPE timestamp,
        lvs_timestamp TYPE timestamp,
        lv_mess(100).

  IF iv_next_day IS NOT INITIAL AND iv_next_tim IS NOT INITIAL.
*GET TIME STAMP FIELD lv_timestamp.
*lv_timestamp = CL_ABAP_TSTMP=>ADD( tstmp = lv_timestamp  secs = 360 ).
    CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
      EXPORTING
        i_datlo     = iv_next_day
        i_timlo     = iv_next_tim
        i_tzone     = sy-zonlo
      IMPORTING
        e_timestamp = lv_timestamp.
    IF sy-subrc EQ 0.
      "tarih ve saat günün trh ve satinden küçük olunca subrc o değil aslında
      CALL FUNCTION 'IB_CONVERT_INTO_TIMESTAMP'
        EXPORTING
          i_datlo     = sy-datum
          i_timlo     = sy-uzeit
          i_tzone     = sy-zonlo
        IMPORTING
          e_timestamp = lvs_timestamp.

      IF lv_timestamp GE lvs_timestamp .
        send_request->send_request->set_send_at( lv_timestamp ).
        CONCATENATE 'Mail Gönderme İşlem zamanı-> '
                     iv_next_day+6(2) '.' iv_next_day+4(2) '.' iv_next_day(4) '_'
                iv_next_tim(2) ':' iv_next_tim+2(2) ':' iv_next_tim+4(2) ' olarak ayarlandı'
               INTO lv_mess.
*        CLEAR s_return.
*        s_return-type    = 'S'.
*        s_return-message = lv_mess.
*        APPEND s_return TO t_return. CLEAR s_return.
      ENDIF.
    ENDIF.

  ELSE.
    TRY.
        CALL METHOD send_request->set_send_immediately
          EXPORTING
            i_send_immediately = 'X'.
      CATCH cx_send_req_bcs INTO cx_req_bcs.
        lv_text = cx_req_bcs->get_text( ).
        s_return-message = lv_text.
        APPEND s_return TO t_return. CLEAR s_return.
    ENDTRY.
  ENDIF.

  TRY.
      CALL METHOD send_request->set_status_attributes
        EXPORTING
          i_requested_status = 'N'.
    CATCH cx_send_req_bcs INTO cx_req_bcs.
      lv_text = cx_req_bcs->get_text( ).
      s_return-message = lv_text.
      APPEND s_return TO t_return. CLEAR s_return..
  ENDTRY.


  TRY.
      CALL METHOD send_request->send
        EXPORTING
          i_with_error_screen = 'X'
        RECEIVING
          result              = sent_to_all.
    CATCH cx_send_req_bcs INTO cx_req_bcs.
      lv_text = cx_req_bcs->get_text( ).
      s_return-message = lv_text.
      APPEND s_return TO t_return. CLEAR s_return.
  ENDTRY.

  COMMIT WORK AND WAIT.
ENDMETHOD.
ENDCLASS.
