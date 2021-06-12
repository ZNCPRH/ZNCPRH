*&---------------------------------------------------------------------*
*& Report ZNCPRH_P501
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p501.

DATA(r_kscha) = VALUE piq_selopt_t( sign   = 'I'
                                    option = 'EQ' ( low = 'ZPR0' )
                                                  ( low = 'ZK01' )
                                  ).

*--------------------------------------------------------------------*

DATA(ls_mara) = VALUE mara( matnr = '12' ersda = sy-datum ).

*--------------------------------------------------------------------*

DATA(lt_mara) = VALUE mara_tab( ( matnr = '123' ersda = sy-datum )
                                ( ls_mara ) ).

*--------------------------------------------------------------------*

TYPES: BEGIN OF t_makt,
         spras TYPE spras,
         makt  TYPE makt,
       END OF t_makt.

TYPES: BEGIN OF t_desc_mara,
         matnr TYPE matnr,
         makt  TYPE t_makt,
       END OF t_desc_mara.

DATA(ls_desc_mara)   = VALUE t_desc_mara( matnr = 'Malzeme1'
                                          makt  =
                       VALUE t_makt(  spras = 'T' makt-mandt = '300' makt-maktx   = 'Türkçe malzeme' ) ).

*--------------------------------------------------------------------*

TYPES t_itab TYPE TABLE OF i.
DATA itab TYPE t_itab.

itab = VALUE #( ( ) ( 1 ) ( 2 ) ).

*--------------------------------------------------------------------*


TYPES tt_mara2 TYPE STANDARD TABLE OF mara WITH DEFAULT KEY.
DATA(lt_mara2) = VALUE tt_mara2( ( mandt = '834' matnr = '456' matkl = 'DENEME')
                                 ( mandt = '999' matnr = '789' matkl = 'TEST') ).

DATA :lr_massn       TYPE RANGE OF massn .
DATA :lr_stat2       TYPE RANGE OF stat2 .
DATA :lr_datum       TYPE RANGE OF datum.
DATA :lr_aedtm       TYPE RANGE OF datum.

lr_massn = VALUE #( option = 'EQ' sign = 'I'
   ( low = '02' )
    ).
lr_stat2 = VALUE #( option = 'EQ' sign = 'I'

    ( low = '3' ) ).
lr_aedtm = VALUE #( option = 'EQ' sign = 'I'
 ( low = sy-datum )
 ( low = sy-datum - 1  ) ).

lr_datum = VALUE #( option = 'EQ' sign = 'I'
      ( low = sy-datum )
      ( low = sy-datum - 2 )
      ( low = sy-datum - 1  ) ).
BREAK p1362.
