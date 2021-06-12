*&---------------------------------------------------------------------*
*& Report ZNCPRH_P255
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p255.


TRY.
*    zncprh_cl013=>insert_( iv_client = sy-mandt ).
*    zncprh_cl013=>delete_( iv_client = sy-mandt ).
    zncprh_cl013=>update_( iv_client = sy-mandt ).
  CATCH cx_amdp_error.

ENDTRY.
