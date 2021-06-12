FUNCTION ZNCPRH_FG005_003.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(EV_RESULT) TYPE  FLAG
*"  TABLES
*"      DATA STRUCTURE  ZNCPRH_S033 OPTIONAL
*"----------------------------------------------------------------------


  DATA : lt_data TYPE TABLE OF zncprh_t007,
         ls_data TYPE zncprh_t007.

  LOOP AT data[] ASSIGNING FIELD-SYMBOL(<fs_data>).
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


  MODIFY zncprh_t007 FROM TABLE lt_data[].
  COMMIT WORK.

  IF sy-subrc EQ 0.
    ev_result = 'X'.
  ENDIF.

ENDFUNCTION.
