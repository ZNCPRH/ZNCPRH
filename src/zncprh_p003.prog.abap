*&---------------------------------------------------------------------*
*& Report ZNCPRH_P003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p003.

SELECT * FROM snwd_so_sl INTO TABLE @DATA(lt_data) UP TO 10000 ROWS.


LOOP AT lt_data INTO DATA(ls_data).

  DATA(lv_tabix) = sy-tabix.

  zncprh_cl004=>get_instance( )->show_progress(
    EXPORTING
      i_tabix = lv_tabix     " ABAP System Field: Row Index of Internal Tables
      i_count = lines( lt_data[] )     " ABAP System Field: Row Index of Internal Tables
      i_text  = 'Veriler İşleniyor'    " Metin (120 karakter uzunluğunda)
  ).

ENDLOOP.
