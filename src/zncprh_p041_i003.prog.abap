*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P041_I003
*&---------------------------------------------------------------------*


CLASS lcl_convert IMPLEMENTATION.
  METHOD html_header.

    DATA :ls_html TYPE string.
    APPEND '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">' TO html_header.
    APPEND '<html xmlns="http://www.w3.org/1999/xhtml">' TO html_header.
    APPEND '<head>' TO html_header.
    APPEND '<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=ISO-8859-1" />' TO html_header.
    ls_html = '<title>' && object_name && '</title>'. "APPEND '<title>SAP Document</title>' TO html_header."Header Field
    APPEND ls_html TO html_header.
    CLEAR ls_html.
    APPEND '<style type="text/css">' TO html_header.
    CASE program_type.
      WHEN 'FMNAM' OR 'FUGR' OR 'CLAS' OR 'PROG' OR 'INCL' OR 'MSCLAS' OR 'XSLT'.
        APPEND '.code{ font-family:"Courier New", Courier, monospace; color:#000; font-size:14px; background-color:#F2F4F7 }' TO html_header.
        APPEND ' .codeComment {font-family:"Courier New", Courier, monospace; color:#0000F0; font-size:14px; background-color:#F2F4F7 }' TO html_header.
        APPEND ' .normalBold{ font-family:Arial, Helvetica, sans-serif; color:#000; font-size:12px; font-weight:800 }' TO html_header.
        APPEND ' .normalBoldLarge{ font-family:Arial, Helvetica, sans-serif; color:#000; font-size:16px; font-weight:800 }' TO html_header.
      WHEN 'DBTAB' OR 'TABTY' OR 'STRUC'.
        APPEND '  th{text-align:left}' TO html_header.
        APPEND '  .cell{' TO html_header.
        APPEND '    font-family:"Courier New", Courier, monospace;' TO html_header.
        APPEND '    color:#000;' TO html_header.
        APPEND '    font-size:12px;' TO html_header.
        APPEND '    background-color:#F2F4F7;' TO html_header.
        APPEND '  }' TO html_header.
        APPEND '  .cell td { border: thin solid #ccc; }' TO html_header.
    ENDCASE.
    APPEND '</style>' TO html_header.
    APPEND '<style type="text/css">' TO html_header.
    APPEND '  .normal{ font-family:Arial, Helvetica, sans-serif; color:#000; font-size:12px }' TO html_header.
    APPEND '  .footer{ font-family:Arial, Helvetica, sans-serif; color:#000; font-size:12px; text-align: center }' TO html_header.
    APPEND ' h2{ font-family:Arial, Helvetica, sans-serif; color:#000; font-size:16px; font-weight:800 }' TO html_header.
    APPEND ' h3{ font-family:Arial, Helvetica, sans-serif; color:#000; font-size:14px; font-weight:800 }' TO html_header.
    APPEND '  .outerTable{' TO html_header.
    APPEND '   background-color:#00B3FF;' TO html_header.
    APPEND '   width:100%;' TO html_header.
    APPEND '   border-top-width: thin;' TO html_header.
    APPEND '   border-right-width: thin;' TO html_header.
    APPEND '   border-bottom-width: thin;' TO html_header.
    APPEND '   border-left-width: thin;' TO html_header.
    APPEND '   border-top-style: solid;' TO html_header.
    APPEND '   border-right-style: solid;' TO html_header.
    APPEND '   border-bottom-style: solid;' TO html_header.
    APPEND '   border-left-style: solid;' TO html_header.
    APPEND ' }' TO html_header.
    APPEND '  .innerTable{' TO html_header.
    APPEND '   background-color:#90B5FF;' TO html_header.
    APPEND '   width:100%;' TO html_header.
    APPEND '   border-top-width: thin;' TO html_header.
    APPEND '   border-right-width: thin;' TO html_header.
    APPEND '   border-bottom-width: thin;' TO html_header.
    APPEND '   border-left-width: thin;' TO html_header.
    APPEND '   border-top-style: solid;' TO html_header.
    APPEND '   border-right-style: solid;' TO html_header.
    APPEND '   border-bottom-style: solid;' TO html_header.
    APPEND '   border-left-style: solid;' TO html_header.
    APPEND ' }' TO html_header.
    APPEND '</style>' TO html_header.
    APPEND '</head>' TO html_header.
    APPEND '<body>' TO html_header.
    APPEND '<table class="outerTable">' TO html_header.
    APPEND ' <tr class="normalBoldLarge">' TO html_header.
    CASE program_type.
      WHEN 'FMNAM'.
        ls_html = '  <td><h2>Function Module :' && object_name && '</h2>'.
      WHEN 'FUGR'.
        ls_html = '  <td><h2>Function Group :' && object_name && '</h2>'.
      WHEN 'CLAS'.
        ls_html = '  <td><h2>Global Class :' && object_name && '</h2>'.
      WHEN 'PROG'.
        ls_html = '  <td><h2>Program :' && object_name && '</h2>'.
      WHEN 'INCL'.
        ls_html = '  <td><h2>Include Program :' && object_name && '</h2>'.
      WHEN 'MSCLAS'.
        ls_html = '  <td><h2>Message Class :' && object_name && '</h2>'.
      WHEN 'XSLT'.
        ls_html = '  <td><h2>Transformation :' && object_name && '</h2>'.
      WHEN 'DBTAB'.
        ls_html = '  <td><h2>Database Table/Structure :' && object_name && '</h2>'.
      WHEN 'TABTY'.
        ls_html = '  <td><h2>Table Type :' && object_name && '</h2>'.
      WHEN 'STRUC'.
        ls_html = '  <td><h2>Structure :' && object_name && '</h2>'.
    ENDCASE.
    APPEND ls_html TO html_header.
    CLEAR ls_html.
