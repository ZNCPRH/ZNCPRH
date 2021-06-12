class ZNCPRH_CL001 definition
  public
  final
  create public .

public section.

  class-methods READ_PAYRESULT
    importing
      value(IV_PERNR) type PERSNO optional
      value(IV_FPPER) type FPPER optional
    exporting
      value(RT_RT) type PC207_TAB .
  class-methods READ_PA0041
    importing
      value(IS_PA041) type P0041 optional
      value(IV_DATAR) type DATAR optional
    exporting
      value(RV_DATUM) type DARDT .
  class-methods GET_PERSONEL_INFOTYPES
    importing
      value(IT_PERNR) type HCM_T_CICO_PERNR_TAB optional
    returning
      value(RT_INFOTYPES) type ZNCPRH_TT001 .
  class-methods GET_PERSONEL_INFOTYPES_2
    importing
      value(IT_PERNR) type HCM_T_CICO_PERNR_TAB optional
    returning
      value(RT_INFOTYPES) type ZNCPRH_TT001 .
  class-methods TCNO_VALIDATION
    importing
      value(MERNI) type PTR_MERNI optional
    returning
      value(VALID) type CHAR1 .
  class-methods PERSONEL_DEPARTMENT_PERSONS
    importing
      value(IV_UNAME) type SY-UNAME optional
      value(IV_REFERANCE) type CHAR1 optional
    returning
      value(RT_PERS) type ZNCPRH_TT002 .
  class-methods GET_LEADER_AND_MAIL
    importing
      value(IV_OBJID) type REALO optional
    exporting
      value(EV_LEADER_PERNR) type REALO
      value(EV_LEADER_MAIL) type COMM_ID_LONG .
  class-methods GET_MOLGA
    importing
      value(IV_PERNR) type PERSNO
    returning
      value(RV_MOLGA) type MOLGA .
  class-methods GET_PERSONEL_IMAGE
    importing
      value(IT_PERNR) type ZNCPRH_TT030 optional
    exporting
      value(RT_DATA) type ZNCPRH_TT031 .
protected section.
private section.
ENDCLASS.



CLASS ZNCPRH_CL001 IMPLEMENTATION.


  METHOD get_leader_and_mail.
    DATA :leader_type TYPE  otype,
          leader_id   TYPE  realo,
          multiple    TYPE  flag,
          ls_pa0105   TYPE  pa0105.

    CALL FUNCTION 'RH_GET_LEADER'
      EXPORTING
        plvar                     = '01'
        keydate                   = sy-datum
        otype                     = 'P'
        objid                     = iv_objid
      IMPORTING
        leader_type               = leader_type
        leader_id                 = ev_leader_pernr
        multiple                  = multiple
      EXCEPTIONS
        no_leader_found           = 1
        no_leading_position_found = 2
        OTHERS                    = 3.

    IF ev_leader_pernr IS NOT INITIAL.
      SELECT SINGLE * FROM pa0105 INTO ls_pa0105
         WHERE pernr EQ ev_leader_pernr
            AND usrty EQ '0010'
              AND begda LE sy-datum
                AND endda GE sy-datum.
      ev_leader_mail = ls_pa0105-usrid_long.
    ENDIF.
  ENDMETHOD.


  METHOD get_molga.
    CALL FUNCTION 'HR_COUNTRYGROUPING_GET'
      EXPORTING
        pernr     = iv_pernr
        tclas     = 'A'
        begda     = sy-datum
        endda     = sy-datum
      IMPORTING
        molga     = rv_molga
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
  ENDMETHOD.


  METHOD get_personel_image.


    DATA: BEGIN OF ls_merni,
            pernr TYPE persno,
            merni TYPE ptr_merni,
          END OF ls_merni.
    DATA   lt_merni LIKE TABLE OF ls_merni.

    DATA   ls_pernr    TYPE zncprh_s030.

    DATA   ls_persdata TYPE zncprh_s031.


    DATA: lr_resim TYPE RANGE OF toahr-object_id,
          ls_resim LIKE LINE OF lr_resim.

    DATA: lt_toahr TYPE TABLE OF toahr,
          ls_toahr TYPE          toahr.

    DATA : BEGIN OF ls_objidtoahr,
             objid TYPE saeobjid,
           END OF ls_objidtoahr,
           lt_objidtoahr LIKE TABLE OF ls_objidtoahr.

    DATA : archiv_id     TYPE  toaar-archiv_id,
           archiv_doc_id TYPE  sapb-sapadokid,
           bindata       TYPE TABLE OF  tbl1024,
           ls_bindata    TYPE tbl1024,
           pic_xstr      TYPE xstring,
           archivobject  TYPE TABLE OF  docs.


    CHECK it_pernr IS NOT INITIAL.

