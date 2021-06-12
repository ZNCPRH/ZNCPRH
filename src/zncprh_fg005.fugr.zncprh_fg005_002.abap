FUNCTION zncprh_fg005_002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_DATA) TYPE  ZNCPRH_TT033 OPTIONAL
*"----------------------------------------------------------------------


  DATA : lt_data TYPE TABLE OF zncprh_t007,
         ls_data TYPE zncprh_t007.

  LOOP AT it_data  ASSIGNING FIELD-SYMBOL(<fs_data>).
    MOVE-CORRESPONDING <fs_data> TO ls_data.
    CLEAR ls_data-proid.
    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
      EXPORTING
        input     = <fs_data>-proid
      IMPORTING
        output    = ls_data-proid
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
    ENDIF.
    APPEND ls_data TO lt_data.
  ENDLOOP.

  CHECK  lt_data IS NOT INITIAL.
  MODIFY zncprh_t007 FROM  TABLE lt_data.
  COMMIT WORK.


ENDFUNCTION.
