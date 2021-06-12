FUNCTION zncprh_fg003_001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL_NAME) TYPE  TEXT128 DEFAULT ''
*"     REFERENCE(I_EXCEL_SHEET) TYPE  ZNCPRH_TT020 OPTIONAL
*"     REFERENCE(I_EXCEL_COLUMN) TYPE  ZNCPRH_TT021 OPTIONAL
*"     REFERENCE(I_EXCEL_ROW) TYPE  ZNCPRH_TT022 OPTIONAL
*"     REFERENCE(I_EXCEL_DATA) TYPE  ZNCPRH_TT023
*"  EXPORTING
*"     VALUE(E_DOC_TYPE) TYPE  CHAR3
*"     REFERENCE(E_XML_TABLE) TYPE  SOLIX_TAB
*"     REFERENCE(E_XML_SIZE) TYPE  I
*"     REFERENCE(E_RC) TYPE  I
*"----------------------------------------------------------------------



***********************
***** GLOBAL DATA *****
***********************

  DATA: BEGIN OF it_dati OCCURS 0.
          INCLUDE STRUCTURE zncprh_s023.
          DATA   style_id(10) TYPE c.
  DATA  END OF it_dati.

  DATA: s_excel_column TYPE zncprh_s021,
        s_excel_row    TYPE zncprh_s022,
        s_excel_data   TYPE zncprh_s023.

  DATA: l_ixml                TYPE REF TO if_ixml,
        l_document            TYPE REF TO if_ixml_document,
        l_pi_parsed           TYPE REF TO if_ixml_pi_parsed,
        l_element_root        TYPE REF TO if_ixml_element,
        l_stream_factory      TYPE REF TO if_ixml_stream_factory,
        l_ostream             TYPE REF TO if_ixml_ostream,
        l_renderer            TYPE REF TO if_ixml_renderer,
        l_attribute           TYPE REF TO if_ixml_attribute,
        r_documentproperties  TYPE REF TO if_ixml_element,
        r_styles              TYPE REF TO if_ixml_element,
        r_style               TYPE REF TO if_ixml_element,
        r_alignment           TYPE REF TO if_ixml_element,
        r_font                TYPE REF TO if_ixml_element,
        r_interior            TYPE REF TO if_ixml_element,
        r_numberformat        TYPE REF TO if_ixml_element,
        r_borders             TYPE REF TO if_ixml_element,
        r_border              TYPE REF TO if_ixml_element,
        r_locked              TYPE REF TO if_ixml_element,
        r_worksheet           TYPE REF TO if_ixml_element,
        r_table               TYPE REF TO if_ixml_element,
        r_column              TYPE REF TO if_ixml_element,
        r_row                 TYPE REF TO if_ixml_element,
        r_cell                TYPE REF TO if_ixml_element,
        r_data                TYPE REF TO if_ixml_element,
        r_worksheetoptions    TYPE REF TO if_ixml_element,
        r_freezepanes         TYPE REF TO if_ixml_element,
        r_splithorizontal     TYPE REF TO if_ixml_element,
        r_toprowbottompane    TYPE REF TO if_ixml_element,
        r_splitvertical       TYPE REF TO if_ixml_element,
        r_leftcolumnrightpane TYPE REF TO if_ixml_element,
        r_activepane          TYPE REF TO if_ixml_element,
        r_panes               TYPE REF TO if_ixml_element,
        r_pane                TYPE REF TO if_ixml_element,
        r_number              TYPE REF TO if_ixml_element.

  DATA: c_value TYPE char20,
        l_value TYPE string.

  DATA: w_tabix         LIKE sy-tabix,
        w_tabix_ed(10)  TYPE c,
        w_row_nro       TYPE i,
        w_column_nro    TYPE i,
        w_width         LIKE zncprh_s021-width,
        w_len           TYPE i,
        w_linetype(12)  TYPE c,
        w_lineweight(1) TYPE c,
        w_protected(1)  TYPE c,
        ctr_point       TYPE i,
        ctr_comma       TYPE i,
        ctr_sign        TYPE i,
        ctr_characters  TYPE i,  "N.ro caratteri
        old_sheet       TYPE i,
        old_row         TYPE i,
        old_column      TYPE i,
        data_tabix      LIKE sy-tabix,
        data_subrc      LIKE sy-subrc,
        ls_excel_sheet  TYPE zncprh_s020.

  DATA: BEGIN OF it_sheet OCCURS 0,
          sheet_nro    LIKE zncprh_s023-sheet_nro,
          sheet_name   LIKE zncprh_s020-sheet_name,
          top_row      LIKE zncprh_s020-top_row,
          left_column  LIKE zncprh_s020-left_column,
          active_pane  LIKE zncprh_s020-active_pane,
          title_text   TYPE text128,
          row_max      LIKE zncprh_s023-row_nro,
          column_min   LIKE zncprh_s023-column_nro,
          column_max   LIKE zncprh_s023-column_nro,
          protected(1) TYPE c,
        END OF it_sheet.

  DATA: BEGIN OF it_sheet_name OCCURS 0,      " Controllo nomi fogli ripetuti
          sheet_name   LIKE zncprh_s020-sheet_name,
          ctr          TYPE i,
          protected(1) TYPE c,
        END OF it_sheet_name.

  DATA: BEGIN OF it_column OCCURS 0,
          sheet_nro    TYPE i,
          column_nro   TYPE i,
          style_id(10) TYPE c,
          ctr          TYPE i,
          width        LIKE zncprh_s021-width,
        END OF it_column.

  DATA: BEGIN OF it_style OCCURS 0,
          justify       LIKE zncprh_s023-justify,
          bold          LIKE zncprh_s023-bold,
          italic        LIKE zncprh_s023-italic,
          underline     LIKE zncprh_s023-underline,
          numberformat  LIKE zncprh_s023-numberformat,
          border_bottom LIKE zncprh_s023-border_bottom,
          border_left   LIKE zncprh_s023-border_left,
          border_right  LIKE zncprh_s023-border_right,
          border_top    LIKE zncprh_s023-border_top,
          fontname      LIKE zncprh_s023-fontname,
          char_size     LIKE zncprh_s023-char_size,
          char_color    LIKE zncprh_s023-char_color,
          back_color    LIKE zncprh_s023-back_color,
          protected     LIKE zncprh_s023-protected,
          hideformula   LIKE zncprh_s023-hideformula,
          id(10)        TYPE c,
        END OF it_style.

