*&---------------------------------------------------------------------*
*& Report ZNCPRH_P500
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p500.

"correspending str
DATA(ls_mara)  = VALUE mara( mandt = '123' matnr = '123' matkl = 'test' ).
DATA(ls_mara2) = CORRESPONDING mara( ls_mara ).

*--------------------------------------------------------------------*

"correspending table
TYPES tt_mara2 TYPE STANDARD TABLE OF mara WITH DEFAULT KEY.
DATA(lt_mara2) = VALUE tt_mara2( ( mandt = '834' matnr = '456' matkl = 'DENEME')
                                 ( mandt = '999' matnr = '789' matkl = 'TEST') ).

TYPES : tt_msg TYPE TABLE OF mseg WITH DEFAULT KEY.
DATA(lt_msg) = CORRESPONDING tt_msg( lt_mara2 ).

*--------------------------------------------------------------------*

"correspending mapping
"“MAPPING” komutu ile “CORRESPONDING” yaparken farklı alan isimlerine
"sahip değerleride eşleştirebiliriz.
TYPES : tt_msg2 TYPE TABLE OF mseg WITH DEFAULT KEY.
DATA(lt_msg2) = CORRESPONDING tt_msg2( lt_mara2 MAPPING matnr = matkl ).

*--------------------------------------------------------------------*

"correspending except
"“EXCEPT” komutu ile “CORRESPONDING” yaptığımızda isimleri aynı olmasına
"rağmen atama yapılmasını istemediğimiz alanları bu komutun ardından belirtiyoruz.

DATA(lt_msg3) = CORRESPONDING tt_msg2( lt_mara2 MAPPING matnr = matkl EXCEPT mandt ).
*DATA(lt_msg3) = CORRESPONDING tt_msg2( lt_mara2 MAPPING matnr = matkl EXCEPT * ).


BREAK p1362.
