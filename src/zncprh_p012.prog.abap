*&---------------------------------------------------------------------*
*& Report ZNCPRH_P012
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p012.


INCLUDE ole2incl.

TABLES: spfli.

DATA: gs_word        TYPE    ole2_object, "Word Object
      gs_documents   TYPE ole2_object, "List of documents
      gs_document    TYPE ole2_object, "Current / Active document
      gs_selection   TYPE ole2_object, "Current Cursor Selection
      gs_actdoc      TYPE ole2_object , "Active document
      gs_font        TYPE ole2_object , "Font
      gs_parformat   TYPE ole2_object , "Paragraph format
      gs_tables      TYPE ole2_object , "Tables
      gs_table       TYPE ole2_object,
      gs_range       TYPE ole2_object,
      gs_cell        TYPE ole2_object,
      gs_border      TYPE ole2_object,
      gs_application TYPE ole2_object . "Application
DATA: wf_lines   TYPE i,
      wf_counter TYPE i.

DATA: gt_spfli TYPE STANDARD TABLE OF spfli,
      gs_spfli TYPE spfli.

INITIALIZATION.
  SELECT-OPTIONS: s_carrid FOR spfli-carrid.
  PARAMETERS:    p_file  TYPE localfile DEFAULT 'C:\Users\P1362\Desktop\ABAP_OLE_word.vso'.

START-OF-SELECTION.
  SELECT * FROM spfli INTO TABLE gt_spfli WHERE carrid IN s_carrid.

END-OF-SELECTION.
  CREATE OBJECT gs_word 'WORD.APPLICATION'. "Create word object
* Setting object's visibility property
  SET PROPERTY OF gs_word 'Visible' = 1.
*  Opening a new document
  CALL METHOD OF gs_word 'Documents' = gs_documents.
  CALL METHOD OF gs_documents 'Add' = gs_document.
*  Activating the sheet
  CALL METHOD OF gs_document 'Activate'.
* Getting active document handle
  GET PROPERTY OF gs_word 'ActiveDocument' = gs_actdoc.
*  Getting applications handle
  GET PROPERTY OF gs_actdoc 'Application' = gs_application.
* Getting handle for the selection which is here the character at the cursor position
  GET PROPERTY OF gs_application 'Selection' = gs_selection.
  GET PROPERTY OF gs_selection 'Font' = gs_font.
  GET PROPERTY OF gs_selection 'ParagraphFormat' = gs_parformat.


  SET PROPERTY OF gs_font 'Name' = 'Arial'.
  SET PROPERTY OF gs_font 'Size' = '10'.
  SET PROPERTY OF gs_font 'Bold' = '1'.
  SET PROPERTY OF gs_font 'Italic' = '1'.
  SET PROPERTY OF gs_font 'Underline' = '1'.
  SET PROPERTY OF gs_parformat 'Alignment' = '1'. " Centered


  CALL METHOD OF gs_selection 'TypeText'
    EXPORTING
      #1 = 'Flight Details'.

  DESCRIBE TABLE gt_spfli LINES wf_lines.
  wf_lines = wf_lines + 1.
  GET PROPERTY OF gs_actdoc 'Tables' = gs_tables.
  GET PROPERTY OF gs_selection 'Range' = gs_range.
  CALL METHOD OF gs_tables 'Add' = gs_table
          EXPORTING #1 = gs_range
                    #2 = wf_lines " Rows
                    #3 = '4'. "Columns
  GET PROPERTY OF gs_table 'Borders' = gs_border.
  SET PROPERTY OF gs_border 'Enable' = '1'.


  CALL METHOD OF gs_table 'Cell' = gs_cell
  EXPORTING #1 = '1'
  #2 = '1'.
  GET PROPERTY OF gs_cell 'Range' = gs_range.
  SET PROPERTY OF gs_range 'Text' = 'Airline Code'.
  CALL METHOD OF gs_table 'Cell' = gs_cell
    EXPORTING #1 = '1'
    #2 = '2'.
  GET PROPERTY OF gs_cell 'Range' = gs_range.
  SET PROPERTY OF gs_range 'Text' = 'Flight Connection Number'.
  CALL METHOD OF gs_table 'Cell' = gs_cell
    EXPORTING #1 = '1'
    #2 = '3'.
  GET PROPERTY OF gs_cell 'Range' = gs_range.
  SET PROPERTY OF gs_range 'Text' = 'Country Key'.
  CALL METHOD OF gs_table 'Cell' = gs_cell
    EXPORTING #1 = '1'
    #2 = '4'.
  GET PROPERTY OF gs_cell 'Range' = gs_range.
  SET PROPERTY OF gs_range 'Text' = 'Departure city'.


  LOOP AT gt_spfli INTO gs_spfli.
    wf_counter = wf_counter + 1.
    CALL METHOD OF gs_table 'Cell' = gs_cell
    EXPORTING #1 = wf_counter
                      #2 = '1'.
    GET PROPERTY OF gs_cell 'Range' = gs_range .
    SET PROPERTY OF gs_range 'Text' = gs_spfli-carrid .

    CALL METHOD OF gs_table 'Cell' = gs_cell
    EXPORTING #1 = wf_counter
                      #2 = '2'.
    GET PROPERTY OF gs_cell 'Range' = gs_range .
    SET PROPERTY OF gs_range 'Text' = gs_spfli-connid.

    CALL METHOD OF gs_table 'Cell' = gs_cell
    EXPORTING #1 = wf_counter
                      #2 = '3'.
    GET PROPERTY OF gs_cell 'Range' = gs_range .
    SET PROPERTY OF gs_range 'Text' = gs_spfli-countryfr.

    CALL METHOD OF gs_table 'Cell' = gs_cell
    EXPORTING #1 = wf_counter
                      #2 = '4'.
    GET PROPERTY OF gs_cell 'Range' = gs_range .
    SET PROPERTY OF gs_range 'Text' = gs_spfli-cityfrom.
  ENDLOOP.

  CALL METHOD OF gs_document 'SaveAs'
    EXPORTING
      #1 = p_file.

  FREE OBJECT gs_word.