******************************
***** END OF GLOBAL DATA *****
******************************

***********************************************
***** Function module Z_UT_CREA_EXCEL_XML *****
***********************************************

  CLEAR w_protected.

*_ copio i dati in una tabella interna e determino gli stili
  REFRESH it_dati.
  CLEAR it_dati.
  REFRESH it_style.
  CLEAR it_style.
  LOOP AT i_excel_data INTO s_excel_data.
    MOVE-CORRESPONDING s_excel_data TO it_dati.
    IF it_dati-numberformat IS NOT INITIAL.
      SHIFT it_dati-numberformat LEFT DELETING LEADING space.
      TRANSLATE it_dati-numberformat TO UPPER CASE.
      IF it_dati-numberformat = 'TESTO'.
        MOVE 'STRING' TO it_dati-numberformat.
      ENDIF.
    ENDIF.
    IF it_dati-numberformat <> 'STRING'.
      SHIFT it_dati-value LEFT DELETING LEADING space.
    ENDIF.
    IF it_dati-numberformat = 'D'        " Data a zero
    AND it_dati-value = '00000000'.
      CLEAR it_dati-value.
    ELSEIF it_dati-numberformat = 'T'    " Ora a zero
    AND it_dati-value = '000000'.
      CLEAR it_dati-value.
    ENDIF.
    APPEND it_dati.
    MOVE-CORRESPONDING it_dati TO it_style.
    COLLECT it_style.
  ENDLOOP.

  SORT it_style.

*_ aggiungo o attribuisco lo stile di default
  READ TABLE it_style INDEX 1.
  IF sy-subrc = 0
  AND it_style IS INITIAL.
    MOVE 'Default' TO it_style-id.
    MODIFY it_style INDEX 1.
  ELSE.
    CLEAR it_style.
    MOVE 'Default' TO it_style-id.
    INSERT it_style INDEX 1.
  ENDIF.

*_ associo l'id style
  LOOP AT it_style WHERE id IS INITIAL.          " Escludo il default
    WRITE sy-tabix TO w_tabix_ed LEFT-JUSTIFIED.
    CONCATENATE 'S' w_tabix_ed INTO it_style-id.
    MODIFY it_style.
  ENDLOOP.

  SORT it_dati BY sheet_nro row_nro column_nro.

  REFRESH it_sheet.
  CLEAR it_sheet.
  CLEAR: old_sheet,
         old_row,
         old_column.
  REFRESH it_column.
  LOOP AT it_dati.
    IF it_dati-sheet_nro  IS INITIAL
    OR it_dati-row_nro    IS INITIAL
    OR it_dati-column_nro IS INITIAL.
* N.ro sheet, riga o colonna non valorizzati
      MESSAGE e001(zut) RAISING posizione_mancante.
    ENDIF.
    IF  it_dati-sheet_nro  = old_sheet
    AND it_dati-row_nro    = old_row
    AND it_dati-column_nro = old_column.
* Sheet & riga & colonna & - presente più volte.
      MESSAGE e002(zut) WITH it_dati-sheet_nro
                             it_dati-row_nro
                             it_dati-column_nro
            RAISING posizione_ripetuta.
    ELSE.
      MOVE: it_dati-sheet_nro  TO old_sheet
           ,it_dati-row_nro    TO old_row
           ,it_dati-column_nro TO old_column.
    ENDIF.

*_ Determino limiti fogli
    IF it_dati-sheet_nro <> it_sheet-sheet_nro.
      IF it_sheet IS NOT INITIAL.
        APPEND it_sheet.
      ENDIF.
      CLEAR it_sheet.
      MOVE it_dati-sheet_nro TO it_sheet-sheet_nro.
    ENDIF.

    IF it_dati-row_nro > it_sheet-row_max.
      MOVE it_dati-row_nro    TO it_sheet-row_max.
    ENDIF.
    IF it_sheet-column_min IS INITIAL
    OR it_dati-column_nro < it_sheet-column_min.
      MOVE it_dati-column_nro    TO it_sheet-column_min.
    ENDIF.
    IF it_dati-column_nro > it_sheet-column_max.
      MOVE it_dati-column_nro    TO it_sheet-column_max.
    ENDIF.

    IF it_dati-protected IS NOT INITIAL
    OR it_dati-hideformula IS NOT INITIAL.
      MOVE 'X' TO it_sheet-protected.
      MOVE 'X' TO w_protected.
    ENDIF.

*_ Riporto lo style ID nella tabella dati
    READ TABLE it_style WITH KEY justify         = it_dati-justify
                                 bold            = it_dati-bold
                                 italic          = it_dati-italic
                                 underline       = it_dati-underline
                                 numberformat    = it_dati-numberformat
                                 border_bottom   = it_dati-border_bottom
                                 border_left     = it_dati-border_left
                                 border_right    = it_dati-border_right
                                 border_top      = it_dati-border_top
                                 fontname        = it_dati-fontname
                                 char_size       = it_dati-char_size
                                 char_color      = it_dati-char_color
                                 back_color      = it_dati-back_color
                                 protected       = it_dati-protected
                                 hideformula     = it_dati-hideformula
               BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE it_style-id TO it_dati-style_id.
      MODIFY it_dati.
    ENDIF.

