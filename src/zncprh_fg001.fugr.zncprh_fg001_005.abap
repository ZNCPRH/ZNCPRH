FUNCTION zncprh_fg001_005.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_RAWSTRING) TYPE  FPCONTENT
*"----------------------------------------------------------------------

  DATA: lv_fm_name      TYPE   rs38l_fnam,
        fp_docparams    TYPE   sfpdocparams,
        fp_outputform   TYPE   fpformoutput,
        fp_outputparams TYPE   sfpoutputparams,
        i_name          TYPE   fpname,
        ls_close        TYPE   sfpjoboutput,
        lv_usrty        TYPE   rspopname. "lp01 vs

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = '/DSL/HLAF001' "ADOBEFORMS ADI
    IMPORTING
      e_funcname = lv_fm_name.

  fp_outputparams-nodialog = 'X'.
  fp_outputparams-getpdf   = 'X'.
  fp_outputparams-dest     = lv_usrty."lp01 vs

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = fp_outputparams     " Form Processing Output Parameter
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.

  CLEAR sy-cprog .

  fp_docparams-langu       = sy-langu.
  fp_docparams-country     = 'TR'.
  fp_outputparams-nodialog = 'X'.
  fp_outputparams-preview  = ''.
  fp_outputparams-getpdf   = 'X'.

  CALL FUNCTION lv_fm_name
    EXPORTING
      /1bcdwb/docparams  = fp_docparams
*     mtur               = i_mtur "form importları
*     hlid               = i_hlid "form importları
    IMPORTING
      /1bcdwb/formoutput = fp_outputform
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
  IF sy-subrc EQ 0.
    e_rawstring = fp_outputform-pdf.
  ENDIF.

  CALL FUNCTION 'FP_JOB_CLOSE'
    IMPORTING
      e_result       = ls_close
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.
ENDFUNCTION.
