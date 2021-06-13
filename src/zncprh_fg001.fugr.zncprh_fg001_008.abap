FUNCTION zncprh_fg001_008.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_ENAME) TYPE  EMNAM OPTIONAL
*"----------------------------------------------------------------------

  DATA: lr_ename  TYPE RANGE OF pa0001-ename,
        lrs_ename LIKE LINE OF  lr_ename,
        lt_emnam  TYPE TABLE OF emnam,
        lv_ename1 TYPE emnam,
        lv_ename2 TYPE emnam,
        lv_ename3 TYPE emnam.

  FIELD-SYMBOLS: <os>       TYPE any,
                 <ot>       TYPE table,
                 <fs_emnam> TYPE emnam.

  DEFINE add_range.
    IF &1 IS NOT INITIAL AND &1 NE '' .
      ASSIGN (&2) TO <os>.
      IF sy-subrc EQ 0 .
        ASSIGN (&3) TO <ot>.
        <os> = 'I'  && &4 && &1.
        APPEND <os> TO <ot>.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.

  lv_ename1 = lv_ename2 = iv_ename.

  IF iv_ename IS NOT INITIAL.

    TRANSLATE :lv_ename1 TO UPPER CASE,
               lv_ename2 TO LOWER CASE.

    lv_ename1 = '*' && lv_ename1 && '*'.

    SPLIT lv_ename2 AT space INTO TABLE lt_emnam.
    CLEAR lv_ename2.

    LOOP AT lt_emnam ASSIGNING <fs_emnam>.
      TRANSLATE <fs_emnam>(1) TO UPPER CASE.
      lv_ename2 = lv_ename2 && | | && <fs_emnam>.
    ENDLOOP.
    CONDENSE lv_ename2.

    lv_ename3 = lv_ename2.
    lv_ename2 = '*' && lv_ename2 && '*'.

    TRANSLATE lv_ename3 TO UPPER CASE.
    lv_ename3 = '*' && lv_ename3 && '*'.
    REPLACE ALL OCCURRENCES OF 'I' IN lv_ename3 WITH 'İ'.
    REPLACE ALL OCCURRENCES OF 'O' IN lv_ename3 WITH 'Ö'.
    REPLACE ALL OCCURRENCES OF 'U' IN lv_ename3 WITH 'Ü'.

  ENDIF.


  add_range : lv_ename1         'LRS_ENAME' 'LR_ENAME' 'CP' ,
              lv_ename2         'LRS_ENAME' 'LR_ENAME' 'CP' ,
              lv_ename3         'LRS_ENAME' 'LR_ENAME' 'CP' .
ENDFUNCTION.
