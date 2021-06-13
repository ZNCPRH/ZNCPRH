FUNCTION zncprh_fg001_006.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_ROTP) TYPE  CHAR10 OPTIONAL
*"     REFERENCE(I_OBJECT) DEFAULT '*'
*"  EXPORTING
*"     REFERENCE(SVALUE)
*"----------------------------------------------------------------------

  DATA : lv_viewname  LIKE  dd25l-viewname.
  DATA : lv_tcode     LIKE  tstc-tcode.
  DATA : lv_name      LIKE  trdir-name.
  DATA : lv_id        LIKE  euobj-id.


  IF i_rotp EQ 'VIEWDATA'."VIEW
    lv_viewname = i_object.
    CALL FUNCTION 'F4_DD_VIEW'
      EXPORTING
        object = lv_viewname
      IMPORTING
        result = lv_viewname.
    svalue = lv_viewname .
  ELSEIF i_rotp EQ 'TSTC'. "TCODE
    lv_tcode = i_object.
    CALL FUNCTION 'F4_TRANSACTION'
      EXPORTING
        object = lv_tcode
      IMPORTING
        result = lv_tcode.
    svalue = lv_tcode.
  ELSEIF i_rotp EQ 'REPORT'. "RAPOR
    lv_name = i_object.
    CALL FUNCTION 'F4_REPORT'
      EXPORTING
        object = lv_name
      IMPORTING
        result = lv_name.
    svalue = lv_name.
  ELSEIF i_rotp EQ 'W'. "WEB APP
    CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
      EXPORTING
        object_type          = 'WDYD'
        object_name          = i_object
      IMPORTING
        object_name_selected = svalue
      EXCEPTIONS
        cancel               = 1
        wrong_type           = 2
        OTHERS               = 3.
  ELSEIF i_rotp EQ 'B'. "BSP
    CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
      EXPORTING
        object_type          = 'WAPD'
        object_name          = i_object
      IMPORTING
        object_name_selected = svalue
      EXCEPTIONS
        cancel               = 1
        wrong_type           = 2
        OTHERS               = 3.
  ENDIF.



ENDFUNCTION.
