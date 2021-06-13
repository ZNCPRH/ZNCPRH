*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P056_I002
*&---------------------------------------------------------------------*
CLASS gc_main DEFINITION .
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_toahr,
             object_id  TYPE  char50,
             arc_doc_id TYPE  saeardoid,
             ar_date    TYPE  saeabadate,
             reserve    TYPE  saereserve,
           END OF ty_toahr.

    TYPES: BEGIN OF ty_archiv_info,
             archiv_id TYPE            saearchivi,
             doc_type  TYPE            saedoktyp,
             sapobj    TYPE            saeanwdid,
           END OF ty_archiv_info.

    TYPES : BEGIN OF ty_070,
              pernr TYPE persno,
              imgtp TYPE zncprh_de026,
              datum TYPE datum,
            END OF ty_070.




    DATA: gt_toahr_orj TYPE TABLE OF ty_toahr     WITH NON-UNIQUE KEY object_id  ar_date,
          gt_t070_orj  TYPE TABLE OF ty_070,
          "WITH NON-UNIQUE KEY pernr      imgtp,
          "   WITH NON-UNIQUE KEY PERNR      imgtp,
          gt_t070_rsz  TYPE TABLE OF ty_070.
    "WITH NON-UNIQUE KEY pernr      imgtp.
    " WITH NON-UNIQUE KEY PERNR      imgtp datum.

    DATA: gs_archiv_info TYPE        ty_archiv_info.

    METHODS: init           ,
      at_sel_scr     ,
      get_image      ,
      set_image      ,
*             get_archiv_info,
      set_org_image_process   IMPORTING VALUE(iv_arc_doc_id) TYPE saeardoid
                                        VALUE(iv_doctype)    TYPE any
                              RETURNING VALUE(ev_xstring)    TYPE xstring ,
      set_org_image_process_1 IMPORTING VALUE(iv_arc_doc_id) TYPE saeardoid
                                        VALUE(iv_doctype)    TYPE any
                              RETURNING VALUE(ev_xstring)    TYPE xstring ,
      set_rsz_image_process   IMPORTING VALUE(iv_xstring) TYPE xstring
                              RETURNING VALUE(ev_xstring) TYPE xstring ,
      xstring_to_base64       IMPORTING VALUE(iv_xstring) TYPE xstring
                              RETURNING VALUE(ev_base64)  TYPE zncprh_de027.

ENDCLASS.                    "gc_main DEFINITION

CLASS gc_main IMPLEMENTATION.
  METHOD init.
    gv_sapobject = 'PREL'.
    gv_archiv_id = 'A2'.
    gv_ar_object = 'HRICOLFOTO'.
  ENDMETHOD.                    "init
  METHOD at_sel_scr.
    SELECT SINGLE COUNT(*) FROM zncprh_t013.
    IF sy-subrc NE 0.
      LOOP AT SCREEN.
        IF screen-name CP '*P_ARDAT*'.
          screen-invisible = 1.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.                    "at_sel_scr
  METHOD get_image .
    DATA: lr_pernr   TYPE RANGE OF saeobjid,
          lr_s_pernr LIKE LINE OF  lr_pernr.

*-  Ranges Data Preparing
    LOOP AT s_pernr[] INTO s_pernr.
      lr_s_pernr-sign   = s_pernr-sign.
      CASE s_pernr-option.
        WHEN 'BT'.
          lr_s_pernr-option  = 'BT'.
          lr_s_pernr-low     = s_pernr-low  && '*'.
          lr_s_pernr-high    = s_pernr-high && '*'.
        WHEN 'EQ'.
          lr_s_pernr-option  = 'CP'.
          lr_s_pernr-low     = s_pernr-low  && '*'.
      ENDCASE.

      APPEND lr_s_pernr TO lr_pernr.
      CLEAR lr_s_pernr.
    ENDLOOP.

*-
    SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_t070_orj
      FROM zncprh_t013
       WHERE  pernr IN lr_pernr AND
              imgtp EQ gc_orj.
*-

    IF p_ardat IS INITIAL."Tabloya ilk kez kayıt atıldığında.