*_ Determino la style_id più frequente per foglio/colonna
    IF  it_dati-border_left   IS INITIAL    " Escludo i valori che si
    AND it_dati-border_right  IS INITIAL    " allungano nella colonna
    AND it_dati-border_top    IS INITIAL    " oltre i dati
    AND it_dati-border_bottom IS INITIAL
    AND it_dati-back_color    IS INITIAL.
      READ TABLE it_column WITH KEY sheet_nro  = it_dati-sheet_nro
                                    column_nro = it_dati-column_nro
                                    style_id   = it_dati-style_id
                 BINARY SEARCH.
      IF sy-subrc = 0.
        ADD 1 TO it_column-ctr.
        MODIFY it_column INDEX sy-tabix.
      ELSE.
        CLEAR it_column.
        MOVE it_dati-sheet_nro  TO it_column-sheet_nro.
        MOVE it_dati-column_nro TO it_column-column_nro.
        MOVE it_dati-style_id   TO it_column-style_id.
        MOVE 1 TO it_column-ctr.
        INSERT it_column INDEX sy-tabix.
      ENDIF.
    ENDIF.

  ENDLOOP.
  IF it_sheet IS NOT INITIAL.
    APPEND it_sheet.
  ENDIF.

*_ Assegno i nomi ai fogli (in automatico)
  LOOP AT it_sheet.
    WRITE it_sheet-sheet_nro TO it_sheet-sheet_name LEFT-JUSTIFIED.
    CONCATENATE 'Foglio' it_sheet-sheet_name INTO it_sheet-sheet_name.      " Nome foglio automatico
    MODIFY it_sheet.
  ENDLOOP.

*_ Sostituisco i dati del foglio con quanto passato dal programma
  LOOP AT i_excel_sheet INTO ls_excel_sheet.
    READ TABLE it_sheet WITH KEY sheet_nro = ls_excel_sheet-sheet_nro
         BINARY SEARCH.
    IF sy-subrc = 0.
      IF ls_excel_sheet-sheet_name IS NOT INITIAL.
        MOVE ls_excel_sheet-sheet_name TO it_sheet-sheet_name.
      ENDIF.
      IF ls_excel_sheet-top_row IS NOT INITIAL.
        MOVE ls_excel_sheet-top_row TO it_sheet-top_row.
      ENDIF.
      IF ls_excel_sheet-left_column IS NOT INITIAL.
        MOVE ls_excel_sheet-left_column TO it_sheet-left_column.
      ENDIF.
      IF ls_excel_sheet-active_pane IS NOT INITIAL.
        MOVE ls_excel_sheet-active_pane TO it_sheet-active_pane.
      ENDIF.
      IF ls_excel_sheet-title_text IS NOT INITIAL.
        MOVE ls_excel_sheet-title_text TO it_sheet-title_text.
        ADD 1 TO it_sheet-row_max.
      ENDIF.
      MODIFY it_sheet INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

*_ Verifico se ho fogli con lo stesso nome, se si li modifico
  REFRESH it_sheet_name.
  LOOP AT it_sheet.
    READ TABLE it_sheet_name WITH KEY sheet_name = it_sheet-sheet_name
      BINARY SEARCH.
    IF sy-subrc = 0.
      ADD 1 TO it_sheet_name-ctr.
      MODIFY it_sheet_name INDEX sy-tabix.
      w_len = strlen( it_sheet-sheet_name ) .
      IF it_sheet_name-ctr < 10.
        IF w_len > 27.
          MOVE 27 TO w_len.
        ENDIF.
      ELSEIF it_sheet_name-ctr < 100.
        IF w_len > 26.
          MOVE 26 TO w_len.
        ENDIF.
      ELSE.
        IF w_len > 25.
          MOVE 25 TO w_len.
        ENDIF.
      ENDIF.
      WRITE it_sheet_name-ctr TO c_value LEFT-JUSTIFIED.
      CONCATENATE it_sheet-sheet_name(w_len) '(' c_value ')'
            INTO it_sheet-sheet_name.
      MODIFY it_sheet.
    ELSE.
      MOVE it_sheet-sheet_name TO it_sheet_name-sheet_name.
      CLEAR it_sheet_name-ctr.
      INSERT it_sheet_name INDEX sy-tabix.
    ENDIF.
    MOVE sy-tabix TO w_tabix.
  ENDLOOP.


*_ Mantengo solo lo style più ricorrente per colonna
  SORT it_column BY sheet_nro column_nro ctr DESCENDING.
  LOOP AT it_column.
    AT NEW column_nro.
      MOVE sy-tabix TO w_tabix.
    ENDAT.
    IF sy-tabix <> w_tabix.
      DELETE it_column INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

