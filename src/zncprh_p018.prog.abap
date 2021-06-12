*&---------------------------------------------------------------------*
*& Report ZNCPRH_P018
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p018.

DATA : gt_receiver TYPE zncprh_tt006,
       gs_receiver LIKE LINE OF gt_receiver.

DATA : gt_p TYPE zncprh_tt007,
       gs_p TYPE zncprh_s007.

DATA : BEGIN OF gs_table,
         t_header  TYPE zncprh_tt009,
         s_header  TYPE zncprh_s009,
         t_content TYPE zncprh_tt010,
         s_content TYPE zncprh_s010,
         t_attach  TYPE zncprh_tt008,
         s_attach  TYPE zncprh_s008,
       END OF gs_table.

"necip reha"
DATA : gv_sender    TYPE ad_smtpadr VALUE 'sap@sap.com'.
DATA : rt_return    TYPE fmfg_t_bapireturn.
DATA : gv_content    TYPE tdobname VALUE 'ZNCPRH_ST001'.
DATA : Gt_att_content_hex TYPE solix_tab .

DATA: BEGIN OF gs_table_par,
        pernr  TYPE persno,
        ename  TYPE emnam,
        ypernr TYPE pernr_d,
        ldate  TYPE char10,
        lgart  TYPE lgart,
        lgtxt  TYPE lgtxt,
        anzhl  TYPE anzhl,
        secim  TYPE ddtext,
      END OF gs_table_par,
      gt_table_par LIKE TABLE OF gs_table_par.

APPEND VALUE #( mtext = 'necip.ertug@detaysoft.com' ) TO gt_receiver.
APPEND VALUE #( pernr = CONV #( 1362 ) ) TO gt_receiver.

APPEND VALUE #( p = 'Parametre1' ) TO gt_p.
APPEND VALUE #( p = 'Parametre2' ) TO gt_p.
APPEND VALUE #( p = 'Parametre3' ) TO gt_p.
APPEND VALUE #( p = 'Parametre4' ) TO gt_p.


LOOP AT gt_table_par INTO gs_table_par.

  gs_table-s_content-val1 = gs_table_par-pernr && '</td>'.
  APPEND gs_table-s_content TO gs_table-t_content.

  gs_table-s_content-val1 = gs_table_par-ename && '</td>'.
  APPEND gs_table-s_content TO gs_table-t_content.

  gs_table-s_content-val1 = gs_table_par-ldate && '</td>'.
  APPEND gs_table-s_content TO gs_table-t_content.

  gs_table-s_content-val1 = gs_table_par-lgart && '</td>'.
  APPEND gs_table-s_content TO gs_table-t_content.

  gs_table-s_content-val1 = gs_table_par-lgtxt && '</td>'.
  APPEND gs_table-s_content TO gs_table-t_content.

  gs_table-s_content-val1 = gs_table_par-anzhl && '</td>'.
  APPEND gs_table-s_content TO gs_table-t_content.

  gs_table-s_content-val1 = gs_table_par-secim && '</td>'.


  gs_table-s_content-finish_line = '</tr>'.
  APPEND gs_table-s_content TO gs_table-t_content.

ENDLOOP.


gs_table-s_header-data  = gs_table-t_content.
gs_table-s_header-count = 1.
APPEND gs_table-s_header TO gs_table-t_header.


PERFORM get_pdf.

gs_table-s_attach-ext    = 'PDF'.
gs_table-s_attach-ftext  = 'EKin ADı'.
gs_table-s_attach-soli[] = gt_att_content_hex[].
APPEND gs_table-s_attach to gs_table-t_attach.



CLEAR rt_return.
CALL METHOD zncprh_cl002=>send_mail_with_image
  EXPORTING
    it_receiver    = gt_receiver
    ip_content     = gv_content
    t_p            = gt_p
    i_sender       = gv_sender
    i_langu        = sy-langu
    it_attachments = gs_table-t_attach
    ptab           = gs_table-t_header
  IMPORTING
    t_return    = rt_return.


*--------------------------------------------------------------------*
FORM get_pdf.
  DATA l_name TYPE  funcname.
  DATA : w_binary TYPE xstring.
  DATA : l_fm_name       TYPE rs38l_fnam,
         l_formname      TYPE fpname,
         fp_docparams    TYPE sfpdocparams,
         fp_formoutput   TYPE fpformoutput,
         fp_outputparams TYPE sfpoutputparams.
  CLEAR:l_fm_name      ,
        l_formname     ,
        fp_docparams   ,
        fp_formoutput  ,
        fp_outputparams.

  DATA : lt_pdf_table TYPE TABLE OF  pa0001.

  l_name = 'ZNCPRH_AF001'.


  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = l_name "'ZSCPF_SM03_N'
    IMPORTING
      e_funcname = l_fm_name.

  fp_outputparams-nodialog  = 'X'.
  fp_outputparams-preview   = 'X'.
  fp_outputparams-getpdf    = 'X'.
  fp_outputparams-device    = 'PRINTER'.
  fp_outputparams-reqimm    = 'X'.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = fp_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.

  fp_docparams-langu =   'X'.
  fp_docparams-country = 'TR'.


  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object       = 'GRAPHICS'
      p_name         = 'LOGONAME'
      p_id           = 'BMAP'
      p_btype        = 'BCOL'
    RECEIVING
      p_bmp          = w_binary
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.


  CALL FUNCTION l_fm_name
    EXPORTING
      /1bcdwb/docparams  = fp_docparams
      it_itab            = lt_pdf_table
      logo               = w_binary
    IMPORTING
      /1bcdwb/formoutput = fp_formoutput
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.

*--
  CLEAR gt_att_content_hex .
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = fp_formoutput-pdf
    TABLES
      binary_tab = gt_att_content_hex.
ENDFORM.
