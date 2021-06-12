*&---------------------------------------------------------------------*
*& Report ZNCPRH_P050
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p050.

DATA :lv_base64_1 TYPE string,
      lv_last_xml TYPE string.

lv_base64_1 = cl_http_utility=>if_http_utility~encode_base64( lv_last_xml ).

*--------------------------------------------------------------------*
DATA: lv_xstring TYPE xstring,       "Xstring
      lv_base64  TYPE string.        "Base64

CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
  EXPORTING
    text   = lv_last_xml
  IMPORTING
    buffer = lv_xstring
  EXCEPTIONS
    failed = 1
    OTHERS = 2.

CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
  EXPORTING
    input  = lv_xstring
  IMPORTING
    output = lv_base64.

*--------------------------------------------------------------------*
*  CALL METHOD cl_http_utility=>if_http_utility~decode_x_base64
*EXPORTING
*encoded = lv_base64_pdf
*RECEIVING
*decoded = lv_decodedx.
*
*CALL METHOD cl_http_utility=>if_http_utility~encode_x_base64
*EXPORTING
*unencoded = lv_decodedx
*RECEIVING
*encoded = lv_base64_pdf.
