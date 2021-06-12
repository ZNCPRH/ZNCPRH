FUNCTION zncprh_fg006_001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_ISLNO) TYPE  NUMC09 OPTIONAL
*"     VALUE(IS_DATA) TYPE  ZNCPRH_S036 OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"     VALUE(EV_ISLNO) TYPE  NUMC09
*"----------------------------------------------------------------------


  zncprh_cl014=>save_update_islem(
    EXPORTING
      iv_islno  = iv_islno                 " 9 uzunluğunda numara alanı
      is_data   = is_data                 " İşlem Oluşturma Kaydet-Güncelle
    IMPORTING
      et_return = et_return
      ev_islno  = ev_islno                 " 9 uzunluğunda numara alanı
  ).

ENDFUNCTION.