*  lt_archiv_id  = /dsl/hlcl01=>get_esaglik_param( 'P_ARC_ARCHIV_ID' ).
*  lt_doc_type   = /dsl/hlcl01=>get_esaglik_param( 'P_ARC_DOC_TYPE' ).
*  lt_sap_object = /dsl/hlcl01=>get_esaglik_param( 'P_ARC_SAP_OBJECT' ).

    SELECT pernr merni
      FROM pa0770
      INTO TABLE lt_merni
      FOR ALL ENTRIES IN it_pernr
         WHERE pernr EQ it_pernr-pernr
         AND   endda GE sy-datum
         AND   begda LE sy-datum
         AND   subty EQ '01'.
*

    LOOP AT it_pernr INTO ls_pernr.
      ls_objidtoahr-objid = ls_pernr-pernr.
      APPEND ls_objidtoahr TO lt_objidtoahr.
      CLEAR ls_objidtoahr.
    ENDLOOP.


*  READ TABLE lt_archiv_id   INTO ls_archiv_id   INDEX 1.
*  READ TABLE lt_doc_type    INTO ls_doc_type    INDEX 1.
*  READ TABLE lt_sap_object  INTO ls_sap_object  INDEX 1.

    archiv_id = 'A2'.

    DATA: lv_archiv_id  TYPE saearchivi VALUE 'A2',
          lv_sap_object TYPE saeanwdid  VALUE 'PREL',
          lv_doc_type   TYPE saeobjart  VALUE 'HRICOLFOTO'.

    SELECT  * FROM toahr AS a INTO TABLE lt_toahr
      FOR ALL ENTRIES IN lt_objidtoahr
      WHERE sap_object EQ lv_sap_object
        AND archiv_id  EQ lv_archiv_id
        AND ar_object  EQ lv_doc_type
        AND ar_date    EQ (
                   SELECT MAX( ar_date ) FROM toahr WHERE sap_object EQ lv_sap_object
                                                    AND   archiv_id  EQ lv_archiv_id
                                                    AND   ar_object  EQ lv_doc_type
                                                    AND   object_id  EQ a~object_id )
        AND object_id EQ lt_objidtoahr-objid.

    CLEAR ls_pernr.

    LOOP AT it_pernr INTO ls_pernr.

      ls_persdata-pernr = ls_pernr-pernr.

      READ TABLE lt_merni INTO ls_merni WITH KEY pernr = ls_pernr-pernr.
      IF sy-subrc EQ 0.
        ls_persdata-merni = ls_merni-merni.
      ENDIF.

      READ TABLE lt_toahr  INTO ls_toahr
          WITH KEY object_id(8) = ls_pernr-pernr.
      IF sy-subrc EQ 0.
        archiv_doc_id = ls_toahr-arc_doc_id.

        CALL FUNCTION 'ARCHIVOBJECT_GET_BYTES'
          EXPORTING
            archiv_id                = archiv_id
            archiv_doc_id            = archiv_doc_id
            document_type            = 'JPG'
            length                   = 0
            offset                   = 0
          TABLES
            archivobject             = archivobject
            binarchivobject          = bindata
          EXCEPTIONS
            error_archiv             = 1
            error_communicationtable = 2
            error_kernel             = 3
            OTHERS                   = 4.

        LOOP AT bindata INTO ls_bindata.
          CONCATENATE ls_persdata-resim_bin ls_bindata-line INTO
          ls_persdata-resim_bin IN BYTE MODE.
        ENDLOOP.

      ENDIF.

      APPEND ls_persdata TO rt_data.
      CLEAR: ls_persdata,archiv_doc_id.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_personel_infotypes.

    SET LOCALE LANGUAGE 'T'.

    DELETE it_pernr WHERE table_line IS INITIAL.
    TYPES ty_objid TYPE RANGE OF saeobjid.

    DATA rt_pernr TYPE RANGE OF persno .
    rt_pernr = VALUE #( FOR s_pernr IN it_pernr ( sign   = 'I'
                                                  option = 'EQ'
                                                  low    = s_pernr   )
                                                 ) .
    SELECT DISTINCT
      p1~pernr ,
      p1~ename ,
      p1~btrtl ,
      t1~btext ,
      p1~persg ,
      t2~ptext ,
      p1~persk ,
      t3~ptext AS perskt,
      p1~plans ,
      h1~stext AS planst,
      p1~orgeh ,
      h2~stext AS orgeht,
      p1~stell ,
      h3~stext AS stellt,"AÇ
      p1~kostl ,
      kt~ltext ,
      p1~abkrs ,"
      t4~atext ,"
      p00~begda AS dat01,
      p00~begda ,
     " p00~endda ,

      CASE
        WHEN p00_last~pernr <> ' ' THEN  CAST( p00_last~begda     AS DATS )
        ELSE   CAST( '99991231'    AS DATS )   END AS endda ,
      p2~gbdat ,
      p6~stras ,
      p6~ort01 ,

       p15~usrid AS usrid ,
       p15_1~usrid AS usrid03,
       p15_2~usrid AS usrid04,
       p15_3~usrid_long AS usrid30,
      p70~merni ,
      t1w~bukrs  ,
      t1w~butxt  ",

       FROM  pa0001 AS p1

        INNER JOIN pa0000 AS p00  ON p00~pernr = p1~pernr
                                 AND (   p00~massn = '01'  OR p00~massn =  '03' OR p00~massn = '12' )
                                 AND p1~begda LE @sy-datum
                                 AND p1~endda GE @sy-datum

  "bitiş tarihi
        LEFT OUTER JOIN pa0000 AS p00_last  ON p00_last~pernr = p1~pernr
                                 AND p00_last~begda LE @sy-datum
                                 AND p00_last~endda GE @sy-datum
                                 AND p00_last~massn = '10'"İşten ayrılma !
  "end bitiş tarihi

        LEFT OUTER JOIN t001        AS t1w    ON ( p1~bukrs EQ t1w~bukrs )


        LEFT OUTER JOIN t001p AS t1
                     ON t1~werks  EQ p1~werks
                    AND t1~btrtl  EQ p1~btrtl
                    AND t1~molga  EQ '47'
        LEFT OUTER JOIN t501t AS t2
                     ON t2~sprsl EQ @sy-langu
                    AND t2~persg EQ p1~persg
        LEFT OUTER JOIN t503t AS t3
                     ON t3~sprsl EQ @sy-langu
                    AND t3~persk EQ p1~persk
        LEFT OUTER JOIN cskt AS kt
                     ON kt~spras EQ @sy-langu
                    AND kt~kostl EQ p1~kostl
                    AND kt~datbi GE @sy-datum
                       "pozisyon texti.
        LEFT OUTER JOIN hrp1000 AS h1
                     ON h1~objid EQ p1~plans
                    AND h1~otype EQ 'S'
                    AND h1~plvar EQ '01'
                    AND h1~istat EQ '1'
                    AND h1~begda LE @sy-datum
                    AND h1~endda GE @sy-datum
                    AND h1~langu EQ @sy-langu
                 "Organizasyon texti.
        LEFT OUTER JOIN hrp1000 AS h2
                     ON h2~objid EQ p1~orgeh
                    AND h2~otype EQ 'O'
                    AND h2~plvar EQ '01'
                    AND h2~istat EQ '1'
                    AND h2~begda LE @sy-datum
                    AND h2~endda GE @sy-datum
                    AND h2~langu EQ @sy-langu

                 "iş nesnesi texti.
        LEFT OUTER JOIN hrp1000 AS h3
                     ON h3~objid EQ p1~stell
                    AND h3~otype EQ 'C'
                    AND h3~plvar EQ '01'
                    AND h3~istat EQ '1'
                    AND h3~begda LE @sy-datum
                    AND h3~endda GE @sy-datum
                    AND h3~langu EQ @sy-langu

        LEFT OUTER JOIN pa0002 AS p2  ON p1~pernr = p2~pernr AND
                                         p2~begda <= @sy-datum AND
                                         p2~endda >  @sy-datum


        LEFT OUTER JOIN pa0006 AS p6  ON p1~pernr = p6~pernr
                                     AND p6~subty = '1'
                                     AND p6~begda <= @sy-datum
                                     AND p6~endda >  @sy-datum

        LEFT OUTER JOIN pa0105 AS p15 ON p1~pernr = p15~pernr   AND
                                         p15~begda LE @sy-datum AND
                                         p15~endda GE @sy-datum AND
                                         p15~subty EQ '0001'

        LEFT OUTER JOIN pa0105 AS p15_1 ON p1~pernr = p15_1~pernr   AND
                                         p15_1~begda LE @sy-datum AND
                                         p15_1~endda GE @sy-datum AND
                                         p15_1~subty EQ '0003'

        LEFT OUTER JOIN pa0105 AS p15_2 ON p1~pernr = p15_2~pernr AND
                                         p15_2~begda LE @sy-datum AND
                                         p15_2~endda GE @sy-datum AND
                                         p15_2~subty EQ '0004'
        LEFT OUTER JOIN pa0105 AS p15_3 ON p1~pernr = p15_3~pernr AND
                                         p15_3~begda LE @sy-datum AND
                                         p15_3~endda GE @sy-datum AND
                                         p15_3~subty EQ '0030'

        LEFT OUTER JOIN pa0770 AS p70 ON p1~pernr = p70~pernr AND
                                         p70~begda <= @sy-datum AND
                                         p70~endda >  @sy-datum AND
                                         p70~subty = '01'
        LEFT OUTER JOIN t549t AS t4 ON t4~sprsl = @sy-langu AND
                                       t4~abkrs = p1~abkrs
     INTO CORRESPONDING FIELDS OF TABLE @rt_infotypes WHERE p1~pernr IN @rt_pernr .


    SORT rt_infotypes BY pernr endda DESCENDING.
    DELETE ADJACENT DUPLICATES FROM rt_infotypes COMPARING pernr.


    IF rt_infotypes[] IS NOT INITIAL.


      SELECT * FROM pa0000 INTO TABLE @DATA(lt_p000) FOR ALL ENTRIES IN @rt_infotypes
              WHERE pernr  EQ @rt_infotypes-pernr
                AND begda  LE @sy-datum
                AND endda  GE @sy-datum
                AND massn  IN ('10' ,'12').
      SORT  lt_p000 BY pernr.

      DATA(lr_objid) = VALUE ty_objid( FOR gy IN rt_infotypes
                                        sign = 'I' option = 'EQ'
                                        ( low = CONV #( gy-pernr ) ) ).

      SELECT th1~object_id , th1~arc_doc_id  AS image_docid , th1~reserve AS image_reserve ,
         th1~ar_date , t1~creatime FROM
                                    toahr AS th1 LEFT OUTER JOIN toaat AS t1
                                          ON th1~sap_object  = 'PREL' AND
                                           th1~ar_object  = 'HRICOLFOTO' AND
                                           th1~arc_doc_id = t1~arc_doc_id AND
                                           th1~archiv_id = 'Z2' AND
                                           th1~sap_object = 'PREL'
       WHERE th1~object_id IN  @lr_objid INTO TABLE @DATA(lt_images).
      SORT lt_images BY object_id ar_date DESCENDING creatime DESCENDING.
      DELETE ADJACENT DUPLICATES FROM  lt_images COMPARING object_id.


    ENDIF.

    LOOP AT rt_infotypes ASSIGNING FIELD-SYMBOL(<f1>).

      TRY .
          DATA(ls_image) = lt_images[ object_id = <f1>-pernr ].
          <f1>-image_docid = ls_image-image_docid.
          <f1>-image_reserve = ls_image-image_reserve.
        CATCH cx_sy_itab_line_not_found.

          CLEAR ls_image.
      ENDTRY.

      LOOP AT lt_p000 ASSIGNING FIELD-SYMBOL(<f2>)
                      WHERE pernr  = <f1>-pernr.
      ENDLOOP.
      IF sy-subrc EQ 0.
        <f1>-endda = <f2>-begda.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD GET_PERSONEL_INFOTYPES_2.

    SET LOCALE LANGUAGE 'T'.

    DELETE it_pernr WHERE table_line IS INITIAL.
    TYPES ty_objid TYPE RANGE OF saeobjid.

    DATA rt_pernr TYPE RANGE OF persno .
    rt_pernr = VALUE #( FOR s_pernr IN it_pernr ( sign   = 'I'
                                                  option = 'EQ'
                                                  low    = s_pernr   )
                                                 ) .
    DATA lv_begda TYPE sy-datum.

    SELECT DISTINCT
      p1~pernr ,
      p1~ename ,
      p1~btrtl ,
      t1~btext ,
      p1~persg ,
      t2~ptext ,
      p1~persk ,
      t3~ptext AS perskt,
      p1~plans ,
      h1~stext AS planst,
      p1~orgeh ,
      h2~stext AS orgeht,
      p1~stell ,
      h3~stext AS stellt,"AÃ‡
      p1~kostl ,
      kt~ltext ,
      p1~abkrs ,"
      t4~atext ,"
      p00~begda AS dat01,
      p2~vorna ,
      p2~nachn ,

      "p2~gesch ,
      CASE WHEN p2~gesch = '2' THEN '0'
           WHEN p2~gesch = '1' THEN '1'
            ELSE ' ' END AS gesch ,


      CASE WHEN p00~begda <> '00000000' AND p00~begda <> ' ' THEN p00~begda
      ELSE
      p41~dat01 END AS begda ,
      CASE
        WHEN p00_last~pernr <> ' ' THEN  CAST( p00_last~begda     AS DATS )
        ELSE   CAST( '99991231'    AS DATS )   END AS endda ,

      p2~gbdat ,
      p6~stras ,
      p6~ort01 ,

       p15~usrid AS usrid ,
       p15_1~usrid AS usrid03,
       p15_2~usrid AS usrid04,
       p15_3~usrid_long AS usrid30,

      p70~merni ,
      p15_5~usrid_long AS email ,
      t1w~bukrs  ,
      t1w~butxt  ",

       FROM  pa0001 AS p1

        INNER JOIN pa0000 AS p00  ON p00~pernr = p1~pernr
                                 AND (   p00~massn = '01'  OR p00~massn =  '03' OR p00~massn = '12' )
                                 AND p1~begda LE @sy-datum
                                 AND p1~endda GE @sy-datum

  "bitiÅŸ tarihi
        LEFT OUTER JOIN pa0000 AS p00_last  ON p00_last~pernr = p1~pernr
                                 AND p00_last~begda LE @sy-datum
                                 AND p00_last~endda GE @sy-datum
                                 AND p00_last~massn = '10'"Ä°ÅŸten ayrÄ±lma !
  "end bitiÅŸ tarihi

        LEFT OUTER JOIN t001        AS t1w    ON ( p1~bukrs EQ t1w~bukrs )



  "baÅŸla tarih deÄŸgis

          LEFT OUTER JOIN pa0041 AS p41  ON p41~pernr = p1~pernr AND
                                         p41~begda <= @sy-datum AND
                                         p41~endda >  @sy-datum AND
                                        " p41~subty = '0001'     AND
                                         p41~dar01 = '01'

        LEFT OUTER JOIN t001p AS t1
                     ON t1~werks  EQ p1~werks
                    AND t1~btrtl  EQ p1~btrtl
                    AND t1~molga  EQ '47'
        LEFT OUTER JOIN t501t AS t2
                     ON t2~sprsl EQ @sy-langu
                    AND t2~persg EQ p1~persg
        LEFT OUTER JOIN t503t AS t3
                     ON t3~sprsl EQ @sy-langu
                    AND t3~persk EQ p1~persk
        LEFT OUTER JOIN cskt AS kt
                     ON kt~spras EQ @sy-langu
                    AND kt~kostl EQ p1~kostl
                    AND kt~datbi GE @sy-datum
                       "pozisyon texti.
        LEFT OUTER JOIN hrp1000 AS h1
                     ON h1~objid EQ p1~plans
                    AND h1~otype EQ 'S'
                    AND h1~plvar EQ '01'
                    AND h1~istat EQ '1'
                    AND h1~begda LE @sy-datum
                    AND h1~endda GE @sy-datum
                    AND h1~langu EQ @sy-langu
                 "Organizasyon texti.
        LEFT OUTER JOIN hrp1000 AS h2
                     ON h2~objid EQ p1~orgeh
                    AND h2~otype EQ 'O'
                    AND h2~plvar EQ '01'
                    AND h2~istat EQ '1'
                    AND h2~begda LE @sy-datum
                    AND h2~endda GE @sy-datum
                    AND h2~langu EQ @sy-langu

                 "iÅŸ nesnesi texti.
        LEFT OUTER JOIN hrp1000 AS h3
                     ON h3~objid EQ p1~stell
                    AND h3~otype EQ 'C'
                    AND h3~plvar EQ '01'
                    AND h3~istat EQ '1'
                    AND h3~begda LE @sy-datum
                    AND h3~endda GE @sy-datum
                    AND h3~langu EQ @sy-langu

        LEFT OUTER JOIN pa0002 AS p2  ON p1~pernr = p2~pernr AND
                                         p2~begda <= @sy-datum AND
                                         p2~endda >  @sy-datum


        LEFT OUTER JOIN pa0006 AS p6  ON p1~pernr = p6~pernr
                                     AND p6~subty = '1'
                                     AND p6~begda <= @sy-datum
                                     AND p6~endda >  @sy-datum

        LEFT OUTER JOIN pa0105 AS p15_5 ON p1~pernr = p15_5~pernr AND
                                         p15_5~begda LE @sy-datum AND
                                         p15_5~endda GE @sy-datum AND
                                         p15_5~subty EQ '0010'

        LEFT OUTER JOIN pa0105 AS p15 ON p1~pernr = p15~pernr   AND
                                         p15~begda LE @sy-datum AND
                                         p15~endda GE @sy-datum AND
                                         p15~subty EQ '0001'

        LEFT OUTER JOIN pa0105 AS p15_1 ON p1~pernr = p15_1~pernr   AND
                                         p15_1~begda LE @sy-datum AND
                                         p15_1~endda GE @sy-datum AND
                                         p15_1~subty EQ '0003'

        LEFT OUTER JOIN pa0105 AS p15_2 ON p1~pernr = p15_2~pernr AND
                                         p15_2~begda LE @sy-datum AND
                                         p15_2~endda GE @sy-datum AND
                                         p15_2~subty EQ '0004'
        LEFT OUTER JOIN pa0105 AS p15_3 ON p1~pernr = p15_3~pernr AND
                                         p15_3~begda LE @sy-datum AND
                                         p15_3~endda GE @sy-datum AND
                                         p15_3~subty EQ '0030'

        LEFT OUTER JOIN pa0770 AS p70 ON p1~pernr = p70~pernr AND
                                         p70~begda <= @sy-datum AND
                                         p70~endda >  @sy-datum AND
                                         p70~subty = '01'
        LEFT OUTER JOIN t549t AS t4 ON t4~sprsl = @sy-langu AND
                                       t4~abkrs = p1~abkrs
     INTO CORRESPONDING FIELDS OF TABLE @Rt_infotypes WHERE p1~pernr IN @rt_pernr .

    SORT Rt_infotypes BY pernr endda DESCENDING.
    DELETE ADJACENT DUPLICATES FROM Rt_infotypes COMPARING pernr.


    IF Rt_infotypes[] IS NOT INITIAL.


      SELECT * FROM pa0000 INTO TABLE @DATA(lt_p000) FOR ALL ENTRIES IN @Rt_infotypes
              WHERE pernr  EQ @Rt_infotypes-pernr
                AND begda  LE @sy-datum
                AND endda  GE @sy-datum
                AND massn  IN ('10' ,'12').
      SORT  lt_p000 BY pernr.

      DATA(lr_objid) = VALUE ty_objid( FOR gy IN Rt_infotypes
                                        sign = 'I' option = 'EQ'
                                        ( low = CONV #( gy-pernr ) ) ).

      SELECT th1~object_id , th1~arc_doc_id  AS image_docid , th1~reserve AS image_reserve ,
         th1~ar_date , t1~creatime FROM
                                    toahr AS th1 LEFT OUTER JOIN toaat AS t1
                                          ON th1~sap_object  = 'PREL' AND
                                           th1~ar_object  = 'HRICOLFOTO' AND
                                           th1~arc_doc_id = t1~arc_doc_id AND
                                           th1~archiv_id = 'Z2' AND
                                           th1~sap_object = 'PREL'
       WHERE th1~object_id IN  @lr_objid INTO TABLE @DATA(lt_images).
      SORT lt_images BY object_id ar_date DESCENDING creatime DESCENDING.
      DELETE ADJACENT DUPLICATES FROM  lt_images COMPARING object_id.


    ENDIF.

    LOOP AT Rt_infotypes ASSIGNING FIELD-SYMBOL(<f1>).

      TRY .
          DATA(ls_image) = lt_images[ object_id = <f1>-pernr ].
          <f1>-image_docid = ls_image-image_docid.
          <f1>-image_reserve = ls_image-image_reserve.
        CATCH cx_sy_itab_line_not_found.

          CLEAR ls_image.
      ENDTRY.


      LOOP AT lt_p000 ASSIGNING FIELD-SYMBOL(<f2>)
                    WHERE pernr  = <f1>-pernr AND massn = '10'."
      ENDLOOP.      "iÅŸten ayrÄ±lma !
      IF sy-subrc EQ 0.
        <f1>-endda = <f2>-begda.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD personel_department_persons.

    DATA: lv_orgeh  TYPE pa0001-orgeh.
    DATA : ls_data  TYPE pa0001-orgeh.
    DATA : it_objec TYPE TABLE OF objec .
    DATA : lt_objec TYPE TABLE OF objec .
    DATA : es_pers  TYPE zncprh_s002.
*
    IF iV_referance = 'X'.
      SELECT pernr AS objid , ename  AS stext FROM pa0001
              INTO CORRESPONDING FIELDS OF TABLE @lt_objec
             WHERE endda >= @sy-datum AND  pernr NOT IN (
          SELECT DISTINCT pernr   FROM pa0000
        WHERE endda > @sy-datum  AND massn = '10' ) .

    ELSE.

      SELECT SINGLE usrid,pernr FROM pa0105 INTO @DATA(lv_uname)
        WHERE subty EQ '0001'
          AND usrid EQ @iv_uname
          AND begda LE @sy-datum
          AND endda GE @sy-datum.
      IF sy-subrc = 0.


        SELECT SINGLE orgeh,pernr FROM pa0001
           INTO  @DATA(iv_orgeh)
          WHERE pernr EQ @lv_uname-pernr
            AND begda LE @sy-datum
            AND endda GE @sy-datum.
        IF sy-subrc = 0.
          CALL FUNCTION 'RH_PM_GET_STRUCTURE'
            EXPORTING
              plvar           = '01'
              otype           = 'O'
              objid           = iv_orgeh-orgeh
              begda           = sy-datum
              endda           = sy-datum
*             STATUS          = '1'
              wegid           = 'O-O_DOWN'
*             77AW_INT        = ' '
*             AUTHY           = 'X'
*             DEPTH           = 0
*             CHECK_OBJECT    = ' '
*             PROGRESS_INDICATOR       = ' '
*             SVECT           =
*             ACTIV           = 'X'
*             BUFFER_MODE     =
            TABLES
              objec_tab       = it_objec
*             STRUC_TAB       =
*             GDSTR_TAB       =
            EXCEPTIONS
              not_found       = 1
              ppway_not_found = 2
              OTHERS          = 3.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

          LOOP AT it_objec INTO DATA(s_objec).
            SELECT pernr AS objid , ename  AS stext FROM pa0001
              WHERE endda >= @sy-datum  AND orgeh = @s_objec-objid"@iv_orgeh-orgeh
              APPENDING CORRESPONDING FIELDS OF TABLE @lt_objec.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

    LOOP AT lt_objec INTO DATA(ls_objec) WHERE objid <> lv_uname-pernr. "AND otype = 'P'.
      es_pers-pernr = ls_objec-objid.
      es_pers-ename = ls_objec-stext.
      COLLECT es_pers INTO rt_pers.
      CLEAR es_pers.
    ENDLOOP.
  ENDMETHOD.


  METHOD read_pa0041.
    DATA :lv_dar TYPE datar,
          lv_dat TYPE dardt.
    DATA :ls_pa041 TYPE pa0041.


    ls_pa041 = CORRESPONDING #( is_pa041 ).
    CHECK ls_pa041 IS NOT INITIAL .

    CLEAR: lv_dar, lv_dat.
    DO 12 TIMES VARYING lv_dar FROM ls_pa041-dar01
                               NEXT ls_pa041-dar02
                VARYING lv_dat FROM ls_pa041-dat01
                               NEXT ls_pa041-dat02.
      IF lv_dar EQ iv_datar.
        rv_datum  = lv_dat. EXIT .
      ENDIF.
    ENDDO.

  ENDMETHOD.


  METHOD read_payresult.
    DATA: lt_rgdir TYPE TABLE OF pc261.
    DATA :lt_py_result TYPE paytr_result.

    CALL FUNCTION 'CU_READ_RGDIR'
      EXPORTING
        persnr          = iv_pernr
      TABLES
        in_rgdir        = lt_rgdir
      EXCEPTIONS
        no_record_found = 1
        OTHERS          = 2.

    READ TABLE lt_rgdir INTO DATA(ls_rgdir)
                    WITH KEY srtza = 'A'
                             fpper = iv_fpper.
    CHECK sy-subrc EQ 0.
    CLEAR lt_py_result.
    CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
      EXPORTING
        clusterid                    = 'TR'
        employeenumber               = iv_pernr
        sequencenumber               = ls_rgdir-seqnr
        check_read_authority         = 'X'
      CHANGING
        payroll_result               = lt_py_result
      EXCEPTIONS
        illegal_isocode_or_clusterid = 1
        error_generating_import      = 2
        import_mismatch_error        = 3
        subpool_dir_full             = 4
        no_read_authority            = 5
        no_record_found              = 6
        versions_do_not_match        = 7
        OTHERS                       = 8.


    rt_rt[]  = lt_py_result-inter-rt[].

  ENDMETHOD.


  METHOD TCNO_VALIDATION.
    DATA: lv_divided(11) TYPE n,
          lv_num1        TYPE n,
          lv_num2        TYPE n,
          lv_num3        TYPE n,
          lv_num4        TYPE n,
          lv_num5        TYPE n,
          lv_num6        TYPE n,
          lv_num7        TYPE n,
          lv_num8        TYPE n,
          lv_num9        TYPE n,
          lv_top1        TYPE n,
          lv_top2        TYPE n,
          lv_hsp1(3)     TYPE n,
          lv_hsp2(3)     TYPE n.

    lv_num1 = merni+0(1).
    lv_num2 = merni+1(1).
    lv_num3 = merni+2(1).
    lv_num4 = merni+3(1).
    lv_num5 = merni+4(1).
    lv_num6 = merni+5(1).
    lv_num7 = merni+6(1).
    lv_num8 = merni+7(1).
    lv_num9 = merni+8(1).

    lv_divided = merni+0(9).

    lv_hsp1 =  ( lv_num1 + lv_num3 + lv_num5 + lv_num7 + lv_num9 ) * 3
              + ( lv_num2 + lv_num4 + lv_num6 + lv_num8 ).
    lv_top1 = ( 10 - ( lv_hsp1 MOD 10 ) ) MOD 10.

    lv_hsp2 =  ( lv_num2 + lv_num4 + lv_num6 + lv_num8 + lv_top1 ) * 3
              + ( lv_num1 + lv_num3 + lv_num5 + lv_num7 + lv_num9 ).
    lv_top2 = ( 10 - ( lv_hsp2 MOD 10 ) ) MOD 10.

    lv_divided = ( lv_divided * 100 ) + ( lv_top1 * 10 ) + lv_top2.

    IF lv_divided EQ merni.
      valid = 'X'.
    ELSE.
      CLEAR valid.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
