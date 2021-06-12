*&---------------------------------------------------------------------*
*& Report ZNCPRH_P504
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p504.
"cond verilen sarta uygun veriyi değişkenın içine atar
"ilk şart False olsa bile lv_value değişkeni onun türünde oluşur.
DATA(lv_value) = COND #( WHEN 1 = 2 THEN 'TEXXXXXXX'
                         WHEN 2 = 2 THEN 'TEST2'
                         WHEN 1 = 3 THEN 'TEST3'
                         ELSE 'TEST4'
                       ).
*--------------------------------------------------------------------*
DATA(lv_value2) = COND char5( WHEN 1 = 2 THEN 'TEST1'
                              WHEN 2 = 2 THEN 'TEST2'
                              WHEN 1 = 3 THEN 'TEST3'
                              ELSE 'TEST4'
                             ).
*--------------------------------------------------------------------*
DATA(ls_pernr2) = COND #( WHEN 1 = 1 THEN VALUE pernr( pernr = '1431' )
                                     ELSE VALUE pernr( pernr = '1362' ) ).
*--------------------------------------------------------------------*

TYPES : BEGIN OF ty_mara,
          mandt TYPE mandt,
          matnr TYPE matnr,
        END OF ty_mara.
TYPES tt_mara TYPE TABLE OF ty_mara WITH DEFAULT KEY.
DATA(lt_mara) = COND tt_mara( WHEN 1 = 2 THEN VALUE tt_mara( ( mandt = '200' matnr = '1234' ) )
                                         ELSE VALUE tt_mara( ( mandt = '300' matnr = '4321' ) ) ) .
