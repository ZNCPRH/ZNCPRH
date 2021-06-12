class ZNCPRH_CL007 definition
  public
  final
  create public .

public section.

  class-methods GET_USER_INF
    importing
      !I_DATUM type DATUM default SY-DATUM
      !I_PERNR type HROBJID optional
      !I_PLVAR type PLVAR default '01'
    exporting
      !E_PERSONEL type ZNCPRH_S014 .
  class-methods GET_PERNR_FROM_UNAME
    importing
      !I_UNAME type UNAME default SY-UNAME
    exporting
      !E_PERNR type PERSNO .
  class-methods READ_OBJID_TEXT
    importing
      !IP_PLVAR type PLVAR default '01'
      !IP_OTYPE type OTYPE
      !IP_OBJID type HROBJID
      !IM_DATUM type DATUM default SY-DATUM
    exporting
      !EP_STEXT type STEXT
      !EP_SHORT type SHORT_D .
  class-methods GET_ULKE_GRUBU
    importing
      !I_PERNR type PERSNO
      !I_DATUM type DATUM default SY-DATUM
    exporting
      !MOLGA type MOLGA
      !MOABW type MOABW .
protected section.
private section.
ENDCLASS.



CLASS ZNCPRH_CL007 IMPLEMENTATION.


  METHOD get_pernr_from_uname.

    DATA : lv_uname TYPE sysid .

    lv_uname = i_uname  .
    CALL FUNCTION 'RP_GET_PERNR_FROM_USERID'
      EXPORTING
        begda     = sy-datum
        endda     = sy-datum
        usrid     = lv_uname
        usrty     = '0001'
      IMPORTING
        usr_pernr = e_pernr
      EXCEPTIONS
        retcd     = 1
        OTHERS    = 2.

  ENDMETHOD.


  METHOD get_ulke_grubu.
    CLEAR molga .

    IF 1 = 2.
      MESSAGE s000(zutil).
*  SELECT SINGLE molga FROM pa9011 INTO molga            "#EC CI_NOORDER
*          WHERE pernr EQ i_pernr
*            AND subty EQ '05'
*            AND endda GE i_datum
*            AND begda LE i_datum.
    ENDIF.

    IF ( molga IS INITIAL ) .

      CALL FUNCTION 'RH_PM_GET_MOLGA_FROM_PERNR'
        EXPORTING
          plvar           = '01'
          pernr           = i_pernr
          begda           = i_datum
          endda           = i_datum
        IMPORTING
          molga           = molga
        EXCEPTIONS
          nothing_found   = 1
          no_active_plvar = 2
          OTHERS          = 3.

    ENDIF .

    SELECT SINGLE moabw FROM t001p INTO moabw           "#EC CI_NOORDER
            WHERE molga EQ molga.
  ENDMETHOD.


  METHOD get_user_inf.
    DATA : l_sobid  TYPE sobid,
           lv_pernr TYPE pernr_d,
           lt_1001  TYPE TABLE OF hrp1001,
           ls_1001  TYPE hrp1001,
           ls_chief TYPE zncprh_s015,
           BEGIN OF s_sobid,
             l_sobid TYPE sobid,
           END OF s_sobid,
           t_sobid LIKE TABLE OF s_sobid.

    DATA(lv_langu) = sy-langu.
    DATA(lv_prevl) = sy-langu.
    IF lv_langu NE 'T'. lv_langu = 'E'. SET LOCALE LANGUAGE lv_langu. ENDIF.


    CLEAR e_personel.
    lv_pernr = i_pernr.
    IF lv_pernr IS INITIAL.
      CALL METHOD zncprh_cl007=>get_pernr_from_uname
        EXPORTING
          i_uname = sy-uname
        IMPORTING
          e_pernr = lv_pernr.
    ENDIF.

    e_personel-pernr = lv_pernr.

    CALL FUNCTION 'RP_GET_HIRE_DATE'
      EXPORTING
        persnr          = e_personel-pernr
        check_infotypes = '0041'
        datumsart       = '01'
        status2         = '3'
      IMPORTING
        hiredate        = e_personel-hired.

    CALL FUNCTION 'RP_GET_HIRE_DATE'
      EXPORTING
        persnr          = e_personel-pernr
        check_infotypes = '0041'
        datumsart       = '05'
        status2         = '3'
      IMPORTING
        hiredate        = e_personel-hakdt.

