*&---------------------------------------------------------------------*
*& Report ZNCPRH_P502
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p502.

DATA : lv_mblnr  TYPE bapi2017_gm_head_ret-mat_doc,
       lv_mjahr  TYPE bapi2017_gm_head_ret-doc_year,
       lt_item   TYPE bapi2017_gm_item_create_t,
       lt_return TYPE bapiret2_t.

CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
  EXPORTING
    goodsmvt_header  = VALUE bapi2017_gm_head_01(
                             doc_date   = sy-datum
                             header_txt = 'TESTTT'
                             pr_uname   = sy-uname
                             pstng_date = sy-datum )
    goodsmvt_code    = VALUE bapi2017_gm_code( gm_code = '03' )
  IMPORTING
    materialdocument = lv_mblnr " Number of Material Document
    matdocumentyear  = lv_mjahr " Material Document Year
  TABLES
    goodsmvt_item    = lt_item
    return           = lt_return. "Return Messages
