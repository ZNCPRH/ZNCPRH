FUNCTION zncprh_fg006_002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_ISLNO) TYPE  NUMC09 OPTIONAL
*"  EXPORTING
*"     VALUE(EV_BUTTON) TYPE  ZNCPRH_DE023
*"     VALUE(EV_SEQNR) TYPE  ZNCPRH_DE016
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  et_return = zncprh_cl014=>send_to_approve( iv_islno ).

  zncprh_cl014=>get_button_info(
         EXPORTING
           iv_islno  =  iv_islno       " 9 uzunluğunda numara alanı
         IMPORTING
           ev_button =  ev_button " Akort Fiori Button Kontrolleri
           ev_seqnr  =  ev_seqnr  " Onay Sıra Numarası
       ).
ENDFUNCTION.
