FUNCTION zncprh_fg001_002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"----------------------------------------------------------------------

  DATA : lt_fld TYPE  TABLE OF dynpread,
         ls_fld TYPE dynpread,
         ls_rec TYPE seahlpres.

  IF callcontrol-step EQ 'RETURN'.
    ls_rec = record_tab[ 1 ].
    IF sy-subrc EQ 0.
      APPEND VALUE #( fieldname  = 'P_CTYFR'
                      fieldvalue = ls_rec-string+7(20) ) TO lt_fld.
      APPEND VALUE #( fieldname  = 'P_CTYTO'
                      fieldvalue = ls_rec-string+27(20) ) TO lt_fld.
      CALL FUNCTION 'DYNP_UPDATE_FIELDS'
        EXPORTING
          dyname               = sy-cprog
          dynumb               = '1000'
          request              = 'A'
        TABLES
          dynpfields           = lt_fld
        EXCEPTIONS
          invalid_abapworkarea = 1
          invalid_dynprofield  = 2
          invalid_dynproname   = 3
          invalid_dynpronummer = 4
          invalid_request      = 5
          no_fielddescription  = 6
          undefind_error       = 7
          OTHERS               = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.
  ENDIF.



ENDFUNCTION.