*    APPEND '  <td><h2>Code listing Document</h2>' TO html_header.
*    APPEND '<h3> Description: ' TO html_header.
    APPEND '   </tr>' TO html_header.
    APPEND '  <tr>' TO html_header.
    APPEND '     <td>' TO html_header.
    APPEND '<table class="innerTable">' TO html_header.

  ENDMETHOD.                    "html_header

  METHOD html_footer.

    DATA : lv_footer TYPE string,
           lv_datum  TYPE char10.
    WRITE sy-datum TO lv_datum.
    APPEND `          </td>` TO html_footer.
    APPEND `        </tr>` TO html_footer.
    APPEND `      </table>` TO html_footer.
    APPEND `      </td>` TO html_footer.
    APPEND `      </tr>` TO html_footer.
    APPEND `   <tr>` TO html_footer.
    CONCATENATE '<td class="footer">' sy-datum INTO lv_footer.
    APPEND lv_footer TO html_footer.
    APPEND `   </tr>` TO html_footer.
    APPEND '`</table>`' TO html_footer.
    APPEND '</body>' TO html_footer.
    APPEND '</html>' TO html_footer.

  ENDMETHOD.                    "html_footer

  METHOD html_prog_body.


    DATA : lt_html        TYPE ty_html,
           ls_html        TYPE string,
           ls_source      TYPE recastring,
           lv_tabix       TYPE sytabix,
           lv_html_tabix  TYPE sytabix,
           lv_commentmode TYPE abap_bool VALUE 'X',
           lv_br          TYPE string.


    CLEAR : lt_html.

    me->html_header(
      EXPORTING
        object_name  = program_name
        program_type = program_type
      IMPORTING
        html_header = lt_html ).

    APPEND '       <tr>' TO lt_html.
    APPEND '          <td>' TO lt_html.


    LOOP AT source_code-source_code INTO ls_source.
      lv_tabix = sy-tabix.
      IF ls_source IS NOT INITIAL.

        IF ls_source+0(1) NE '*'."Satır Commentlenmediyse
          IF lv_tabix EQ 1.
            APPEND `   <div class="code">` TO lt_html.
            lv_commentmode = space.
          ELSE.
            IF lv_commentmode = 'X'.
              APPEND `   </div>` TO lt_html.
              lv_commentmode = space.
              APPEND `   <div class="code">` TO lt_html.
            ENDIF.
          ENDIF.

        ELSE. "Satır Commentlendiyse
          IF ls_source+0(1) EQ '*'.
            IF lv_tabix = 1.
              APPEND `   <div class="codeComment">` TO lt_html.
              lv_commentmode = 'X'.
            ELSE.
              IF lv_commentmode = space.
                APPEND '<br />' TO lt_html.
                APPEND `   </div>` TO lt_html.
                APPEND '   <div class="codeComment">' TO lt_html.
                lv_commentmode = 'X'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

