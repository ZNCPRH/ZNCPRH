FUNCTION zncprh_fg001_003.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_ARC) TYPE  SAEARCHIVI OPTIONAL
*"     VALUE(I_DOC_ID) TYPE  SAEARDOID OPTIONAL
*"     VALUE(I_TYPE) TYPE  SAERESERVE OPTIONAL
*"  EXPORTING
*"     VALUE(E_DATA) TYPE  STRING
*"     VALUE(E_BINARY) TYPE  ZNCPRH_DE025
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"     VALUE(E_LENGTH) TYPE  NUM12
*"----------------------------------------------------------------------


  DATA :
    lt_binary  TYPE tabl1024_t,
    lv_len     TYPE sapb-length,
    lv_bin     TYPE sapb-length,
    lt_archive TYPE STANDARD TABLE OF  docs WITH DEFAULT KEY,
    lv_xstring TYPE xstring.


  CALL FUNCTION 'ARCHIVOBJECT_GET_TABLE'
    EXPORTING
      archiv_id                = i_arc
      document_type            = CONV saedoktyp( i_type )
      archiv_doc_id            = i_doc_id
*     ALL_COMPONENTS           =
*     SIGNATURE                = 'X'
*     COMPID                   = 'data'
    IMPORTING
      length                   = lv_len
      binlength                = lv_bin
    TABLES
      archivobject             = lt_archive
      binarchivobject          = lt_binary
    EXCEPTIONS
      error_archiv             = 1
      error_communicationtable = 2
      error_kernel             = 3
      OTHERS                   = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    et_return = VALUE #( ( type = 'E' message = 'Döküman arşivde bulunamadı !' ) ).
    RETURN.
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = CONV i( lv_bin )
*     FIRST_LINE   = 0
*     LAST_LINE    = 0
    IMPORTING
      buffer       = lv_xstring
    TABLES
      binary_tab   = lt_binary
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
    et_return = VALUE #( ( type = 'E' message = 'Döküman veri dönüşümü sağlanamadı !' ) ).
    RETURN.
  ELSE.
    e_binary = lv_xstring.
  ENDIF.

  CALL FUNCTION 'SSFC_BASE64_ENCODE'
    EXPORTING
      bindata                  = lv_xstring
      binleng                  = CONV i( lv_bin )
    IMPORTING
      b64data                  = e_data
    EXCEPTIONS
      ssf_krn_error            = 1
      ssf_krn_noop             = 2
      ssf_krn_nomemory         = 3
      ssf_krn_opinv            = 4
      ssf_krn_input_data_error = 5
      ssf_krn_invalid_par      = 6
      ssf_krn_invalid_parlen   = 7
      OTHERS                   = 8.

  IF sy-subrc <> 0.
* Implement suitable error handling here
    et_return = VALUE #( ( type = 'E' message = 'Döküman veri dönüşümü sağlanamadı !' ) ).
    RETURN.
  ENDIF.

  et_return = VALUE #( ( type = 'S' message = 'Döküman başarıyla getirildi.' ) ).
  e_length = CONV i( lv_bin ).

ENDFUNCTION.
