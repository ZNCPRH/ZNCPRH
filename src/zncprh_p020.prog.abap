*&---------------------------------------------------------------------*
*& Report ZNCPRH_P020
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p020.

TABLES : bseg ,bkpf,sscrfields ,dd03p,bsid,tcurr.
***** tabscript lerin baslıkları yazılıyo *****
INITIALIZATION.

*-
  SELECTION-SCREEN FUNCTION KEY 1.
  SELECTION-SCREEN BEGIN OF BLOCK b12 WITH FRAME TITLE TEXT-s04.
  SELECT-OPTIONS   : p_bukrs FOR bkpf-bukrs  OBLIGATORY  MEMORY ID buk.
  SELECT-OPTIONS   : s_hesab  FOR  bseg-hkont  MODIF ID bk               .
  PARAMETERS       : hk1 RADIOBUTTON GROUP gr1  USER-COMMAND radio,
                     hk2 RADIOBUTTON GROUP gr1             , "Satıcı
                     hk3 RADIOBUTTON GROUP gr1             . "ANA HESAP
  SELECTION-SCREEN END OF BLOCK b12 .

  SELECTION-SCREEN BEGIN OF SCREEN 1010 AS SUBSCREEN .

  SELECTION-SCREEN BEGIN OF BLOCK dsel WITH FRAME TITLE TEXT-999.
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS rbcg RADIOBUTTON GROUP  hd1 USER-COMMAND rbdat DEFAULT 'X' . "Cari Gün
  SELECTION-SCREEN COMMENT (12) TEXT-998 FOR FIELD rbcg      .
  PARAMETERS rbch RADIOBUTTON GROUP  hd1                     . "Cari Hafta
  SELECTION-SCREEN COMMENT (12) TEXT-997 FOR FIELD rbch      .
  PARAMETERS rbca RADIOBUTTON GROUP  hd1                     . "Cari Ay
  SELECTION-SCREEN COMMENT (12) TEXT-996 FOR FIELD rbca      .
  PARAMETERS rbcy RADIOBUTTON GROUP  hd1                     . "Cari Yıl
  SELECTION-SCREEN COMMENT (12) TEXT-995 FOR FIELD rbcy      .
  PARAMETERS rbsg RADIOBUTTON GROUP  hd1                     . "Serbest Giriş
  SELECTION-SCREEN COMMENT (12) TEXT-994 FOR FIELD rbsg      .
  SELECTION-SCREEN END   OF LINE .
  SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT (12) TEXT-993 FOR FIELD p_begda    .
  PARAMETERS  p_begda LIKE sy-datum OBLIGATORY                .
  SELECTION-SCREEN END   OF LINE.

  SELECTION-SCREEN END   OF BLOCK dsel .

  SELECTION-SCREEN BEGIN OF BLOCK b13 WITH FRAME TITLE TEXT-s02.

  PARAMETERS      : rbg RADIOBUTTON GROUP  hr1 USER-COMMAND radio , "Günlük
                    rbh RADIOBUTTON GROUP  hr1             , "Haftalık
                    rba RADIOBUTTON GROUP  hr1             , "aylık
                    rbs RADIOBUTTON GROUP  hr1             . "Seçim
  PARAMETERS      : pgun TYPE i OBLIGATORY DEFAULT '005' MODIF ID pr1.
  SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 01(30) TEXT-026 MODIF ID pr2.
  SELECTION-SCREEN POSITION POS_LOW.
  PARAMETERS: rastbis1 LIKE rfpdo1-allgrogr DEFAULT '030' MODIF ID pr2.
  PARAMETERS: rastbis2 LIKE rfpdo1-allgrogr DEFAULT '060' MODIF ID pr2.
  PARAMETERS: rastbis3 LIKE rfpdo1-allgrogr DEFAULT '090' MODIF ID pr2.
  PARAMETERS: rastbis4 LIKE rfpdo1-allgrogr DEFAULT '120' MODIF ID pr2.
  PARAMETERS: rastbis5 LIKE rfpdo1-allgrogr DEFAULT '150' MODIF ID pr2.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN END OF BLOCK b13 .

  SELECTION-SCREEN END OF SCREEN 1010 .

  SELECTION-SCREEN BEGIN OF SCREEN 1060 AS SUBSCREEN .
  SELECTION-SCREEN BEGIN OF BLOCK status WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
  PARAMETERS x_opsel LIKE itemset-xopsel RADIOBUTTON GROUP rad1.
  SELECTION-SCREEN COMMENT 3(20) TEXT-003 FOR FIELD x_opsel.
  SELECTION-SCREEN END OF LINE.
  PARAMETERS pa_stida LIKE rfpdo-allgstid DEFAULT sy-datlo.
*   all items:
  SELECTION-SCREEN BEGIN OF LINE.
  PARAMETERS x_aisel LIKE itemset-xaisel RADIOBUTTON GROUP rad1.
  SELECTION-SCREEN COMMENT 3(20) TEXT-005 FOR FIELD x_aisel.
  SELECTION-SCREEN END OF LINE.
  SELECT-OPTIONS s_budat FOR bsid-budat NO DATABASE SELECTION.
  PARAMETERS : xnorm LIKE itemset-xnorm DEFAULT 'X',
               xshbv LIKE itemset-xshbv.
  PARAMETERS : nzrero AS CHECKBOX DEFAULT 'X',
               tkayit AS CHECKBOX.

  SELECTION-SCREEN END OF BLOCK status.
  SELECTION-SCREEN END OF SCREEN 1060 .

