class ZNCPRH_CL014 definition
  public
  final
  create public .

public section.

  class-methods SAVE_UPDATE_ISLEM
    importing
      value(IV_ISLNO) type NUMC09 optional
      value(IS_DATA) type ZNCPRH_S036 optional
    exporting
      value(ET_RETURN) type BAPIRET2_T
      value(EV_ISLNO) type NUMC09 .
  class-methods MODIFY_RETURN
    changing
      !T_RETURN type BAPIRET2_T .
  class-methods CHECK_SEND_TO_APPROVE
    importing
      value(IV_ISLNO) type NUMC09 optional
    returning
      value(RT_RETURN) type BAPIRET2_T .
  class-methods SEND_TO_APPROVE
    importing
      value(IV_ISLNO) type NUMC09 optional
    returning
      value(RT_RETURN) type BAPIRET2_T .
  class-methods GET_PLANS_TO_PERS
    importing
      value(IV_PLANS) type PLANS optional
    returning
      value(RV_PERNR) type PERSNO .
  class-methods GET_BUTTON_INFO
    importing
      value(IV_ISLNO) type NUMC09 optional
    exporting
      value(EV_BUTTON) type ZNCPRH_DE023
      value(EV_SEQNR) type ZNCPRH_DE016 .
  class-methods GET_PERNR_FROM_UNAME
    importing
      value(IV_UNAME) type UNAME default SY-UNAME
    exporting
      value(EV_PERNR) type PERSNO .
  class-methods APPLY_PROCESS
    importing
      value(IV_ISLNO) type NUMC09 optional
      value(IV_ISLEM) type ZNCPRH_DE024 optional
      value(IV_SEQNR) type ZNCPRH_DE016 optional
    returning
      value(RT_RETURN) type BAPIRET2_T .
  class-methods CHECK_APPLY_PROCESS
    importing
      !IV_ISLNO type NUMC09
      !IV_ISLEM type ZNCPRH_DE024
      !IV_SEQNR type ZNCPRH_DE016
    returning
      value(RT_RETURN) type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZNCPRH_CL014 IMPLEMENTATION.


  METHOD apply_process.

    DATA: ls_return TYPE bapiret2,
          lt_return TYPE bapiret2_t,
          lv_seqnr  TYPE zncprh_de016,
          lv_statu  TYPE zncprh_de015,
          lv_state.

    DEFINE add_return.
      CLEAR ls_return .
      ls_return-type       = &1.
      ls_return-id         = &2.
      ls_return-number     = &3.
      ls_return-message_v1 = &4.
      ls_return-message_v2 = &5.
      ls_return-message_v3 = &6.
      ls_return-message_v4 = &7.
      APPEND ls_return TO rt_return.
    END-OF-DEFINITION.

    rt_return = check_apply_process( iv_islno = iv_islno
                                     iv_islem = iv_islem
                                     iv_seqnr = iv_seqnr ).
    IF rt_return IS NOT INITIAL.
      modify_return( CHANGING t_return = rt_return ).
      RETURN.
    ENDIF.

    get_pernr_from_uname(
      EXPORTING
        iv_uname = sy-uname         " Kullanıcı adı
      IMPORTING
        ev_pernr = DATA(lv_pernr)                 " Personel numarası
    ).

    lv_seqnr = iv_seqnr.

    SELECT SINGLE MAX( priod ) FROM zncprh_t009 INTO @DATA(lv_max_priod)
      WHERE islno EQ @iv_islno.

    SELECT * FROM zncprh_t011 INTO TABLE @DATA(lt_t011)
      WHERE islno EQ @iv_islno
        AND   priod EQ @lv_max_priod.

    SORT lt_t011 BY seqnr.


    CASE iv_islem.
      WHEN 'ONAY'.

        LOOP AT lt_t011 INTO DATA(ls_t011) WHERE seqnr EQ lv_seqnr.

          ls_t011-istat = 02         .
          ls_t011-apdat  = sy-datum  .
          ls_t011-apusr  = sy-uname  .
          ls_t011-aptme  = sy-uzeit  .
          ls_t011-apper  = lv_pernr  ." Personel numarası

          MODIFY zncprh_t011 FROM ls_t011.
          COMMIT WORK AND WAIT .
        ENDLOOP.

        LOOP AT lt_t011 INTO ls_t011 WHERE seqnr > lv_seqnr.
          lv_state = 'X'.
          lv_seqnr = ls_t011-seqnr.
          EXIT.
        ENDLOOP.

        IF lv_state EQ 'X'. " state
          LOOP AT lt_t011 INTO ls_t011 WHERE seqnr EQ lv_seqnr.
            ls_t011-istat  = 01        .
            ls_t011-apbeg  = sy-datum  .
            MODIFY zncprh_t011 FROM ls_t011.
            COMMIT WORK AND WAIT .
          ENDLOOP.
          lv_statu = 10."yönetici onay sürecinde
        ELSE.
          lv_statu = 20."Tamamlandı
        ENDIF.

        SELECT SINGLE * FROM zncprh_t009 INTO @DATA(ls_t009)
          WHERE islno EQ @iv_islno.

        ls_t009-statu  = lv_statu.
        ls_t009-cdatum = sy-datum .
        ls_t009-cname  = sy-uname.
        ls_t009-cuzeit = sy-uzeit.

        MODIFY zncprh_t009 FROM ls_t009.
        COMMIT WORK AND WAIT .

        add_return 'S' 'ZSCPA' '199' iv_islno space space space.

        IF ls_t009-statu EQ 20. "Tamamlandıysa Ana Tablomuza ve Ekip
          "TAblomuza aktarimi yapıyoruz !

        """"""""""""""

        ENDIF.

      WHEN 'RED'.

        LOOP AT lt_t011 INTO ls_t011 WHERE seqnr EQ lv_seqnr.

          ls_t011-istat  = 03        .
          ls_t011-apdat  = sy-datum  .
          ls_t011-apusr  = sy-uname  .
          ls_t011-aptme  = sy-uzeit  .
          ls_t011-apper  = lv_pernr  ." Personel numarası

          MODIFY zncprh_t011 FROM ls_t011.
          COMMIT WORK AND WAIT .

        ENDLOOP.

        DATA(lv_last_period) = ls_t011-priod.

        ADD 1 TO lv_last_period.

        SELECT SINGLE * FROM zncprh_t009 INTO @ls_t009
           WHERE islno EQ @iv_islno.

        ls_t009-statu  = 0."Kaydet Durumuna dönder
        "Onaya gönderilebilir !
        ls_t009-priod  = lv_last_period."""
        ls_t009-cdatum = sy-datum .
        ls_t009-cname  = sy-uname.
        ls_t009-cuzeit = sy-uzeit.

        MODIFY zncprh_t009 FROM ls_t009.
        COMMIT WORK AND WAIT .
        add_return 'S' 'ZSCPA' '200' iv_islno space space space.

      WHEN 'IPTAL'.

        SELECT SINGLE * FROM zncprh_t009 INTO @ls_t009
          WHERE islno EQ @iv_islno.

        ls_t009-statu  = 30       .
        ls_t009-cdatum = sy-datum .
        ls_t009-cname  = sy-uname .
        ls_t009-cuzeit = sy-uzeit .

        MODIFY zncprh_t009 FROM ls_t009.
        COMMIT WORK AND WAIT .

        add_return 'S' 'ZSCPA' '201' iv_islno space space space.
    ENDCASE.
  ENDMETHOD.


  METHOD check_apply_process.

    DATA: ls_return TYPE bapiret2,
          lt_return TYPE bapiret2_t.

    DEFINE add_return.
      CLEAR ls_return .
      ls_return-type       = &1.
      ls_return-id         = &2.
      ls_return-number     = &3.
      ls_return-message_v1 = &4.
      ls_return-message_v2 = &5.
      ls_return-message_v3 = &6.
      ls_return-message_v4 = &7.
      APPEND ls_return TO rt_return.
    END-OF-DEFINITION.



    IF iv_islno IS INITIAL.
      add_return 'E' 'ZNCPRH_MC001' '194' space space space space.
      RETURN.
    ENDIF.

*-

    IF iv_islem IS INITIAL.
      add_return 'E' 'ZNCPRH_MC001' '195' space space space space.
      RETURN.
    ENDIF.

*-

    IF iv_islem EQ 'ONAY' OR iv_islem EQ 'RED'.
      IF iv_seqnr IS INITIAL.
        add_return 'E' 'ZNCPRH_MC001' '196' space space space space.
        RETURN.
      ENDIF.
    ENDIF.

*-

    IF iv_islem EQ 'ONAY' OR
       iv_islem EQ 'RED'  OR
       iv_islem EQ 'IPTAL'  .
    ELSE.
      add_return 'E' 'ZNCPRH_MC001' '203' space space space space.
      RETURN.
    ENDIF.

*-

    SELECT SINGLE * FROM zncprh_t009 INTO @DATA(ls_t009)
      WHERE islno EQ @iv_islno.
    IF sy-subrc NE 0.
      add_return 'E' 'ZNCPRH_MC001' '188' space space space space.
      RETURN.
    ELSEIF ls_t009-statu NE 10.
      IF iv_islem EQ 'ONAY' OR iv_islem EQ 'RED'.
        add_return 'E' 'ZNCPRH_MC001' '197' space space space space.
        RETURN.
      ENDIF.
    ENDIF.

*-
    SELECT SINGLE MAX( priod ) FROM zncprh_t009 INTO @DATA(lv_max_priod)
      WHERE islno EQ @iv_islno.

    SELECT * FROM zncprh_t011 INTO TABLE @DATA(lt_t011)
      WHERE islno EQ @iv_islno
        AND   priod EQ @lv_max_priod.
    IF sy-subrc NE 0.
      IF iv_islem EQ 'ONAY' OR iv_islem EQ 'RED'.
        add_return 'E' 'ZNCPRH_MC001' '198' space space space space.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_send_to_approve.
    DATA: ls_return TYPE bapiret2.

    DEFINE add_return.
      CLEAR ls_return .
      ls_return-type       = &1.
      ls_return-id         = &2.
      ls_return-number     = &3.
      ls_return-message_v1 = &4.
      ls_return-message_v2 = &5.
      ls_return-message_v3 = &6.
      ls_return-message_v4 = &7.
      APPEND ls_return TO rt_return.
    END-OF-DEFINITION.


    IF iv_islno IS INITIAL.
      add_return 'E' 'ZNCPRH_MC001' '187' space space space space.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM zncprh_t009 INTO @DATA(ls_header)
      WHERE islno EQ @iv_islno.
    IF sy-subrc NE 0.
      add_return 'E' 'ZNCPRH_MC001' '188' space space space space.
      RETURN.
    ENDIF.

    IF ls_header-statu NE 0.
      add_return 'E' 'ZNCPRH_MC001' '189' space space space space.
      RETURN.
    ENDIF.

    SELECT * FROM zncprh_t010 INTO TABLE @DATA(lt_t173)
      WHERE werks EQ @ls_header-werks
      AND   btrtl EQ @ls_header-btrtl.
    IF sy-subrc NE 0.
      add_return 'E' 'ZNCPRH_MC001' '190' space space space space.
      RETURN.
    ENDIF.

    SELECT COUNT(*) FROM zncprh_t011
      WHERE islno EQ @iv_islno
      AND   priod EQ @ls_header-priod.
    IF sy-subrc EQ 0.
      add_return 'E' 'ZNCPRH_MC001' '193' space space space space.
    ENDIF.

  ENDMETHOD.


  METHOD get_button_info.
    DATA : lv_pos_pernr TYPE persno,
           lv_seqnr     TYPE zncprh_de016,
           lv_open.

    SELECT SINGLE * FROM zncprh_t009 INTO @DATA(ls_t009)
    WHERE islno EQ @iv_islno.


    "headerdan aldık periyotu
    DATA(lv_max_priod) = ls_t009-priod.

    SELECT SINGLE COUNT(*) FROM zncprh_t011 "işlem bazlı onaycı tablosuna bakalım
         WHERE islno EQ @iv_islno.
    IF sy-subrc NE 0."kayıt yoksa onay süreci başlamamış Kaydet-onaya gönder acık
*      ev_button = 'SAVE'.

      IF ls_t009-aname EQ sy-uname."girenle oluşturan aynıysa
        " iptal edebilir !
        ev_button = 'ISTA'. " İptal-Save-Send to Approve
      ELSE.
        ev_button = 'SAVE'. "Save -
      ENDIF.
    ELSE.

      IF ls_t009-statu EQ '10'."Yönetici onayında mı?

        get_pernr_from_uname(
          EXPORTING
            iv_uname = sy-uname         " Kullanıcı adı
          IMPORTING
            ev_pernr = DATA(lv_pernr)   " Personel numarası
        ).

        SELECT * FROM zncprh_t011 INTO TABLE @DATA(lt_t011)
          WHERE islno EQ @iv_islno
          AND   priod EQ @lv_max_priod.

        LOOP AT lt_t011 INTO DATA(ls_t011) WHERE istat EQ 01."Onay Sürecinde
          CLEAR lv_pos_pernr.

          lv_pos_pernr =  get_plans_to_pers( ls_t011-objid ).

          IF lv_pernr EQ lv_pos_pernr.
            lv_open  = 'X'.
            lv_seqnr = ls_t011-seqnr.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF sy-subrc NE 0.
          ev_button = 'NULL'.
          RETURN.
        ELSE.
          IF lv_open EQ 'X'.
            ev_button = 'OPEN'.
            ev_seqnr  = lv_seqnr.
          ELSE.
            ev_button = 'NULL'.
          ENDIF.
        ENDIF.
      ELSEIF ls_t009-statu EQ 0." onay süreci başlamamış save açık

        IF ls_t009-aname EQ sy-uname."girenle oluşturan aynıysa
          " iptal edebilir !
          ev_button = 'ISTA'. " İptal-Save-Send to Approve
        ELSE.
          ev_button = 'SAVE'. "Save -
        ENDIF.

      ELSEIF ls_t009-statu EQ 20 OR ls_t009-statu EQ 30.
        ev_button = 'NULL'."Onaylanmış veya iptal edilmiş kapalı
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_pernr_from_uname.
    DATA : lv_uname TYPE sysid .

    lv_uname = iv_uname  .
    CALL FUNCTION 'RP_GET_PERNR_FROM_USERID'
      EXPORTING
        begda     = sy-datum
        endda     = sy-datum
        usrid     = lv_uname
        usrty     = '0001'
      IMPORTING
        usr_pernr = ev_pernr
      EXCEPTIONS
        retcd     = 1
        OTHERS    = 2.
  ENDMETHOD.


  METHOD get_plans_to_pers.
    SELECT SINGLE sobid FROM hrp1001 INTO @DATA(lv_sobid)
        WHERE plvar = '01'
          AND otype = 'S'
          AND objid = @iv_plans
          AND rsign = 'A'
          AND relat = '008'
          AND begda <= @sy-datum
          AND endda >= @sy-datum
          AND sclas EQ 'P'.
    rv_pernr = lv_sobid .
  ENDMETHOD.


  METHOD modify_return.
    DATA :lt_imsg   TYPE TABLE OF msg_log,
          ls_imsg   TYPE          msg_log,
          lt_text   TYPE TABLE OF msg_text,
          ls_text   TYPE          msg_text,
          ls_return LIKE LINE  OF t_return.
    CHECK t_return[] IS NOT INITIAL .
    FIELD-SYMBOLS : <fs_data> TYPE bapiret2.
**
    LOOP AT t_return INTO ls_return.
      ls_imsg-msgid = ls_return-id.
      ls_imsg-msgno = ls_return-number.
      ls_imsg-msgty = ls_return-type.
      ls_imsg-msgv1 = ls_return-message_v1.
      ls_imsg-msgv2 = ls_return-message_v2.
      ls_imsg-msgv3 = ls_return-message_v3.
      ls_imsg-msgv4 = ls_return-message_v4.
      APPEND ls_imsg TO lt_imsg.CLEAR ls_imsg.
    ENDLOOP.
**
    CALL FUNCTION 'MESSAGE_TEXTS_READ'
      TABLES
        t_msg_log_imp   = lt_imsg
        t_msg_texts_exp = lt_text.
**


    LOOP AT t_return ASSIGNING <fs_data>.
      CLEAR ls_text.
      READ TABLE lt_imsg TRANSPORTING NO FIELDS WITH KEY msgid = <fs_data>-id
                                                         msgno = <fs_data>-number
                                                         msgty = <fs_data>-type.
      IF sy-subrc EQ 0.
        READ TABLE lt_text INTO ls_text INDEX sy-tabix.
        <fs_data>-message = ls_text-msgtx.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD save_update_islem.

    DATA : lv_islno LIKE iv_islno,
           ls_t009  TYPE zncprh_t009.
    DATA: ls_return TYPE bapiret2.

    DEFINE add_return.
      CLEAR ls_return .
      ls_return-type       = &1.
      ls_return-id         = &2.
      ls_return-number     = &3.
      ls_return-message_v1 = &4.
      ls_return-message_v2 = &5.
      ls_return-message_v3 = &6.
      ls_return-message_v4 = &7.
      APPEND ls_return TO et_return.
    END-OF-DEFINITION.

    IF iv_islno IS INITIAL OR iv_islno EQ 0.
      SELECT SINGLE MAX( islno ) FROM zncprh_t009
        INTO @DATA(lv_maxislno).
      lv_islno = lv_maxislno + 1.
    ELSE.
      lv_islno = iv_islno.
    ENDIF.

    ev_islno = lv_islno.

    MOVE-CORRESPONDING is_data TO ls_t009.
    ls_t009-islno = lv_islno.


    IF iv_islno IS NOT INITIAL.
      SELECT SINGLE * FROM zncprh_t009 INTO @DATA(ls_t009_exist)
        WHERE islno EQ @lv_islno.

      ls_t009-statu  = ls_t009_exist-statu.
      ls_t009-priod  = ls_t009_exist-priod.

      ls_t009-aname  = ls_t009_exist-aname.
      ls_t009-adatum = ls_t009_exist-adatum.
      ls_t009-auzeit = ls_t009_exist-auzeit.

      ls_t009-cname  = sy-uname.
      ls_t009-cdatum = sy-datum.
      ls_t009-cuzeit = sy-uzeit.
    ELSE.
      ls_t009-statu  = 0."Oluşturuldu
      ls_t009-priod  = 1.

      ls_t009-aname  = ls_t009-cname  = sy-uname.
      ls_t009-adatum = ls_t009-cdatum = sy-datum.
      ls_t009-auzeit = ls_t009-cuzeit = sy-uzeit.
    ENDIF.

    MODIFY zncprh_t009 FROM ls_t009.
    COMMIT WORK AND WAIT.
    IF sy-subrc EQ 0.
      IF iv_islno IS NOT INITIAL.
        add_return 'S' 'ZNCPRH_MC001' '181' space space space space.
      ELSE.
        add_return 'S' 'ZNCPRH_MC001' '179' space space space space.
      ENDIF.
    ELSE.
      IF iv_islno IS NOT INITIAL.
        add_return 'E' 'ZNCPRH_MC001' '182' space space space space.
      ELSE.
        add_return 'E' 'ZNCPRH_MC001' '180' space space space space.
      ENDIF.
    ENDIF.


    modify_return( CHANGING t_return = et_return ).
  ENDMETHOD.


  METHOD send_to_approve.
    DATA: ls_return TYPE bapiret2,
          lt_t011   TYPE TABLE OF zncprh_t011.

    DEFINE add_return.
      CLEAR ls_return .
      ls_return-type       = &1.
      ls_return-id         = &2.
      ls_return-number     = &3.
      ls_return-message_v1 = &4.
      ls_return-message_v2 = &5.
      ls_return-message_v3 = &6.
      ls_return-message_v4 = &7.
      APPEND ls_return TO rt_return.
    END-OF-DEFINITION.

    rt_return = check_send_to_approve( iv_islno ).

    IF rt_return IS NOT INITIAL.
      modify_return( CHANGING t_return = rt_return ).
      RETURN.
    ENDIF.

    "Header Verileri
    SELECT SINGLE * FROM zncprh_t009 INTO @DATA(ls_header)
      WHERE islno EQ @iv_islno.

    "Werks-Btrtl Bazlı Onaycıların Alınması!
    SELECT * FROM zncprh_t010 INTO TABLE @DATA(lt_t010)
      WHERE werks EQ @ls_header-werks
      AND   btrtl EQ @ls_header-btrtl
      ORDER BY seqnr.

    DATA(lv_seqnr) = lt_t010[ 1 ]-seqnr.
    "Onaya gönderilince ilk seqnr ' ı onay adımı
    "olarak belirliyoruz.

    DATA(lv_priod) = ls_header-priod.

    LOOP AT lt_t010 INTO DATA(ls_t010).
      APPEND VALUE #( islno  = iv_islno
                      priod  = lv_priod
*                        COND #( WHEN lv_seqnr EQ ls_t173-seqnr
*                                                     THEN lv_priod
*                                                     "headerdaki mevcut priod!
*                                                     ELSE 0 )
                        " period için tüm onaycı kayıtlarına headerdakini attık!
                      seqnr  = ls_t010-seqnr
                      otype  = ls_t010-otype
                      objid  = ls_t010-objid
                      istat  = COND #( WHEN lv_seqnr EQ ls_t010-seqnr
                                                     THEN 1
                                                     ELSE 0 )
                      apbeg  = COND #( WHEN lv_seqnr EQ ls_t010-seqnr
                                                     THEN sy-datum )
                                                          ) TO lt_t011.
    ENDLOOP.


    "Onaycıların İşlem No Bazlı tabloya kaydı.
    MODIFY zncprh_t011 FROM TABLE lt_t011.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
      add_return 'S' 'ZNCPRH_MC001' '191' space space space space.

      SELECT SINGLE * FROM zncprh_t009 INTO @DATA(ls_t009)
        WHERE islno EQ @iv_islno.

      ls_t009-priod  = 1.
      ls_t009-statu  = 10.
      ls_t009-cdatum = sy-datum.
      ls_t009-cname  = sy-uname.
      ls_t009-cuzeit = sy-uzeit.

      "Genel Durumunu Yönetici onayına çekiyoruz.
      MODIFY zncprh_t009 FROM ls_t009.
      COMMIT WORK AND WAIT.
    ELSE.
      add_return 'E' 'ZNCPRH_MC001' '192' space space space space.
    ENDIF.

    modify_return( CHANGING t_return = rt_return ).
  ENDMETHOD.
ENDCLASS.