*    IF gt_t070_orj[] IS INITIAL."Tabloya ilk kez kayıt atıldığında.
      SELECT object_id arc_doc_id ar_date reserve
       FROM toahr AS to
           INTO TABLE gt_toahr_orj
              WHERE sap_object EQ gv_sapobject
                AND archiv_id  EQ gv_archiv_id
                AND ar_object  EQ gv_ar_object
                AND object_id  IN lr_pernr
                AND ar_date    EQ (
                      SELECT MAX( ar_date ) FROM toahr WHERE sap_object EQ gv_sapobject
                                                         AND archiv_id  EQ gv_archiv_id
                                                         AND object_id  EQ to~object_id
                                                         AND ar_object  EQ gv_ar_object
                                                          ).
    ELSE."Tabloda kayıt varken

      SELECT object_id arc_doc_id ar_date reserve
      FROM toahr
          INTO TABLE gt_toahr_orj
             WHERE sap_object EQ gv_sapobject
               AND archiv_id  EQ gv_archiv_id
               AND ar_object  EQ gv_ar_object
               AND object_id  IN lr_pernr
               AND ar_date    GE p_ardat.
    ENDIF.

  ENDMETHOD.                    "get_slc_orj
  METHOD set_image.
    DATA: lt_t070 TYPE TABLE OF    zncprh_t013 WITH DEFAULT KEY,
          ls_t070 TYPE             zncprh_t013.
    DATA: ls_t070_orj    TYPE             ty_070,
          lv_xstr_orj    TYPE             xstring,
          lv_xstr_rsz    TYPE             xstring,
          lv_p_photo_mth.
    DATA lv_lines TYPE i.
    DATA lv_slace TYPE i.
    DATA lv_text  TYPE char120.
    FIELD-SYMBOLS <fs_orj> TYPE ty_toahr.


    CHECK gt_toahr_orj IS NOT INITIAL.

    SORT gt_t070_orj BY pernr.
    DESCRIBE TABLE gt_toahr_orj LINES lv_lines.


    LOOP AT gt_toahr_orj ASSIGNING <fs_orj>.
      CLEAR ls_t070_orj.
      lv_slace = ( 100 * sy-tabix ) / lv_lines .
      lv_text = '%' && lv_slace && '-' &&
                <fs_orj>-object_id && '-' && sy-tabix && '-'
                && lv_lines.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = lv_slace
          text       = lv_text.
      READ TABLE gt_t070_orj INTO ls_t070_orj
                  WITH KEY pernr = <fs_orj>-object_id BINARY SEARCH.