*        IF lv_commentmode = 'X'."Boşlukları Dönüştür
*          IF ls_source+0(1) EQ space.
        WHILE ls_source CS ' '.
          REPLACE space WITH '&nbsp;' INTO ls_source.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
        ENDWHILE.
*          ENDIF.
*        ENDIF.
        lv_br = ls_source && '</br>'.
        APPEND lv_br TO lt_html.

      ELSE.
        APPEND '' TO lt_html.

      ENDIF.
      CLEAR ls_source.
    ENDLOOP.

    APPEND `            </div>` TO lt_html.

    me->html_footer(
  CHANGING
    html_footer = lt_html ).

    me->convert_solix(
      EXPORTING
        html_table = lt_html
      IMPORTING
        solix_tab  = solix_tab  ).



  ENDMETHOD.                    "html_body

  METHOD html_dbtab_body.

    DATA : lt_html  TYPE STANDARD TABLE OF string,
           ls_html  TYPE string,
           ls_dd03p TYPE dd03p,
           lv_tabix TYPE sytabix.

    CLEAR : lt_html.

    me->html_header(
  EXPORTING
    object_name  = table_name
    program_type = table_type
  IMPORTING
    html_header = lt_html ).


    APPEND '<tr>' TO lt_html.
    APPEND '  <th>Row</th>' TO lt_html.
    APPEND '  <th>Field Name</th>' TO lt_html.
    APPEND '  <th>Position</th>' TO lt_html.
    APPEND '  <th>Key</th>' TO lt_html.
    APPEND '  <th>Data element</th>' TO lt_html.
    APPEND '  <th>Domain</th>' TO lt_html.
    APPEND '  <th>Datatype</th>' TO lt_html.
    APPEND '  <th>Domain text</th>' TO lt_html.
    APPEND '</tr>' TO lt_html.

    LOOP AT source_tab INTO ls_dd03p.

      APPEND '<tr class="cell">' TO lt_html.

      lv_tabix = lv_tabix + 1.
      ls_html = '<td>' && lv_tabix && '</td>'.
      APPEND ls_html TO lt_html.
      CLEAR ls_html.

      ls_html = '<td>' && ls_dd03p-fieldname && '</td>'.
      APPEND ls_html TO lt_html.
      CLEAR ls_html.

      ls_html = '<td>' && ls_dd03p-position && '</td>'.
      APPEND ls_html TO lt_html.
      CLEAR ls_html.

      ls_html = '<td>' && ls_dd03p-keyflag && '</td>'.
      APPEND ls_html TO lt_html.
      CLEAR ls_html.

      ls_html = '<td>' && ls_dd03p-rollname && '</td>'.
      APPEND ls_html TO lt_html.
      CLEAR ls_html.

      ls_html = '<td>' && ls_dd03p-domname && '</td>'.
      APPEND ls_html TO lt_html.
      CLEAR ls_html.

      ls_html = '<td>' && ls_dd03p-datatype && '</td>'.
      APPEND ls_html TO lt_html.
      CLEAR ls_html.

      ls_html = '<td>' && ls_dd03p-ddtext && '</td>'.
      APPEND ls_html TO lt_html.
      CLEAR ls_html.

      APPEND '</tr>' TO lt_html.

    ENDLOOP.

    me->html_footer(
      CHANGING
        html_footer = lt_html ).

