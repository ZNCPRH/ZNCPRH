*&---------------------------------------------------------------------*
*& Report ZNCPRH_P508
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p508.

SELECT * FROM mara INTO TABLE @DATA(lt_mara).

DATA: lt_mara_ernam TYPE STANDARD TABLE OF mara,
      ls_mara       TYPE mara,
      ls_mara_ernam TYPE mara.
"eskisi
BREAK-POINT.
LOOP AT lt_mara INTO ls_mara.
  CLEAR ls_mara_ernam.
  ls_mara_ernam-ernam = ls_mara-ernam.
  COLLECT ls_mara_ernam INTO lt_mara_ernam.
ENDLOOP.

BREAK-POINT.
LOOP AT lt_mara_ernam INTO ls_mara_ernam.
  LOOP AT lt_mara INTO ls_mara WHERE ernam = ls_mara_ernam-ernam.
*    İşlemler...
  ENDLOOP.
ENDLOOP.
"endeskisi

*--------------------------------------------------------------------*

"yenisi
LOOP AT lt_mara INTO DATA(ls_mara_gr)
  GROUP BY ( ernam = ls_mara_gr-ernam )
  ASCENDING
  ASSIGNING FIELD-SYMBOL(<fs_group>).

  LOOP AT GROUP <fs_group> INTO DATA(ls_mara_field).
*    İşlemler...

  ENDLOOP.
*  BREAK-POINT.

ENDLOOP.
"endyenisi
