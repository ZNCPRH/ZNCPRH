*&---------------------------------------------------------------------*
*& Report ZNCPRH_P014
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p014.

* Data Selection
SELECT * FROM sflight INTO TABLE @DATA(gt_outtab)
               UP TO 00030 ROWS.

DATA : lt_sum TYPE ccgld_fieldnames,
       ls_sum TYPE lvc_fname.

ls_sum = 'PAYMENTSUM'.
INSERT ls_sum INTO TABLE lt_sum.

CALL FUNCTION 'ZNCPRH_FG001_001'
  EXPORTING
    it_table      = gt_outtab[]
*   I_FULL_ALV    = 'X'
*   I_TITLE       =
    it_sum_fields = lt_sum.
