CLASS zncprh_cl012 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.


    TYPES : BEGIN OF ty_string,
              kunnr     TYPE kunnr,
              name(80)  TYPE c,
              tel(4)    TYPE c,
              tarih(4)  TYPE c,
              length    TYPE i,
              replace   TYPE string,
              substring TYPE string,
              lower     TYPE string,
              upper     TYPE string,
              lpad      TYPE string,
              rpad      TYPE string,
              ltrim     TYPE string,
              rtrim     TYPE string,
            END OF ty_string .
    TYPES : tt_string TYPE TABLE OF ty_string.
**********************************************************************
    TYPES : BEGIN OF ty_num,
              abs     TYPE i,
              ceil    TYPE i,
              floor   TYPE i,
              round_u TYPE i,
              round_l TYPE i,
            END OF ty_num.
    TYPES : tt_num TYPE TABLE OF ty_num.
**********************************************************************
    TYPES : BEGIN OF ty_dats,
              pernr           TYPE persno,
              begda           TYPE begda,
              endda           TYPE endda,
              date_valid      TYPE i,
              date_days_bt    TYPE i,
              dats_add_days   TYPE dats,
              dats_add_months TYPE dats,
            END OF ty_dats.
    TYPES : tt_dats TYPE TABLE OF ty_dats.
**********************************************************************
    CLASS-DATA : gt_string  TYPE tt_string,
                 gt_numeric TYPE tt_num,
                 gt_dats    TYPE tt_dats.
**********************************************************************

    METHODS :
      get_string IMPORTING VALUE(iv_clnt) TYPE mandt
               EXPORTING VALUE(et_kna1) TYPE tt_string,
      get_num  IMPORTING VALUE(iv_clnt) TYPE mandt
               EXPORTING VALUE(et_num)  TYPE tt_num,
      get_dats IMPORTING VALUE(iv_clnt) TYPE mandt
               EXPORTING VALUE(et_dats) TYPE tt_dats.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zncprh_cl012 IMPLEMENTATION.
  METHOD get_string BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
                  OPTIONS READ-ONLY USING kna1.
    et_kna1 = select kunnr ,
                    concat(name1,name2) as name,
                    left (telf1,4) as tel,
*                    soldan 4 karakter
                    right(erdat,4) as tarih ,
*                    sagdan 4 karakter
                    length( stras ) as length ,
                    replace( name1 , 'Veli', 'İtirazim Var' ) as replace ,
                    substring( name1 , 1 , 3 ) as substring ,
                    lower( name1 ) as lower,
                    upper( name1 ) as upper,
                    lpad( regio , 10,'X' ) as lpad ,
*                     "soldan 10 kar. olana kadar X atar
                    rpad( regio , 10,'X' ) as rpad ,
*                     "sağdan 10 kar. olana kadar X atar
                    ltrim( name1 , 'm' ) as ltrim ,
*                    "soldan E karakterini ve boşlukları siler
                    rtrim( name1 , 'e' ) as rtrim
*                    "sağdan e karakterini ve boşukları sıler
                    from kna1 where mandt = iv_clnt
                    order by kunnr;
  ENDMETHOD.
  METHOD get_num BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
               OPTIONS READ-ONLY USING bseg.
    et_num = select
       abs(wrbtr) as abs,
*                       mutlak değer
       ceil (wrbtr) as ceil,
*                       yukarı yuvarlar
       floor(wrbtr ) as floor,
*                       aşağı yuvarla
       round( wrbtr, 1) as round_u,
*                       virgülden sonraki değere kadara yuvarlar
       round( wrbtr, -1) as  round_l
*                       eğer negatifse virgulden onceki değeri
       from bseg where mandt = iv_clnt ;
  ENDMETHOD.
  METHOD get_dats BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
                 OPTIONS READ-ONLY USING pa0000.
    et_dats = select     pernr ,
                         begda as begda,
                         endda as endda,
                         dats_is_valid(begda) as date_valid,
                         dats_days_between(begda,'20190725') as  date_days_bt,
                         dats_add_days (begda,10,'INITIAL' ) as dats_add_days,
                         dats_add_months (begda, 1,'NULL' ) as dats_add_months
                         from pa0000 where mandt = iv_clnt  ;
  ENDMETHOD.
ENDCLASS.