*    BREAK-POINT.

    me->convert_solix(
      EXPORTING
        html_table = lt_html
      IMPORTING
        solix_tab  = solix_tab ).

  ENDMETHOD.                    "html_dbtab_body

  METHOD html_tabty_body.

    DATA : lt_html  TYPE STANDARD TABLE OF string,
           ls_html  TYPE string,
           ls_dd04l TYPE dd04l.

    me->html_header(
     EXPORTING
      object_name  = table_name
      program_type = table_type
     IMPORTING
      html_header = lt_html ).

    APPEND '<tr>' TO lt_html.
    APPEND '  <th>Row</th>' TO lt_html.
    APPEND '  <th>Name of table type</th>' TO lt_html.
    APPEND '  <th>Last Changed by User</th>' TO lt_html.
    APPEND '  <th>Description</th>' TO lt_html.
    APPEND '</tr>' TO lt_html.

    APPEND '<tr class="cell">' TO lt_html.
    APPEND '<td> 1</td>' TO lt_html.

    ls_html = '<td>' && source_str-typename && '</td>'.
    APPEND ls_html TO lt_html.
    CLEAR ls_html.

    ls_html = '<td>' && source_str-rowtype && '</td>'.
    APPEND ls_html TO lt_html.
    CLEAR ls_html.

    ls_html = '<td>' && source_str-as4user && '</td>'.
    APPEND ls_html TO lt_html.
    CLEAR ls_html.

    ls_html = '<td>' && source_str-ddtext && '</td>'.
    APPEND ls_html TO lt_html.
    CLEAR ls_html.

    me->html_footer(
      CHANGING
        html_footer = lt_html ).

    me->convert_solix(
  EXPORTING
    html_table = lt_html
  IMPORTING
    solix_tab  = solix_tab ).

  ENDMETHOD.                    "html_tabty_body

  METHOD html_xslt_body.

    DATA : lt_html TYPE ty_html,
           ls_html TYPE string,
           ls_xslt TYPE o2pageline.

    me->html_header(
      EXPORTING
        object_name  = xslt_name
        program_type = 'XSLT'
      IMPORTING
        html_header  = lt_html ).

    APPEND '       <tr>' TO lt_html.
    APPEND '      <td>' TO lt_html.
    APPEND '<div class="code">' TO lt_html.

    LOOP AT source_tab INTO ls_xslt.

      IF ls_xslt IS NOT INITIAL.

        WHILE ls_xslt CS ' '.
          REPLACE space WITH '&nbsp;' INTO ls_xslt.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
        ENDWHILE.
        REPLACE ALL OCCURRENCES OF '<' IN ls_xslt WITH '&lt;'.
        REPLACE ALL OCCURRENCES OF '>' IN ls_xslt WITH '&gt;'.
        ls_html = ls_xslt-line && '<br />'.

      ELSE.
        ls_html = '<br />'.
      ENDIF.

      APPEND ls_html TO lt_html.
      CLEAR : ls_html, ls_xslt.
    ENDLOOP.

    APPEND '            </div>' TO lt_html.

    me->html_footer(
        CHANGING
          html_footer = lt_html ).

    me->convert_solix(
      EXPORTING
        html_table = lt_html
      IMPORTING
        solix_tab  = solix_tab ).


  ENDMETHOD.                    "html_xslt_body

  METHOD html_mclas_body.

    DATA : lt_html TYPE STANDARD TABLE OF string,
           ls_html TYPE string,
           ls_t100 TYPE t100.

    me->html_header(
      EXPORTING
        object_name  = mclass_name
        program_type = program_type
      IMPORTING
        html_header  = lt_html ).

    APPEND '       <tr>' TO lt_html.
    APPEND '      <td>' TO lt_html.
    APPEND '<div class="code">' TO lt_html.

    LOOP AT source_tab INTO ls_t100.

      ls_html = ls_t100-msgnr && '&nbsp;' && ls_t100-text && '<br />'.
      APPEND ls_html TO lt_html.
      CLEAR : ls_t100, ls_html.

    ENDLOOP.

    APPEND '            </div>' TO lt_html.

    me->html_footer(
      CHANGING
        html_footer = lt_html ).



    me->convert_solix(
      EXPORTING
        html_table = lt_html
      IMPORTING
        solix_tab  = solix_tab ).


  ENDMETHOD.                    "html_mclas_body

  METHOD convert_solix.
    DATA : lv_string  TYPE string,
           lv_xstring TYPE xstring,
           ls_solix   TYPE solix,
           ls_html    TYPE string.

    LOOP AT html_table INTO ls_html.
      CONCATENATE lv_string ls_html INTO lv_string SEPARATED BY cl_abap_char_utilities=>newline.
      CLEAR ls_html.
    ENDLOOP.

    CALL FUNCTION 'HR_KR_STRING_TO_XSTRING'
      EXPORTING
        codepage_to      = '8300'    " Target code page
        unicode_string   = lv_string    " Unicode string to be converted
*       out_len          =     " Length of xstream string in target code page
      IMPORTING
        xstring_stream   = lv_xstring    " Encoded byte stream in target code page
      EXCEPTIONS
        invalid_codepage = 1
        invalid_string   = 2
        OTHERS           = 3.

    solix_tab = cl_bcs_convert=>xstring_to_solix( lv_xstring ).

  ENDMETHOD.                    "convert_solix

ENDCLASS.                    "lcl_convert IMPLEMENTATION
