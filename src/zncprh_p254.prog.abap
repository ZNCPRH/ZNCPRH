*&---------------------------------------------------------------------*
*& Report ZNCPRH_P254
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p254.

DATA : lc_class TYPE REF TO zncprh_cl012.

CREATE OBJECT lc_class.

DATA : gt_string   LIKE  zncprh_cl012=>gt_string.
DATA : gt_numeric  LIKE  zncprh_cl012=>gt_numeric.
DATA : gt_dats     LIKE  zncprh_cl012=>gt_dats.

TRY .
    lc_class->get_string(
      EXPORTING
        iv_clnt = sy-mandt
      IMPORTING
        et_kna1 = gt_string
    ).
    lc_class->get_num(
      EXPORTING
        iv_clnt =  sy-mandt
      IMPORTING
        et_num  =  gt_numeric
    ).

    lc_class->get_dats(
      EXPORTING
        iv_clnt = sy-mandt
      IMPORTING
        et_dats = gt_dats
    ).
  CATCH cx_amdp_error.

ENDTRY.