*_ Determino la larghezza della colonna
  LOOP AT it_dati.
    ctr_characters = strlen( it_dati-value ).
    IF ctr_characters < 5.        " Se ho pochi caratteri aumento (di poco) la larghezza
      ADD 2 TO ctr_characters.
    ELSEIF ctr_characters > 100.  " Se ho troppi caratteri riduco la larghezza
      MOVE 100 TO ctr_characters.
    ENDIF.
    IF it_dati-char_size IS INITIAL.
      w_width = ctr_characters * '6.35'.
    ELSE.
      w_width = ctr_characters * '6.35' * it_dati-char_size / 10.
    ENDIF.
    READ TABLE it_column WITH KEY sheet_nro  = it_dati-sheet_nro
                                  column_nro = it_dati-column_nro
               BINARY SEARCH.
    IF sy-subrc = 0.
      IF w_width > it_column-width.
        MOVE w_width TO it_column-width.
        MODIFY it_column INDEX sy-tabix.
      ENDIF.
    ELSE.
      CLEAR it_column.
      MOVE: it_dati-sheet_nro  TO it_column-sheet_nro
           ,it_dati-column_nro TO it_column-column_nro
           ,'Default'          TO it_column-style_id
           ,w_width            TO it_column-width.
      INSERT it_column INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

*_ Rimpiazzo la larghezza della colonna con il valore passato dal chiamante
  LOOP AT i_excel_column INTO s_excel_column.
    READ TABLE it_column WITH KEY sheet_nro  = s_excel_column-sheet_nro
                                  column_nro = s_excel_column-column_nro
               BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE s_excel_column-width TO it_column-width.
      MODIFY it_column INDEX sy-tabix.
    ELSE.
      CLEAR it_column.
      MOVE-CORRESPONDING s_excel_column TO it_column.
      MOVE 'Default' TO it_column-style_id.
      INSERT it_column INDEX sy-tabix.
    ENDIF.
  ENDLOOP.


* Creating a ixml Factory
  l_ixml = cl_ixml=>create( ).

* Creating the DOM Object Model
  l_document = l_ixml->create_document( ).

* Aggiunta riferimento al programma per aprire il file (MS Excel)
  l_pi_parsed = l_document->create_pi_parsed( name = 'mso-application' ).
  l_pi_parsed->set_attribute( name = 'progid' value = 'Excel.Sheet').
  l_document->append_child( l_pi_parsed ).

* Create Root Node 'Workbook'
  l_element_root  = l_document->create_simple_element( name = 'Workbook'  parent = l_document ).
  l_element_root->set_attribute( name = 'xmlns'  value = 'urn:schemas-microsoft-com:office:spreadsheet' ).

  l_attribute = l_document->create_namespace_decl( name = 'o'  prefix = 'xmlns'  uri = 'urn:schemas-microsoft-com:office:office' ).
  l_element_root->set_attribute_node( l_attribute ).

  l_attribute = l_document->create_namespace_decl( name = 'x'  prefix = 'xmlns'  uri = 'urn:schemas-microsoft-com:office:excel' ).
  l_element_root->set_attribute_node( l_attribute ).

  l_attribute = l_document->create_namespace_decl( name = 'ss'  prefix = 'xmlns'  uri = 'urn:schemas-microsoft-com:office:spreadsheet' ).
  l_element_root->set_attribute_node( l_attribute ).

* Create node for document properties.
  IF i_excel_name IS NOT INITIAL.
    r_documentproperties = l_document->create_simple_element( name = 'DocumentProperties'  parent = l_element_root  ).
    r_documentproperties->set_attribute( name = 'xmlns'  value = 'urn:schemas-microsoft-com:office:office' ).
    l_value = i_excel_name.
    CONDENSE l_value NO-GAPS.
    l_document->create_simple_element( name = 'Title'  value = l_value  parent = r_documentproperties  ).
    l_value = sy-uname.
    l_document->create_simple_element( name = 'Author'  value = l_value  parent = r_documentproperties  ).
**    CONCATENATE sy-datum(4) '-' sy-datum+4(2) '-' sy-datum+6(2)
**            'T' sy-uzeit(2) ':' sy-uzeit+2(2) ':' sy-uzeit+4(2) 'Z'
**           INTO l_value.
**    l_document->create_simple_element( name = 'Created'  value = l_value  parent = r_documentproperties  ).
  ENDIF.

