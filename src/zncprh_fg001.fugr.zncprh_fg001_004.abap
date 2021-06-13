FUNCTION zncprh_fg001_004.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(E_RAWSTRING) TYPE  FPCONTENT
*"----------------------------------------------------------------------
  DATA: lc_fm_name      TYPE rs38l_fnam,
        ls_control_par  TYPE ssfctrlop,
        ls_job_output   TYPE ssfcrescl,
        lc_file         TYPE string,
        lt_lines        TYPE TABLE OF tline,
        li_pdf_fsize    TYPE i,
        ls_pdf_string_x TYPE xstring,
        ls_pdf          TYPE char80,
        lt_pdf          TYPE TABLE OF char80,
        lv_usrty        TYPE rspopname,
        p_in1           TYPE ssfcompop,
        lv_printer      TYPE rspoptype.     "prnt opt.


  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = '/DSL/HLSF001' "form adı
    IMPORTING
      fm_name            = lc_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  ls_control_par-no_dialog = 'X'.  " no dialog window
  ls_control_par-getotf    = 'X'.
  ls_control_par-langu     = sy-langu.


  SELECT SINGLE patype FROM tsp03 INTO lv_printer
WHERE padest EQ lv_usrty."LP01 VS..

  p_in1-tddest        = lv_usrty.
  p_in1-tdprinter     = lv_printer.
  p_in1-tdnoprev      = 'X'.



  CALL FUNCTION lc_fm_name
    EXPORTING
      output_options     = p_in1
      control_parameters = ls_control_par
*      is_data            = ls_data "formun importları
*      is_data            = ls_data "formun importları
*      is_data            = ls_data "formun importları
*      is_data            = ls_data "formun importları
    IMPORTING
      job_output_info    = ls_job_output
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.


    CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
    IMPORTING
      bin_filesize          = li_pdf_fsize
      bin_file              = ls_pdf_string_x
    TABLES
      otf                   = ls_job_output-otfdata
      lines                 = lt_lines
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      err_bad_otf           = 4
      OTHERS                = 5.

  e_rawstring = ls_pdf_string_x.
ENDFUNCTION.
