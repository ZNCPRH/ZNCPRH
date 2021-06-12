*&---------------------------------------------------------------------*
*& Report ZNCPRH_P252
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p252.

TABLES vbak.
SELECT-OPTIONS s_vbeln FOR vbak-vbeln.

TYPES : BEGIN OF ty_vbak.
          INCLUDE TYPE vbak.
        TYPES : END OF ty_vbak.
DATA : gt_data TYPE STANDARD TABLE OF ty_vbak.


TYPES : BEGIN OF ty_op,
          sign(1)   TYPE c,
          option(2) TYPE c,
          low(10)   TYPE c,
          high(10)  TYPE c,
        END OF ty_op.

DATA : gt_vbeln TYPE TABLE OF ty_op.

DATA(gc_class) = NEW zncprh_cl011(  ).
gt_vbeln = CORRESPONDING #( s_vbeln[] ).

gc_class->get_data_between(
  EXPORTING
    it_vbeln = gt_vbeln
  IMPORTING
    et_vbak  = gt_data
).

BREAK p1362.