*-- 1020 AS SUBSCREEN .
  SELECTION-SCREEN BEGIN OF SCREEN 1020 AS SUBSCREEN .
  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-s03.
  PARAMETERS      : rnt RADIOBUTTON GROUP gr2  DEFAULT 'X', "NetVadeTrh
                    rkt RADIOBUTTON GROUP gr2             , "Kayit Tarihi
                    rbt RADIOBUTTON GROUP gr2             , "Belge Tarihi
                    rtt RADIOBUTTON GROUP gr2             , "Temel Tarihi
                    rgt RADIOBUTTON GROUP gr2             . "Giriş Tarihi
  SELECTION-SCREEN PUSHBUTTON /1(20)  bscr USER-COMMAND buton.
  SELECTION-SCREEN END OF BLOCK b3 .
  SELECTION-SCREEN END OF SCREEN 1020 .
*-- 1030 AS SUBSCREEN .
  SELECTION-SCREEN BEGIN OF SCREEN 1030 AS SUBSCREEN .
  SELECTION-SCREEN BEGIN OF BLOCK b14 WITH FRAME TITLE TEXT-s02.
  SELECT-OPTIONS  : s_gjahr FOR bsid-gjahr      ,
                    s_monat FOR bkpf-monat      ,
                    s_bldat FOR bkpf-bldat      ,
                    s_cpudt FOR bkpf-cpudt      ,
                    s_augdt FOR bsid-augdt      ,
                    s_zfbdt FOR bsid-zfbdt      .
  SELECTION-SCREEN END OF BLOCK b14 .
  SELECTION-SCREEN END OF SCREEN 1030 .
*-- 1040 AS SUBSCREEN .
  SELECTION-SCREEN BEGIN OF SCREEN 1040 AS SUBSCREEN .
  SELECT-OPTIONS  : s_saknr FOR bseg-saknr              ,
                    s_hkont FOR bseg-hkont MODIF ID hk3 ,
                    s_kunnr FOR bseg-kunnr MODIF ID hk1 ,
                    s_lifnr FOR bseg-lifnr MODIF ID hk2 ,
                    s_gsber FOR bseg-gsber              ,
                    s_zuonr FOR bseg-zuonr              ,
                    s_bschl FOR bseg-bschl              ,
                    s_shkzg FOR bseg-shkzg              .

  SELECT-OPTIONS  : s_tab   FOR dd03p-tabname NO-DISPLAY                 .
  SELECTION-SCREEN END OF SCREEN 1040 .
*-- 1050 AS SUBSCREEN .
  SELECTION-SCREEN BEGIN OF SCREEN 1050 AS SUBSCREEN .
  SELECT-OPTIONS  : s_zterm FOR bsid-zterm              ,
                    s_zlsch FOR bsid-zlsch              ,
                    s_xblnr FOR bkpf-xblnr              ,
                    s_umskz FOR bseg-umskz              ,
                    s_blart FOR bkpf-blart              ,
                    s_waers FOR bkpf-waers              .

  PARAMETERS: par_sgtx LIKE bseg-sgtxt,
              p_vari   LIKE disvariant-variant NO-DISPLAY,
              p_vari2  LIKE disvariant-variant.

  SELECTION-SCREEN END OF SCREEN 1050 .
*- Selection-Screen 2000
  SELECTION-SCREEN BEGIN OF SCREEN 2000 ..
  SELECTION-SCREEN BEGIN OF BLOCK b21 WITH FRAME TITLE TEXT-s21.
  PARAMETERS      : rm0 RADIOBUTTON GROUP  hr2 USER-COMMAND radio , "Bp
                    rm1 RADIOBUTTON GROUP  hr2             , "Up
                    rm2 RADIOBUTTON GROUP  hr2             , "UP2
                    rm3 RADIOBUTTON GROUP  hr2             , "UP3
                    rm4 RADIOBUTTON GROUP  hr2             . "UP4
  SELECTION-SCREEN END OF BLOCK b21 .
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-s02.
  PARAMETERS      : pkdate LIKE sy-datum    DEFAULT sy-datum MODIF ID kr,
                    pkurst LIKE tcurr-kurst DEFAULT 'M'      MODIF ID kr,
                    pfcurr LIKE tcurr-tcurr DEFAULT 'TRY'    MODIF ID kr.
  PARAMETERS      : p_cvbt AS CHECKBOX MODIF ID kr.
  SELECTION-SCREEN END OF BLOCK b2 .
  SELECTION-SCREEN END OF SCREEN 2000 .
***** tab-screen *****
  SELECTION-SCREEN BEGIN OF TABBED BLOCK tabbl FOR 11 LINES.
  SELECTION-SCREEN TAB (16) tabs1010 USER-COMMAND ucomm1
                       DEFAULT SCREEN 1010.
  SELECTION-SCREEN TAB (15) tabs1020 USER-COMMAND ucomm6
                       DEFAULT SCREEN 1060.
  SELECTION-SCREEN TAB (15) tabs1030 USER-COMMAND ucomm2
                       DEFAULT SCREEN 1020.
  SELECTION-SCREEN TAB (15) tabs1040 USER-COMMAND ucomm3
                       DEFAULT SCREEN 1030.
  SELECTION-SCREEN TAB (15) tabs1050 USER-COMMAND ucomm4
                       DEFAULT SCREEN 1040.
  SELECTION-SCREEN TAB (15) tabs1060 USER-COMMAND ucomm5
                       DEFAULT SCREEN 1050.
  SELECTION-SCREEN END OF BLOCK tabbl.

  tabs1010 = TEXT-t02.
  tabs1020 = TEXT-t03.
  tabs1030 = TEXT-t04.
  tabs1040 = TEXT-t05.
  tabs1050 = TEXT-t06.
  tabs1060 = TEXT-t07.