* Styles
  r_styles = l_document->create_simple_element( name = 'Styles'  parent = l_element_root  ).

  LOOP AT it_style.
    MOVE it_style-id TO l_value.

    r_style  = l_document->create_simple_element( name = 'Style'   parent = r_styles  ).
    r_style->set_attribute_ns( name = 'ID'  prefix = 'ss'  value = l_value ).

    CASE it_style-justify.
      WHEN 'L'.
        r_alignment  = l_document->create_simple_element( name = 'Alignment'  parent = r_style  ).
        r_alignment->set_attribute_ns( name = 'Horizontal'  prefix = 'ss'  value = 'Left' ).
      WHEN 'C'.
        r_alignment  = l_document->create_simple_element( name = 'Alignment'  parent = r_style  ).
        r_alignment->set_attribute_ns( name = 'Horizontal'  prefix = 'ss'  value = 'Center' ).
      WHEN 'R'.
        r_alignment  = l_document->create_simple_element( name = 'Alignment'  parent = r_style  ).
        r_alignment->set_attribute_ns( name = 'Horizontal'  prefix = 'ss'  value = 'Right' ).
      WHEN 'J'.
        r_alignment  = l_document->create_simple_element( name = 'Alignment'  parent = r_style  ).
        r_alignment->set_attribute_ns( name = 'Horizontal'  prefix = 'ss'  value = 'Justify' ).
    ENDCASE.

    IF it_style-bold       IS NOT INITIAL
    OR it_style-italic     IS NOT INITIAL
    OR it_style-underline  IS NOT INITIAL
    OR it_style-fontname   IS NOT INITIAL
    OR it_style-char_size  IS NOT INITIAL
    OR it_style-char_color IS NOT INITIAL.
      r_font  = l_document->create_simple_element( name = 'Font'  parent = r_style  ).
    ENDIF.

    IF it_style-bold IS NOT INITIAL.
      r_font->set_attribute_ns( name = 'Bold'  prefix = 'ss'  value = '1' ).
    ENDIF.
    IF it_style-italic IS NOT INITIAL.
      r_font->set_attribute_ns( name = 'Italic'  prefix = 'ss'  value = '1' ).
    ENDIF.
    IF it_style-underline IS NOT INITIAL.
      r_font->set_attribute_ns( name = 'Underline'  prefix = 'ss'  value = 'Single' ).
    ENDIF.
    IF it_style-fontname IS NOT INITIAL.
      MOVE it_style-fontname TO l_value.
      r_font->set_attribute_ns( name = 'FontName'   prefix = 'ss'  value = l_value ).
    ENDIF.
    IF it_style-char_size IS NOT INITIAL.
      MOVE it_style-char_size TO l_value.
      r_font->set_attribute_ns( name = 'Size'   prefix = 'ss'  value = l_value ).
    ENDIF.
    IF it_style-char_color IS NOT INITIAL.
      CONCATENATE '#' it_style-char_color INTO l_value.
      r_font->set_attribute_ns( name = 'Color'   prefix = 'ss'  value = l_value ).
    ENDIF.

    IF it_style-back_color IS NOT INITIAL.
      CONCATENATE '#' it_style-back_color INTO l_value.
      r_interior = l_document->create_simple_element( name = 'Interior'  parent = r_style  ).
      r_interior->set_attribute_ns( name = 'Color'    prefix = 'ss'  value = l_value ).
      r_interior->set_attribute_ns( name = 'Pattern'  prefix = 'ss'  value = 'Solid' ).
    ENDIF.

    IF it_style-numberformat IS NOT INITIAL.
      r_numberformat = l_document->create_simple_element( name = 'NumberFormat'  parent = r_style  ).
      CASE it_style-numberformat.
        WHEN 'D'.
          r_numberformat->set_attribute_ns( name = 'Format' prefix = 'ss' value = 'Short Date' ).
        WHEN 'T'.
          r_numberformat->set_attribute_ns( name = 'Format' prefix = 'ss' value = '[$-F400]h:mm:ss AM/PM' ).
        WHEN 'V'.
          r_numberformat->set_attribute_ns( name = 'Format'  prefix = 'ss'  value = 'Standard' ).
        WHEN 'STRING'.
          r_numberformat->set_attribute_ns( name = 'Format'  prefix = 'ss'  value = '@' ).
        WHEN OTHERS.
          MOVE it_style-numberformat TO l_value.
          r_numberformat->set_attribute_ns( name = 'Format'  prefix = 'ss'  value = l_value ).
      ENDCASE.
    ENDIF.

    IF it_style-border_bottom IS NOT INITIAL
    OR it_style-border_left   IS NOT INITIAL
    OR it_style-border_right  IS NOT INITIAL
    OR it_style-border_top    IS NOT INITIAL.
      r_borders = l_document->create_simple_element( name = 'Borders'  parent = r_style ).
    ENDIF.
    IF it_style-border_bottom IS NOT INITIAL.
      r_border = l_document->create_simple_element( name = 'Border'   parent = r_borders  ).
      r_border->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Bottom' ).
      PERFORM converti_linestyle USING it_style-border_bottom CHANGING w_linetype w_lineweight.
      MOVE w_linetype TO l_value.
      r_border->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = l_value ).
      IF w_lineweight IS NOT INITIAL.
        MOVE w_lineweight TO l_value.
        r_border->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = l_value ).
      ENDIF.
    ENDIF.
    IF it_style-border_left IS NOT INITIAL.
      r_border = l_document->create_simple_element( name = 'Border'   parent = r_borders  ).
      r_border->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Left' ).
      PERFORM converti_linestyle USING it_style-border_left CHANGING w_linetype w_lineweight.
      MOVE w_linetype TO l_value.
      r_border->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = l_value ).
      IF w_lineweight IS NOT INITIAL.
        MOVE w_lineweight TO l_value.
        r_border->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = l_value ).
      ENDIF.
    ENDIF.
    IF it_style-border_right IS NOT INITIAL.
      r_border = l_document->create_simple_element( name = 'Border'   parent = r_borders  ).
      r_border->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Right' ).
      PERFORM converti_linestyle USING it_style-border_right CHANGING w_linetype w_lineweight.
      MOVE w_linetype TO l_value.
      r_border->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = l_value ).
      IF w_lineweight IS NOT INITIAL.
        MOVE w_lineweight TO l_value.
        r_border->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = l_value ).
      ENDIF.
    ENDIF.
    IF it_style-border_top IS NOT INITIAL.
      r_border = l_document->create_simple_element( name = 'Border'   parent = r_borders  ).
      r_border->set_attribute_ns( name = 'Position'  prefix = 'ss'  value = 'Top' ).
      PERFORM converti_linestyle USING it_style-border_top CHANGING w_linetype w_lineweight.
      MOVE w_linetype TO l_value.
      r_border->set_attribute_ns( name = 'LineStyle'  prefix = 'ss'  value = l_value ).
      IF w_lineweight IS NOT INITIAL.
        MOVE w_lineweight TO l_value.
        r_border->set_attribute_ns( name = 'Weight'  prefix = 'ss'  value = l_value ).
      ENDIF.
    ENDIF.

    IF w_protected IS NOT INITIAL.
      r_locked = l_document->create_simple_element( name = 'Protection'  parent = r_style  ).
      IF it_style-protected IS INITIAL.
        r_locked->set_attribute_ns( name = 'Protected' prefix = 'ss' value = '0' ).
      ELSE.
        r_locked->set_attribute_ns( name = 'Protected' prefix = 'ss' value = '1' ).
      ENDIF.
      IF it_style-hideformula IS INITIAL.
        r_locked->set_attribute_ns( name = 'HideFormula' prefix = 'x' value = '0' ).
      ELSE.
        r_locked->set_attribute_ns( name = 'HideFormula' prefix = 'x' value = '1' ).
      ENDIF.
    ENDIF.

  ENDLOOP.

