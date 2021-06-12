FUNCTION ZNCPRH_FG003_002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(SUBJECT) TYPE  STRING
*"     REFERENCE(MESSAGE) TYPE  STRING OPTIONAL
*"     REFERENCE(MAILBODY) TYPE  BCSY_TEXT OPTIONAL
*"     REFERENCE(ATTACHMENTS) TYPE  RMPS_T_POST_CONTENT OPTIONAL
*"     REFERENCE(RECIPIENTS) TYPE  ZNCPRH_TT024
*"     REFERENCE(SENDER_UNAME) TYPE  UNAME OPTIONAL
*"     REFERENCE(SENDER_EMAIL) TYPE  AD_SMTPADR OPTIONAL
*"     REFERENCE(SENDER_VISNAME) TYPE  AD_SMTPADR OPTIONAL
*"     REFERENCE(SEND_IMMEDIATELY) TYPE  CHECKBOX OPTIONAL
*"     REFERENCE(MAIL_TYPE) TYPE  SO_OBJ_TP DEFAULT 'RAW'
*"     REFERENCE(COMMIT_WORK) TYPE  CHECKBOX DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------


  DATA: send_request       TYPE REF TO cl_bcs,
        text               TYPE bcsy_text,
        binary_content     TYPE solix_tab,
        bcs_exception      TYPE REF TO cx_bcs,
        document           TYPE REF TO cl_document_bcs,
        i_sender           TYPE REF TO cl_sapuser_bcs,
        lr_sender          TYPE REF TO cl_cam_address_bcs,
        recipient          TYPE REF TO if_recipient_bcs,
        sent_to_all        TYPE os_boolean.

  CONSTANTS:
        on  TYPE checkbox VALUE 'X',
        off TYPE checkbox VALUE ' '.

  IF message IS INITIAL AND mailbody[] IS INITIAL.
    return-type = 'E'.
    return-message = 'No MESSAGE or MAILBODY'.
    RAISE no_body.
  ENDIF.

  TRY.

************************************************************************
* DOCUMENT
************************************************************************

*     -------- create and set document with attachment ---------------
*     create document from internal table with text

*  Move the Subject from string to BCS subject type
      DATA: l_subject  TYPE so_obj_des.
      DATA: l_mailtext TYPE soli_tab.

      l_subject = subject.
      REFRESH l_mailtext.

* Move the message from string to internal table
      IF mailbody[] IS INITIAL.
        CALL FUNCTION 'SCMS_STRING_TO_FTEXT'
          EXPORTING
            text      = message
          TABLES
            ftext_tab = l_mailtext.
      ELSE.
        l_mailtext[] = mailbody[].
      ENDIF.



* Create the Document
      document = cl_document_bcs=>create_document(
      i_type = mail_type
      i_text = l_mailtext
      i_subject = l_subject ).


*Add attachments
      DATA: l_att TYPE rmps_post_content,
            i_attach TYPE solix_tab,
            l_attname TYPE sood-objdes,
            l_attext TYPE soodk-objtp,
            l_lines TYPE i,
            l_file TYPE string,
            wa_attach TYPE solix,         " Attachment
            l_size TYPE sood-objlen.      " Size of Attachmen

      LOOP AT attachments INTO l_att.

        IF l_att-filename IS NOT INITIAL.
          REFRESH i_attach.
          OPEN DATASET l_att-filename IN BINARY MODE FOR INPUT.
          DO.
            READ DATASET l_att-filename INTO wa_attach.
            APPEND wa_attach TO i_attach.
            IF sy-subrc NE 0.
              EXIT.
            ENDIF.
          ENDDO.
          CLOSE DATASET l_att-filename.


          CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
            EXPORTING
              full_name     = l_att-filename
            IMPORTING
              stripped_name = l_file
            EXCEPTIONS
              x_error       = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
          ENDIF.

          SPLIT l_file AT '.' INTO l_attname l_attext.

          DESCRIBE TABLE i_attach LINES l_lines.
          l_size = l_lines * 255.
* Adding Attachment - file
          CALL METHOD document->add_attachment
            EXPORTING
              i_attachment_type    = l_attext
              i_attachment_size    = l_size
              i_attachment_subject = l_attname
              i_att_content_hex    = i_attach[].

        ELSEIF l_att-binary IS INITIAL.
          MOVE l_att-subject TO l_attname.
          DESCRIBE TABLE l_att-cont_text LINES l_lines.
          l_size = l_lines * 255.
