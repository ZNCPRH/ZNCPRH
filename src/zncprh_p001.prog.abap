*&---------------------------------------------------------------------*
*& Report ZNCPRH_P001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p001.

DATA : ls_s001 TYPE zncprh_s011,
       ls_s002 TYPE zncprh_s012.

FIELD-SYMBOLS : <lt_dyn_data> TYPE STANDARD TABLE.

*--------------------------------------------------------------------*

zncprh_cl006=>create_itab_dyn(
  EXPORTING
    iv_gjahr_beg =  CONV #( 2020 )
    iv_gjahr_end =  CONV #( 2027 )
    iv_row       =  ls_s001
    iv_col       =  ls_s002
  IMPORTING
    er_data      = DATA(lr_data)
).

ASSIGN lr_data->* TO <lt_dyn_data>.


*--------------------------------------------------------------------*

BREAK p1362.