*                                 imgtp = gc_orj .
*                           datum = <fs_orj>-ar_date.
      IF sy-subrc NE 0
        OR <fs_orj>-ar_date GT ls_t070_orj-datum.
        CLEAR: lv_xstr_orj , lv_xstr_rsz.
        IF lv_p_photo_mth EQ '1'.
          lv_xstr_orj = set_org_image_process_1( iv_arc_doc_id = <fs_orj>-arc_doc_id
                                             iv_doctype    = <fs_orj>-reserve ).
        ELSE .
          lv_xstr_orj = set_org_image_process( iv_arc_doc_id = <fs_orj>-arc_doc_id
                                             iv_doctype    = <fs_orj>-reserve ).
        ENDIF.

        MOVE: <fs_orj>-ar_date                 TO ls_t070-datum,
              <fs_orj>-object_id               TO ls_t070-pernr,
              gc_orj                           TO ls_t070-imgtp,
              xstring_to_base64( lv_xstr_orj ) TO ls_t070-bin64.
        APPEND ls_t070 TO lt_t070.
        CLEAR ls_t070.

        lv_xstr_rsz = set_rsz_image_process( lv_xstr_orj ).
        MOVE: <fs_orj>-ar_date                  TO ls_t070-datum,
              <fs_orj>-object_id                TO ls_t070-pernr,
              gc_rsz                            TO ls_t070-imgtp,
              xstring_to_base64( lv_xstr_rsz )  TO ls_t070-bin64.
        APPEND ls_t070 TO lt_t070.
        CLEAR ls_t070.

      ENDIF.
    ENDLOOP.


    IF lt_t070 IS NOT INITIAL.
      MODIFY zncprh_t013 FROM TABLE lt_t070.
      COMMIT WORK AND WAIT .

    ELSE.

    ENDIF.
  ENDMETHOD.

  METHOD set_org_image_process.
    DATA: lt_bindata       TYPE TABLE OF   tbl1024,
          ls_bindata       TYPE            tbl1024,
          lv_archiv_doc_id TYPE            saeardoid,
          lv_doctype       TYPE            saedoktyp.

    lv_archiv_doc_id = iv_arc_doc_id.
    lv_doctype       = iv_doctype.

    CALL FUNCTION 'ARCHIVOBJECT_GET_BYTES'
      EXPORTING
        archiv_id                = gv_archiv_id
        archiv_doc_id            = lv_archiv_doc_id
        document_type            = lv_doctype
        length                   = 0
        offset                   = 0
      TABLES
        binarchivobject          = lt_bindata
      EXCEPTIONS
        error_archiv             = 1
        error_communicationtable = 2
        error_kernel             = 3
        OTHERS                   = 4.

    CHECK lt_bindata IS NOT INITIAL.
    LOOP AT lt_bindata INTO ls_bindata.
      CONCATENATE ev_xstring ls_bindata-line INTO ev_xstring IN BYTE MODE.
    ENDLOOP.
  ENDMETHOD.                    "set_org_image
  METHOD set_org_image_process_1.
    DATA: lt_bindata       TYPE TABLE OF   tbl1024,
          ls_bindata       TYPE            sdokcntbin,
          lv_archiv_doc_id TYPE            saeardoid,
          lv_doctype       TYPE            saedoktyp.
    DATA : lt_arc          TYPE TABLE OF bapitoav0,
           wa_arc          LIKE LINE OF lt_arc,
           lt_return       TYPE TABLE OF    bapireturn,
           lt_content_info TYPE TABLE OF scms_acinf,
           lv_file_info    LIKE LINE OF lt_content_info,
           lt_content_txt  TYPE TABLE OF sdokcntasc,
           lt_content_bin  TYPE TABLE OF sdokcntbin,
           l_fl            TYPE i,
           l_ll            TYPE i,
           l_fs            TYPE i.

    lv_archiv_doc_id = iv_arc_doc_id.
    lv_doctype       = iv_doctype.
*-
    CALL FUNCTION 'SCMS_R3DB_IMPORT'
      EXPORTING
        mandt        = sy-mandt
        crep_id      = 'Z2'
        doc_id       = lv_archiv_doc_id
      TABLES
        content_info = lt_content_info
        content_txt  = lt_content_txt
        content_bin  = lt_content_bin
      EXCEPTIONS
        error_import = 1
        error_config = 2
        OTHERS       = 3.
    CHECK lt_content_bin IS NOT INITIAL.
    LOOP AT lt_content_bin INTO ls_bindata.
      CONCATENATE ev_xstring ls_bindata-line INTO ev_xstring IN BYTE MODE.
    ENDLOOP.
  ENDMETHOD .
  METHOD set_rsz_image_process.
    DATA: lo_image_processor TYPE REF TO cl_fxs_image_processor,
          lv_handle          TYPE        i,
          lv_rsz_data        TYPE        xstring,
          lv_orig_width      TYPE        i,
          lv_orig_height     TYPE        i,
          lv_width           TYPE        i VALUE 360,
          lv_height          TYPE        i VALUE 120.
    CREATE OBJECT lo_image_processor TYPE cl_fxs_image_processor.

    CHECK iv_xstring IS NOT INITIAL.

    lv_handle =  lo_image_processor->add_image( iv_data  = iv_xstring ).

    CALL METHOD lo_image_processor->get_info
      EXPORTING
        iv_handle = lv_handle
      IMPORTING
        ev_xres   = lv_orig_width
        ev_yres   = lv_orig_height.

    lv_width = lv_height * lv_orig_width / lv_orig_height.

    CALL METHOD lo_image_processor->resize
      EXPORTING
        iv_handle = lv_handle
        iv_xres   = lv_width
        iv_yres   = lv_height.

    ev_xstring = lo_image_processor->get_image( lv_handle ).

  ENDMETHOD.                    "set_rsz_image
  METHOD xstring_to_base64.
    CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
      EXPORTING
        input  = iv_xstring
      IMPORTING
        output = ev_base64.
  ENDMETHOD.                    "xstring_to_base64
ENDCLASS.
