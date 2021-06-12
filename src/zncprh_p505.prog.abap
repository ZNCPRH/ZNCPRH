*&---------------------------------------------------------------------*
*& Report ZNCPRH_P505
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p505.

TYPES : tt_mara TYPE STANDARD TABLE OF mara WITH DEFAULT KEY.
DATA(lt_mara) = VALUE tt_mara( ( mandt = '834' matnr = '456' matkl = 'Deneme'  )
                               ( mandt = '999' matnr = '789' matkl = 'Test'    ) ).

*--------------------------------------------------------------------*

TYPES : tt_mseg TYPE STANDARD TABLE OF mseg WITH DEFAULT KEY.
DATA(lt_mseg) = VALUE tt_mseg( ( mandt = '834' matnr = '456' menge = 5 ) ).

*--------------------------------------------------------------------*


TYPES tt_makt TYPE STANDARD TABLE OF makt WITH DEFAULT KEY.
DATA(lt_makt) = VALUE tt_makt( ( mandt = '834' matnr = '456' maktx = 'UZN METN') ).

*--------------------------------------------------------------------*

TYPES : BEGIN OF tt_data ,
          mandt TYPE mandt,
          matnr TYPE matnr,
          maktx TYPE maktx,
          menge TYPE menge_d,
        END OF tt_data.
TYPES tt_tdata TYPE STANDARD TABLE OF tt_data WITH EMPTY KEY.


DATA(mt_table) = VALUE tt_tdata( FOR ws IN lt_mara
                                     WHERE ( mandt = '834 ' AND matnr = '456')
                                     FOR wx IN lt_makt
                                     WHERE ( mandt = ws-mandt
                                       AND   matnr = ws-matnr )
                                     FOR wz IN lt_mseg
                                     WHERE ( mandt = ws-mandt
                                       AND   matnr = ws-matnr )
                                     ( mandt = ws-mandt
                                       matnr = ws-matnr
                                       maktx = wx-maktx
                                       menge = wz-menge ) ).
*--------------------------------------------------------------------*


DATA(mt_table2) = VALUE tt_tdata( FOR ws IN lt_mara
                                 WHERE ( mandt = '834' AND matnr = '456' )
                                       ( mandt = ws-mandt
                                         matnr = ws-matnr
maktx = COND #( WHEN line_exists( lt_makt[ mandt = ws-mandt matnr = ws-matnr ] )
                THEN lt_makt[ mandt = ws-mandt matnr = ws-matnr ]-maktx ELSE space )
menge = COND #( WHEN line_exists( lt_mseg[ mandt = ws-mandt matnr = ws-matnr ] )
                THEN lt_mseg[ mandt = ws-mandt matnr = ws-matnr ]-menge ELSE 0 )
) ).

*--------------------------------------------------------------------*

TYPES : BEGIN OF t_year ,
          year TYPE numc4,
        END OF t_year,
        tt_year TYPE STANDARD TABLE OF t_year WITH EMPTY KEY.

DATA(lt_years)  = VALUE tt_year( FOR i = 2000 THEN i + 1 UNTIL i > 2020 ( year = i ) ).


*--------------------------------------------------------------------*
BREAK-POINT.