*_ scrivo i dati
  MOVE 1 TO data_tabix.
  READ TABLE it_dati INDEX data_tabix.
  MOVE sy-subrc TO data_subrc.

  LOOP AT it_sheet.

    MOVE it_sheet-sheet_name TO l_value.
* Worksheet
    r_worksheet = l_document->create_simple_element( name = 'Worksheet'  parent = l_element_root ).
    r_worksheet->set_attribute_ns( name = 'Name'  prefix = 'ss'  value = l_value ).
    IF it_sheet-protected IS NOT INITIAL.
      r_worksheet->set_attribute_ns( name = 'Protected'  prefix = 'ss'  value = '1' ).
    ENDIF.

* Table
    r_table = l_document->create_simple_element( name = 'Table'  parent = r_worksheet ).
    WRITE it_sheet-column_max TO c_value NO-SIGN LEFT-JUSTIFIED NO-GROUPING.
    MOVE c_value TO l_value.
    r_table->set_attribute_ns( name = 'ExpandedColumnCount'  prefix = 'ss'  value = l_value ).
    WRITE it_sheet-row_max TO c_value NO-SIGN LEFT-JUSTIFIED NO-GROUPING.
    MOVE c_value TO l_value.
    r_table->set_attribute_ns( name = 'ExpandedRowCount'  prefix = 'ss'  value = l_value ).
    r_table->set_attribute_ns( name = 'FullColumns'  prefix = 'x'  value = '1' ).
    r_table->set_attribute_ns( name = 'FullRows'     prefix = 'x'  value = '1' ).

    DO it_sheet-column_max TIMES.

      CLEAR it_column.
      READ TABLE it_column WITH KEY sheet_nro = it_sheet-sheet_nro
                                    column_nro = sy-index
                 BINARY SEARCH.
      IF sy-subrc = 0.
        WRITE it_column-width TO c_value NO-SIGN LEFT-JUSTIFIED NO-GROUPING.
        MOVE c_value TO l_value.
        REPLACE FIRST OCCURRENCE OF ',' IN l_value WITH '.'.
      ELSE.
        MOVE '20' TO l_value.
      ENDIF.

* Column Formatting
      r_column = l_document->create_simple_element( name = 'Column'  parent = r_table ).
      r_column->set_attribute_ns( name = 'Width'    prefix = 'ss'  value = l_value   ).

* Style colonna (prevalente)
      IF  it_column-style_id IS NOT INITIAL
      AND it_column-style_id <> 'Default'.
        MOVE it_column-style_id TO l_value.
        r_column->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = l_value ).
      ENDIF.
    ENDDO.

    DO it_sheet-row_max TIMES.
      MOVE sy-index TO w_row_nro.
* Riga dati
      r_row = l_document->create_simple_element( name = 'Row'  parent = r_table ).

*_ sostituisco l'altezza riga automatica con il valore passato dal chiamante
      READ TABLE i_excel_row INTO s_excel_row WITH KEY sheet_nro = it_sheet-sheet_nro
                                                       row_nro   = w_row_nro.
      IF sy-subrc = 0.
        WRITE s_excel_row-height TO c_value NO-SIGN LEFT-JUSTIFIED NO-GROUPING.
        MOVE c_value TO l_value.
        REPLACE FIRST OCCURRENCE OF ',' IN l_value WITH '.'.
        r_row->set_attribute_ns( name = 'AutoFitHeight'  prefix = 'ss'  value = '0' ).
        r_row->set_attribute_ns( name = 'Height'         prefix = 'ss'  value = l_value ).
      ELSE.
        r_row->set_attribute_ns( name = 'AutoFitHeight'  prefix = 'ss'  value = '1' ).
      ENDIF.

      DO it_sheet-column_max TIMES.
        MOVE sy-index TO w_column_nro.

* Empty cell
        r_cell = l_document->create_simple_element( name = 'Cell'  parent = r_row ).

        WHILE data_subrc = 0
          AND ( it_dati-sheet_nro  < it_sheet-sheet_nro
             OR it_dati-sheet_nro  = it_sheet-sheet_nro
            AND it_dati-row_nro    < w_row_nro
             OR it_dati-sheet_nro  = it_sheet-sheet_nro
            AND it_dati-row_nro    = w_row_nro
            AND it_dati-column_nro < w_column_nro ).
          ADD 1 TO data_tabix.
          READ TABLE it_dati INTO it_dati INDEX data_tabix.
          MOVE sy-subrc TO data_subrc.
        ENDWHILE.

        IF  data_subrc = 0
        AND it_dati-sheet_nro  = it_sheet-sheet_nro
        AND it_dati-row_nro    = w_row_nro
        AND it_dati-column_nro = w_column_nro.

