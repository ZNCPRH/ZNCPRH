*&---------------------------------------------------------------------*
*& Report ZNCPRH_P049
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZNCPRH_P049.

*Declaring CL_BCS

DATA:  lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
CLASS cl_bcs DEFINITION LOAD.
lo_send_request = cl_bcs=>create_persistent( ).

* Message body and subject
DATA: lo_document TYPE REF TO cl_document_bcs VALUE IS INITIAL. "document object
DATA : i_text TYPE bcsy_text. "Table for body
DATA : w_text LIKE LINE OF i_text. "work area for message body
*Set body
w_text-line = 'This is the first tutorial of sending email using SAP ABAP programming by SAPNuts.com'.
APPEND w_text TO i_text.
CLEAR w_text.
w_text-line = 'SAPTutorial Website'.
APPEND w_text TO i_text.
CLEAR w_text.
*Create Email document
lo_document = cl_document_bcs=>create_document( "create document
i_type = 'TXT' "Type of document HTM, TXT etc
i_text =  i_text "email body internal table
i_subject = 'baslik' ). "email subject here p_sub input parameter

* Pass the document to send request
lo_send_request->set_document( lo_document ).


DATA : it_mara TYPE TABLE OF mara, "internal table for MARA
       wa_mara TYPE mara. "work area for MARA
**Get data from MARA
SELECT * FROM mara INTO TABLE it_mara UP TO 50 ROWS.

DATA : lv_string      TYPE string, "declare string
       lv_data_string TYPE string. "declare string
LOOP           AT it_mara INTO wa_mara.
  CONCATENATE wa_mara-matnr wa_mara-mtart wa_mara-meins wa_mara-mbrsh wa_mara-matkl INTO lv_string SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
  CONCATENATE lv_data_string lv_string INTO lv_data_string SEPARATED BY cl_abap_char_utilities=>newline.
  CLEAR: wa_mara, lv_string.
ENDLOOP.

DATA lv_xstring TYPE xstring .
**Convert string to xstring
CALL FUNCTION 'HR_KR_STRING_TO_XSTRING'
  EXPORTING
*   codepage_to      = '8300'
    unicode_string   = lv_data_string
*   OUT_LEN          =
  IMPORTING
    xstring_stream   = lv_xstring
  EXCEPTIONS
    invalid_codepage = 1
    invalid_string   = 2
    OTHERS           = 3.
IF sy-subrc <> 0.
  IF sy-subrc = 1 .

  ELSEIF sy-subrc = 2 .
    WRITE:/ 'invalid string ' .
  ENDIF.
ENDIF.

DATA: l_zipper TYPE REF TO cl_abap_zip. " Zip class declerration
DATA : l_data TYPE string.
***Xstring to binary
CREATE OBJECT l_zipper.
"add file to zip
CALL METHOD l_zipper->add
  EXPORTING
    name    = 'Material_report.xls' "filename
    content = lv_xstring.
"save zip
CALL METHOD l_zipper->save
  RECEIVING
    zip = lv_xstring.

DATA :lit_binary_content TYPE solix_tab.
"* Convert Xstring into Binary
CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer     = lv_xstring
  TABLES
    binary_tab = lit_binary_content.
*        EXCEPTIONS
*          program_error                     = 1
*          OTHERS                            = 2.

DATA :l_attsubject TYPE sood-objdes.
CLEAR: l_data.
CONCATENATE 'Material_master_' sy-datum INTO l_data.
l_attsubject = l_data.
CLEAR l_data.
* Create Attachment
TRY.
    lo_document->add_attachment( EXPORTING
                                    i_attachment_type = 'ZIP'
                                    i_attachment_subject = l_attsubject
                                    i_att_content_hex = lit_binary_content  ).
    catch  CX_DOCUMENT_BCS.
ENDTRY.

"*Set Sender
DATA: lo_sender TYPE REF TO if_sender_bcs VALUE IS INITIAL.
TRY.
    lo_sender = cl_sapuser_bcs=>create( sy-uname ). "sender is the logged in user
* Set sender to send request
    lo_send_request->set_sender(
    EXPORTING
    i_sender = lo_sender ).
*    CATCH CX_ADDRESS_BCS.
****Catch exception here
ENDTRY.

DATA : p_email TYPE adr6-smtp_addr VALUE 'necip.ertug@detaysoft.com'.
**Set recipient
DATA: lo_recipient TYPE REF TO if_recipient_bcs VALUE IS INITIAL.
lo_recipient = cl_cam_address_bcs=>create_internet_address( p_email ). "Here Recipient is email input p_email
TRY.
    lo_send_request->add_recipient(
        EXPORTING
        i_recipient = lo_recipient
        i_express = 'X' ).
*  CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
ENDTRY.


*Set immediate sending
TRY.
    CALL METHOD lo_send_request->set_send_immediately
      EXPORTING
        i_send_immediately = 'X'.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
**Catch exception here
ENDTRY.

TRY.
** Send email
    lo_send_request->send(
    EXPORTING
    i_with_error_screen = 'X' ).
    COMMIT WORK.
    IF sy-subrc = 0.
      WRITE :/ 'Mail sent successfully'.
    ENDIF.
*    CATCH CX_SEND_REQ_BCS INTO BCS_EXCEPTION .
*catch exception here
ENDTRY.