*- Personel Genel Bilgileri
    SELECT SINGLE plans stell ename bukrs werks btrtl orgeh kostl persg
            FROM pa0001
            INTO (e_personel-plans ,
                  e_personel-stell ,
                  e_personel-ename ,
                  e_personel-bukrs ,
                  e_personel-werks ,
                  e_personel-btrtl ,
                  e_personel-orgeh ,
                  e_personel-kostl ,
                  e_personel-persg  )
            WHERE pernr EQ e_personel-pernr
              AND begda LE i_datum
              AND endda GE i_datum         .

    CALL METHOD zncprh_cl007=>read_objid_text
      EXPORTING
        ip_plvar = i_plvar
        ip_otype = 'O'
        ip_objid = e_personel-orgeh
      IMPORTING
        ep_stext = e_personel-orgeht.

    CALL METHOD zncprh_cl007=>read_objid_text
      EXPORTING
        ip_plvar = i_plvar
        ip_otype = 'S'
        ip_objid = e_personel-plans
      IMPORTING
        ep_stext = e_personel-planst.

    CALL METHOD zncprh_cl007=>read_objid_text
      EXPORTING
        ip_plvar = i_plvar
        ip_otype = 'C'
        ip_objid = e_personel-stell
      IMPORTING
        ep_stext = e_personel-stellt.

    "şirket kodu metni bukrst
    SELECT SINGLE  butxt FROM t001 INTO e_personel-bukrst
                      WHERE bukrs = e_personel-bukrs
                      AND   spras = sy-langu.

*   Personel alt alanı metni
    SELECT SINGLE btext FROM t001p INTO e_personel-btrtlt
                    WHERE btrtl = e_personel-btrtl .

    SELECT SINGLE ltext FROM cskt INTO e_personel-kostlt
                    WHERE kostl = e_personel-kostl
                      AND spras = sy-langu
                      AND datbi GE sy-datum. .

    "yöneticisi olduğu organizasyon birimleri.
    IF 1 = 2. MESSAGE s000(zutil). ENDIF.
    SELECT otype objid sclas sobid FROM hrp1001
           INTO CORRESPONDING FIELDS OF TABLE lt_1001
             WHERE otype EQ 'P'
               AND objid EQ e_personel-pernr
               AND plvar EQ i_plvar
               AND rsign EQ 'B'
               AND relat EQ '008'
               AND istat EQ '1'
               AND begda LE i_datum
               AND endda GE i_datum
               AND sclas EQ 'S'.

    LOOP AT lt_1001 INTO ls_1001.
      ls_chief-objid = ls_1001-sobid.
      APPEND ls_chief TO e_personel-planstab.

      SELECT sobid FROM hrp1001 INTO TABLE t_sobid
              WHERE otype EQ 'S'
                AND objid EQ ls_chief-objid
                AND plvar EQ '01'
                AND rsign EQ 'A'
                AND relat EQ '012'
                AND begda LE i_datum
                AND endda GE i_datum.
*      check sy-subrc eq 0.
      LOOP AT t_sobid INTO s_sobid.
        ls_chief-objid = s_sobid-l_sobid.
        ls_chief-plans = ls_1001-sobid.
        APPEND ls_chief TO e_personel-chief.
      ENDLOOP.
*    endselect.
    ENDLOOP.
    CALL FUNCTION 'HRWPC_RFC_EP_READ_PHOTO_URI'
      EXPORTING
        pernr            = e_personel-pernr
      IMPORTING
        uri              = e_personel-img
      EXCEPTIONS
        not_supported    = 1
        nothing_found    = 2
        no_authorization = 3
        internal_error   = 4
        OTHERS           = 5.

    get_ulke_grubu(
      EXPORTING
        i_pernr = e_personel-pernr    " Personel numarası
*      i_datum = SY-DATUM    " Tarih
      IMPORTING
        molga   =  e_personel-molga   " Ülke gruplaması
        moabw   =  e_personel-moabw   " Devam/devamsızlık türleri için personel alt aln.gruplaması
    ).

    "Personel alanı metni
    SELECT SINGLE name1 FROM t500p INTO e_personel-werkst
              WHERE persa EQ e_personel-werks
                AND molga EQ e_personel-molga .



    SET LOCALE LANGUAGE lv_prevl.
  ENDMETHOD.


  METHOD read_objid_text.
    CALL FUNCTION 'HR_HCP_READ_OBJECT_TEXT'
      EXPORTING
        im_plvar = ip_plvar
        im_otype = ip_otype
        im_objid = ip_objid
        im_begda = im_datum
        im_endda = im_datum
      IMPORTING
        short    = ep_short
        long     = ep_stext.
  ENDMETHOD.
ENDCLASS.
