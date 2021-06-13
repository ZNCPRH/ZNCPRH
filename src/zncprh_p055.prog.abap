*&---------------------------------------------------------------------*
*& Report ZNCPRH_P055
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZNCPRH_P055.

DATA: http_client TYPE REF TO if_http_client.
DATA: lv_url      TYPE string.
DATA: return      TYPE xstring.
DATA: token       TYPE string.

DATA : lo_conv     TYPE REF TO cl_abap_conv_in_ce,
       lv_response TYPE string.

DATA lt_par_table TYPE tihttpnvp.
DATA ls_par_table LIKE LINE OF lt_par_table.

FIELD-SYMBOLS: <fs_value> TYPE any.
FIELD-SYMBOLS: <fs_struc> TYPE any.

DATA : BEGIN OF gt_text OCCURS 5,
         txt(50) TYPE c,
       END OF gt_text.

**-
START-OF-SELECTION.
  PERFORM get_token CHANGING token.
  PERFORM get_sip USING token.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  get_token
*&---------------------------------------------------------------------*

FORM get_token CHANGING token TYPE string.
  DATA : BEGIN OF result             ,
           token TYPE string,
         END OF  result.

  lv_url  = 'http://mando-crm-api.dogut.net/api/login'.

  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url    = lv_url
    IMPORTING
      client = http_client.

**HTTP basic authenication
*  http_client->propertytype_logon_popup = http_client->co_disabled.
*  DATA l_username TYPE string.
*  DATA l_password TYPE string.
*
*  l_username = 'mando_crm_entegrasyon@alphetech.com'.
*  l_password = 'password'.
*  CALL METHOD http_client->authenticate
*    EXPORTING
*      username = l_username
*      password = l_password.

  ls_par_table-name = 'email'.
  ls_par_table-value = 'mando_crm_entegrasyon@alphetech.com'.
  APPEND ls_par_table TO lt_par_table.
  ls_par_table-name = 'password'.
  ls_par_table-value = 'MandoService_5886'.
  APPEND ls_par_table TO lt_par_table.

  CALL METHOD http_client->request->set_form_fields
    EXPORTING
      fields     = lt_par_table
      multivalue = 1.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Content-Type'
      value = 'application/json'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'X-Requested-With'
      value = 'XMLHttpRequest'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_method'
      value = 'POST'.

  CALL METHOD http_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2.
  IF sy-subrc NE 0.
    CALL METHOD http_client->get_last_error
      IMPORTING
        message = DATA(mess).
    EXIT.
  ENDIF.

  CALL METHOD http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.
  IF sy-subrc NE 0.
    CALL METHOD http_client->get_last_error
      IMPORTING
        message = mess.
  ENDIF.

  return = http_client->response->get_data( ).

  lo_conv = cl_abap_conv_in_ce=>create( input = return ).
  lo_conv->read( IMPORTING data = lv_response ).

  /ui2/cl_json=>deserialize( EXPORTING json = lv_response
pretty_name = /ui2/cl_json=>pretty_mode-camel_case CHANGING data
= result ).

  token = result-token.

  http_client->close( ).
ENDFORM.
FORM get_sip USING token.
  lv_url  = 'http://mando-crm-api.dogut.net/api/order/update-order-line-status-bysalesnumber'.

  CONCATENATE 'Bearer' token INTO token SEPARATED BY space.

  clear http_client.

  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url    = lv_url
    IMPORTING
      client = http_client.

  ls_par_table-name = 'SalesOrderNumber'.
  ls_par_table-value = 'SP1'.
  APPEND ls_par_table TO lt_par_table.
  ls_par_table-name = 'LineNumber'.
  ls_par_table-value = '1'.
  APPEND ls_par_table TO lt_par_table.
  ls_par_table-name = 'SalesOrderStatusId'.
  ls_par_table-value = '7'.
  APPEND ls_par_table TO lt_par_table.

  CALL METHOD http_client->request->set_form_fields
    EXPORTING
      fields     = lt_par_table
      multivalue = 1.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Content-Type'
      value = 'application/json'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'X-Requested-With'
      value = 'XMLHttpRequest'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_method'
      value = 'POST'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Authorization'
      value = token.

  CALL METHOD http_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2.
  IF sy-subrc NE 0.
    CALL METHOD http_client->get_last_error
      IMPORTING
        message = DATA(mess).
    EXIT.
  ENDIF.

  CALL METHOD http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.
  IF sy-subrc NE 0.
    CALL METHOD http_client->get_last_error
      IMPORTING
        message = mess.
  ENDIF.

  return = http_client->response->get_data( ).

  lo_conv = cl_abap_conv_in_ce=>create( input = return ).
  lo_conv->read( IMPORTING data = lv_response ).

  DATA : BEGIN OF result    ,
           token TYPE string,
         END OF  result     .
/ui2/cl_json=>deserialize( EXPORTING json = lv_response
pretty_name = /ui2/cl_json=>pretty_mode-camel_case CHANGING data
= result ).

  token = result-token.

  http_client->close( ).
ENDFORM.
