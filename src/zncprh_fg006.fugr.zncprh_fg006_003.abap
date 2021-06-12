FUNCTION zncprh_fg006_003.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_ISLNO) TYPE  NUMC09 OPTIONAL
*"     VALUE(IV_ISLEM) TYPE  ZNCPRH_DE024 OPTIONAL
*"     VALUE(IV_SEQNR) TYPE  ZNCPRH_DE016 OPTIONAL
*"  EXPORTING
*"     VALUE(EV_BUTTON) TYPE  ZNCPRH_DE023
*"     VALUE(EV_SEQNR) TYPE  ZNCPRH_DE016
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  et_return = zncprh_cl014=>apply_process( iv_islno = iv_islno
                                            iv_islem = iv_islem
                                            iv_seqnr = iv_seqnr ).

  zncprh_cl014=>get_button_info(
     EXPORTING
       iv_islno  =  iv_islno       " 9 uzunluğunda numara alanı
     IMPORTING
       ev_button =  ev_button " Akort Fiori Button Kontrolleri
       ev_seqnr  =  ev_seqnr  " Onay Sıra Numarası
   ).

ENDFUNCTION.