*_ controllo lo style e se diverso dalla colonna lo modifico
          READ TABLE it_column WITH KEY sheet_nro  = it_sheet-sheet_nro
                                        column_nro = w_column_nro
                     BINARY SEARCH.
          IF sy-subrc <> 0
          OR it_column-style_id <> it_dati-style_id.
            MOVE it_dati-style_id TO l_value.
            r_cell->set_attribute_ns( name = 'StyleID'  prefix = 'ss'  value = l_value ).
          ENDIF.

          IF it_dati-value IS NOT INITIAL.
            MOVE it_dati-value TO l_value.
            FIND ALL OCCURRENCES OF '.'
                                        IN l_value MATCH COUNT ctr_point.
            FIND ALL OCCURRENCES OF ',' IN l_value MATCH COUNT ctr_comma.
            FIND ALL OCCURRENCES OF '-' IN l_value MATCH COUNT ctr_sign.

            IF it_dati-numberformat IS NOT INITIAL.
              IF it_dati-numberformat = 'D'.        "Formato data
                CONCATENATE it_dati-value+6(2) '/' it_dati-value+4(2)
                        '/' it_dati-value+0(4) INTO l_value.
              ELSEIF it_dati-numberformat = 'T'.    "Formato ora
                CONCATENATE it_dati-value(2) ':' it_dati-value+2(2)
                        ':' it_dati-value+4(2) INTO l_value.
              ELSEIF it_dati-numberformat <> 'STRING'.
                IF  ctr_comma = 1
                AND ctr_point = 0.
                  REPLACE FIRST OCCURRENCE OF ',' IN l_value WITH '.'.
                  SUBTRACT 1 FROM ctr_comma.
                  ADD 1 TO ctr_point.
                ENDIF.
              ENDIF.
            ENDIF.

            IF  it_dati-numberformat <> 'STRING'
            AND l_value CO '1234567890.-'
            AND ctr_point <= 1
            AND ctr_sign  <= 1.
              w_len = strlen( l_value ) - 1.
              IF w_len >= 0
              AND l_value+w_len(1) = '-'.
                CONCATENATE '-' l_value(w_len) INTO l_value.   " Porto il segno in testa
              ENDIF.
              r_data = l_document->create_simple_element( name = 'Data'  value = l_value parent = r_cell ).
              r_data->set_attribute_ns( name = 'Type'  prefix = 'ss' value = 'Number' ).
            ELSE.
              r_data = l_document->create_simple_element( name = 'Data'  value = l_value parent = r_cell ).
              r_data->set_attribute_ns( name = 'Type'  prefix = 'ss' value = 'String' ).
            ENDIF.

          ENDIF.

          ADD 1 TO data_tabix.
          READ TABLE it_dati INDEX data_tabix.
          MOVE sy-subrc TO data_subrc.

        ENDIF.

      ENDDO.

    ENDDO.

    IF it_sheet-top_row IS NOT INITIAL
    AND it_sheet-left_column IS NOT INITIAL.

      r_worksheetoptions    = l_document->create_simple_element( name = 'WorksheetOptions'  parent = r_worksheet ).
      r_worksheetoptions->set_attribute( name = 'xmlns'  value = 'urn:schemas-microsoft-com:office:excel' ).

      r_freezepanes         = l_document->create_simple_element( name = 'FreezePanes'  parent = r_worksheetoptions ).

      WRITE it_sheet-top_row TO c_value NO-SIGN NO-GROUPING LEFT-JUSTIFIED.
      MOVE c_value TO l_value.
      r_splithorizontal     = l_document->create_simple_element( name = 'SplitHorizontal'     value = l_value parent = r_worksheetoptions ).
      r_toprowbottompane    = l_document->create_simple_element( name = 'TopRowBottomPane'    value = l_value parent = r_worksheetoptions ).
      WRITE it_sheet-left_column TO c_value NO-SIGN NO-GROUPING LEFT-JUSTIFIED.
      MOVE c_value TO l_value.
      r_splitvertical       = l_document->create_simple_element( name = 'SplitVertical'       value = l_value parent = r_worksheetoptions ).
      r_leftcolumnrightpane = l_document->create_simple_element( name = 'LeftColumnRightPane' value = l_value parent = r_worksheetoptions ).

      IF  it_sheet-active_pane >= '0'
      AND it_sheet-active_pane <= '3'.
        MOVE it_sheet-active_pane TO l_value.
      ELSE.
        MOVE '0' TO l_value.
      ENDIF.
      r_activepane = l_document->create_simple_element( name = 'ActivePane' value = l_value parent = r_worksheetoptions ).
      r_panes      = l_document->create_simple_element( name = 'Panes' parent = r_worksheetoptions ).
      r_pane       = l_document->create_simple_element( name = 'Pane'  parent = r_panes ).
      r_number     = l_document->create_simple_element( name = 'Number' value = '3' parent = r_pane ).
      r_pane       = l_document->create_simple_element( name = 'Pane'  parent = r_panes ).
      r_number     = l_document->create_simple_element( name = 'Number' value = '1' parent = r_pane ).
      r_pane       = l_document->create_simple_element( name = 'Pane'  parent = r_panes ).
      r_number     = l_document->create_simple_element( name = 'Number' value = '2' parent = r_pane ).
      r_pane       = l_document->create_simple_element( name = 'Pane'  parent = r_panes ).
      r_number     = l_document->create_simple_element( name = 'Number' value = '0' parent = r_pane ).

    ELSEIF it_sheet-top_row IS NOT INITIAL.

      r_worksheetoptions    = l_document->create_simple_element( name = 'WorksheetOptions'  parent = r_worksheet ).
      r_worksheetoptions->set_attribute( name = 'xmlns'  value = 'urn:schemas-microsoft-com:office:excel' ).

      r_freezepanes         = l_document->create_simple_element( name = 'FreezePanes'  parent = r_worksheetoptions ).

      WRITE it_sheet-top_row TO c_value NO-SIGN NO-GROUPING LEFT-JUSTIFIED.
      MOVE c_value TO l_value.
      r_splithorizontal     = l_document->create_simple_element( name = 'SplitHorizontal'     value = l_value parent = r_worksheetoptions ).
      r_toprowbottompane    = l_document->create_simple_element( name = 'TopRowBottomPane'    value = l_value parent = r_worksheetoptions ).

      IF it_sheet-active_pane = '3'
      OR it_sheet-active_pane = '2'.
        MOVE it_sheet-active_pane TO l_value.
      ELSE.
        MOVE '2' TO l_value.
      ENDIF.
      r_activepane = l_document->create_simple_element( name = 'ActivePane' value = l_value parent = r_worksheetoptions ).
      r_panes      = l_document->create_simple_element( name = 'Panes' parent = r_worksheetoptions ).
      r_pane       = l_document->create_simple_element( name = 'Pane'  parent = r_panes ).
      r_number     = l_document->create_simple_element( name = 'Number' value = '3' parent = r_pane ).
      r_pane       = l_document->create_simple_element( name = 'Pane'  parent = r_panes ).
      r_number     = l_document->create_simple_element( name = 'Number' value = '2' parent = r_pane ).

    ELSEIF it_sheet-left_column IS NOT INITIAL.

      r_worksheetoptions    = l_document->create_simple_element( name = 'WorksheetOptions'  parent = r_worksheet ).
      r_worksheetoptions->set_attribute( name = 'xmlns'  value = 'urn:schemas-microsoft-com:office:excel' ).

      r_freezepanes         = l_document->create_simple_element( name = 'FreezePanes'  parent = r_worksheetoptions ).

      WRITE it_sheet-left_column TO c_value NO-SIGN NO-GROUPING LEFT-JUSTIFIED.
      MOVE c_value TO l_value.
      r_splitvertical       = l_document->create_simple_element( name = 'SplitVertical'       value = l_value parent = r_worksheetoptions ).
      r_leftcolumnrightpane = l_document->create_simple_element( name = 'LeftColumnRightPane' value = l_value parent = r_worksheetoptions ).

      IF it_sheet-active_pane = '3'
      OR it_sheet-active_pane = '1'.
        MOVE it_sheet-active_pane TO l_value.
      ELSE.
        MOVE '1' TO l_value.
      ENDIF.
      r_activepane = l_document->create_simple_element( name = 'ActivePane' value = l_value parent = r_worksheetoptions ).
      r_panes      = l_document->create_simple_element( name = 'Panes' parent = r_worksheetoptions ).
      r_pane       = l_document->create_simple_element( name = 'Pane'  parent = r_panes ).
      r_number     = l_document->create_simple_element( name = 'Number' value = '3' parent = r_pane ).
      r_pane       = l_document->create_simple_element( name = 'Pane'  parent = r_panes ).
      r_number     = l_document->create_simple_element( name = 'Number' value = '1' parent = r_pane ).

    ENDIF.

  ENDLOOP.

  MOVE 'XLS' TO e_doc_type.

