FUNCTION zncprh_fg005_001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_DATA) TYPE  ZNCPRH_S033 OPTIONAL
*"  EXPORTING
*"     VALUE(ES_DATA) TYPE  ZNCPRH_S034
*"----------------------------------------------------------------------



  DATA : ls_data TYPE zncprh_t007.
  IF im_data IS NOT INITIAL.

    MOVE-CORRESPONDING im_data TO ls_data.
    CLEAR ls_data-proid.
    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_INPUT'
      EXPORTING
        input     = im_data-proid
      IMPORTING
        output    = ls_data-proid
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    INSERT zncprh_t007 FROM ls_data.

    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING im_data TO es_data.
      es_data-statu = 'Basarili'.
    ELSE.
      MOVE-CORRESPONDING im_data TO es_data.
      es_data-statu = 'Basarisiz'.
    ENDIF.

    COMMIT WORK AND WAIT.
  ENDIF.
ENDFUNCTION.