* Adding Attachment - text
          CALL METHOD document->add_attachment
            EXPORTING
              i_attachment_type    = l_att-doc_type
              i_attachment_size    = l_size
              i_attachment_subject = l_attname
              i_att_content_text   = l_att-cont_text[].

        ELSE.
          MOVE l_att-subject TO l_attname.
          MOVE l_att-docsize TO l_size.
*          DESCRIBE TABLE l_att-cont_hex LINES l_lines.
*          l_size = l_lines * 255.
* Adding Attachment - binary
          CALL METHOD document->add_attachment
            EXPORTING
              i_attachment_type    = l_att-doc_type
              i_attachment_size    = l_size
              i_attachment_subject = l_attname
              i_att_content_hex    = l_att-cont_hex[].

        ENDIF.
      ENDLOOP.

************************************************************************
* SEND REQUEST
************************************************************************
*     -------- create persistent send request ------------------------
      send_request = cl_bcs=>create_persistent( ).

      IF sender_uname IS NOT INITIAL.
*- sender = utente SAP diverso
        i_sender = cl_sapuser_bcs=>create( sender_uname ).
        CALL METHOD send_request->set_sender
          EXPORTING
            i_sender = i_sender.

      ELSEIF sender_email IS NOT INITIAL.
        IF sender_visname IS INITIAL.
*- sender = indirizzo email senza nome da visualizzare
**          CALL METHOD cl_cam_address_bcs=>create_internet_address
**            EXPORTING
**              i_address_string = sender_email
***              i_address_name   = w_visname
***           i_incl_sapuser   =
**            RECEIVING
**              result           = lr_sender.
          lr_sender = cl_cam_address_bcs=>create_internet_address(
                                          i_address_string = sender_email ).
        ELSE.
*- sender = indirizzo email con nome da visualizzare
**          CALL METHOD cl_cam_address_bcs=>create_internet_address    " Ho il nome da visualizzare
**          EXPORTING
**            i_address_string = sender_email
**            i_address_name   = sender_visname
***           i_incl_sapuser   =
**          RECEIVING
**            result           = lr_sender.
          lr_sender = cl_cam_address_bcs=>create_internet_address(
                                          i_address_string = sender_email
                                          i_address_name   = sender_visname ).
        ENDIF.

        CALL METHOD send_request->set_sender
          EXPORTING
            i_sender = lr_sender.

**      ELSE.
*** sender = utente locale
**        i_sender = cl_sapuser_bcs=>create( sy-uname ).
**        CALL METHOD send_request->set_sender
**          EXPORTING
**            i_sender = i_sender.
      ENDIF.

* Set Recipient Object
      DATA: l_recipient TYPE ZNCPRH_S024.

      LOOP AT recipients INTO l_recipient.
        IF l_recipient-uname IS NOT INITIAL.
          recipient = cl_sapuser_bcs=>create( l_recipient-uname ).
        ELSEIF l_recipient-email IS NOT INITIAL.
          recipient = cl_cam_address_bcs=>create_internet_address( l_recipient-email ).
        ENDIF.

* Add recipient with its respective attributes to send request
        CALL METHOD send_request->add_recipient
          EXPORTING
            i_recipient = recipient
            i_express   = l_recipient-high_priority
            i_copy      = l_recipient-carbon_copy.

      ENDLOOP.



* Add document to send request
      CALL METHOD send_request->set_document( document ).

* Set that you don't need a Return Status E-mail
      CALL METHOD send_request->set_status_attributes
        EXPORTING
          i_requested_status = 'E'
          i_status_mail      = 'E'.

      IF send_immediately IS NOT INITIAL.
* set send immediately flag
        send_request->set_send_immediately( 'X' ).
      ENDIF.

* Send document
      CALL METHOD send_request->send(
             EXPORTING
          i_with_error_screen = 'X'
         RECEIVING
          result              = sent_to_all ).
      IF sent_to_all = 'X'.
        return-type = 'S'.
        return-message = 'Message sent.'.
      ENDIF.

* set commit work
      IF commit_work = on.
        COMMIT WORK.
      ENDIF.

* -----------------------------------------------------------
* *                     exception handling
* -----------------------------------------------------------
    CATCH cx_bcs INTO bcs_exception.
      DATA: l_message TYPE string.
      l_message = bcs_exception->get_text( ).
      return-type = 'E'.
      return-message = l_message.
      RAISE bcs_error.
  ENDTRY.


ENDFUNCTION.
