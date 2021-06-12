*&---------------------------------------------------------------------*
*& Include          ZZP043_I003
*&---------------------------------------------------------------------*

FORM batch_41 USING p_pernr
                    pp_0041 STRUCTURE p0041.

  DATA : lp41 LIKE pa0041 OCCURS 0 WITH HEADER LINE.
  DATA : w41  LIKE p0041.
  DATA: BEGIN OF dat,
          dar LIKE p0041-dar01,
          dat LIKE p0041-dat01,
        END OF dat.
  DATA : txt(30).
  FIELD-SYMBOLS : <l_fs> TYPE any.
  DATA : txt2(30).
  FIELD-SYMBOLS : <l_fs2> TYPE any.
  DATA : txt3(30).
  FIELD-SYMBOLS : <l_fs3> TYPE any.
  DATA : txt4(30).
  FIELD-SYMBOLS : <l_fs4> TYPE any.
  DATA : ok.
  DATA : index2(2).
  DATA : bos(2).
  "gelen veri
  MOVE-CORRESPONDING <wa> TO w41.

  "mevcut veri
  REFRESH lp41.
* 41 bilgi tipi verilerinin alınması ..
  SELECT  * FROM pa0041 INTO CORRESPONDING FIELDS OF TABLE lp41
                                          WHERE pernr = p_pernr.

  LOOP AT lp41. ENDLOOP.

  LOOP AT gt_fcat INTO gs_fcat.
    IF gs_fcat-fieldname+0(3) = 'DAR'.
      CONCATENATE 'W41-DAR' gs_fcat-fieldname+3(2) INTO txt2.
      ASSIGN (txt2) TO <l_fs2>.
      CLEAR ok.
      CLEAR  bos.
      DO 12 TIMES.
        UNPACK sy-index TO index2.
        CONCATENATE 'lp41-DAR' index2 INTO txt.
        ASSIGN (txt) TO <l_fs>.
        IF <l_fs> EQ <l_fs2>.
          CONCATENATE 'lp41-DAT' index2 INTO txt3.
          ASSIGN (txt3) TO <l_fs3>.
          CONCATENATE 'W41-DAT' gs_fcat-fieldname+3(2) INTO txt4.
          ASSIGN (txt4) TO <l_fs4>.
          <l_fs3> = <l_fs4>.
          ok = 'X'.
          EXIT.
        ENDIF.
        IF <l_fs> IS INITIAL AND bos IS INITIAL.
          bos = index2.
        ENDIF.
      ENDDO.
      IF ok IS INITIAL.
        UNASSIGN : <l_fs> , <l_fs2> , <l_fs3> , <l_fs4>.
        CONCATENATE 'lp41-DAT' bos INTO txt.
        ASSIGN (txt) TO <l_fs>.
        CONCATENATE 'lp41-DAR' bos INTO txt2.
        ASSIGN (txt2) TO <l_fs2>.
        CONCATENATE 'W41-DAT' gs_fcat-fieldname+3(2) INTO txt3.
        ASSIGN (txt3) TO <l_fs3>.
        CONCATENATE 'W41-DAR' gs_fcat-fieldname+3(2) INTO txt4.
        ASSIGN (txt4) TO <l_fs4>.
        <l_fs> = <l_fs3>.
        <l_fs2> = <l_fs4>.
      ENDIF.
    ENDIF.
  ENDLOOP.
  MOVE-CORRESPONDING lp41 TO pp_0041.
ENDFORM.                                                    "batch_41

*----------------------------------------------------------------------*
*  MODULE pbo_0100 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE pbo_0100 OUTPUT.
*
  SET PF-STATUS 'GUI' .

ENDMODULE.                 " PBO_0100  OUTPUT

*&---------------------------------------------------------------------*
*& Command / Komut / Tetikleme
*&---------------------------------------------------------------------*
MODULE pai_0100 INPUT.
*
  CASE sy-ucomm          .
    WHEN '&F03' OR '&F15' . LEAVE TO SCREEN 0 .
    WHEN '&F12'           . LEAVE PROGRAM     .
  ENDCASE                .

ENDMODULE.                 " PAI_0100  INPUT

*&---------------------------------------------------------------------*
*& Module  CREATE_CONTAINER  OUTPUT
*& Container oluşturma ..
*&---------------------------------------------------------------------*
MODULE create_container OUTPUT.
  g_object->create_layout( ).
  g_object->alv_initial( ).
ENDMODULE.                    "create_container OUTPUT