* Creating a Stream Factory
  l_stream_factory = l_ixml->create_stream_factory( ).

* Connect Internal XML String to Stream Factory
  l_ostream = l_stream_factory->create_ostream_itable( table = e_xml_table ).
*  l_ostream = l_streamfactory->create_ostream_xstring( string = l_xml_xstring ).

* Rendering the Document
  l_renderer = l_ixml->create_renderer( ostream  = l_ostream  document = l_document ).
  e_rc = l_renderer->render( ).

* Saving the XML Document
  e_xml_size = l_ostream->get_num_written_raw( ).

  FREE: l_ixml
       ,l_document
       ,l_pi_parsed
       ,l_element_root
       ,l_stream_factory
       ,l_ostream
       ,l_renderer
       ,l_attribute
       ,r_documentproperties
       ,r_styles
       ,r_style
       ,r_alignment
       ,r_font
       ,r_interior
       ,r_numberformat
       ,r_borders
       ,r_border
       ,r_worksheet
       ,r_table
       ,r_column
       ,r_row
       ,r_cell
       ,r_data
       ,r_worksheetoptions
       ,r_freezepanes
       ,r_splithorizontal
       ,r_toprowbottompane
       ,r_splitvertical
       ,r_leftcolumnrightpane
       ,r_activepane
       ,r_panes
       ,r_pane
       ,r_number.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  converti_linestyle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LINESTYLE   text
*      <--P_LINETYPE    text
*      <--P_LINEWEIGHT  text
*----------------------------------------------------------------------*
FORM converti_linestyle USING p_linestyle
                        CHANGING p_linetype
                                 p_lineweight.

  CLEAR: p_linetype,
         p_lineweight.

  CASE p_linestyle.
    WHEN '1'.
      MOVE 'Continuous'   TO p_linetype.
      MOVE '1'            TO p_lineweight.
    WHEN '2'.
      MOVE 'Continuous'   TO p_linetype.
      MOVE '2'            TO p_lineweight.
    WHEN '3'.
      MOVE 'Continuous'   TO p_linetype.
      MOVE '3'            TO p_lineweight.
    WHEN 'A'.
      MOVE 'Dash'         TO p_linetype.
    WHEN 'B'.
      MOVE 'DashDot'      TO p_linetype.
    WHEN 'C'.
      MOVE 'DashDotDot'   TO p_linetype.
    WHEN 'D'.
      MOVE 'Dot'          TO p_linetype.
    WHEN 'E'.
      MOVE 'Double'       TO p_linetype.
    WHEN 'F'.
      MOVE 'SlantDashDot' TO p_linetype.
    WHEN OTHERS.
      MOVE 'Continuous'   TO p_linetype.
      MOVE '1'            TO p_lineweight.
  ENDCASE.

ENDFORM.                    "converti_linestyle
