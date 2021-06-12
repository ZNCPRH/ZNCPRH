*&---------------------------------------------------------------------*
*& Report ZNCPRH_P011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p011.


INCLUDE ole2incl.
* handles for OLE objects
DATA: h_excel TYPE ole2_object,        " Excel object
      h_mapl  TYPE ole2_object,         " list of workbooks
      h_map   TYPE ole2_object,          " workbook
      h_zl    TYPE ole2_object,           " cell
      h_f     TYPE ole2_object.            " font
TABLES: spfli.
DATA  h TYPE i.
* table of flights
DATA: it_spfli LIKE spfli OCCURS 10 WITH HEADER LINE.




*&---------------------------------------------------------------------*
*&   Event START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* read flights
  SELECT * FROM spfli INTO TABLE it_spfli UP TO 10 ROWS.
* display header
  ULINE (61).
  WRITE: /     sy-vline NO-GAP,
          (3)  'Flg'(001) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP,
          (4)  'Nr'(002) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP,
          (20) 'Von'(003) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP,
          (20) 'Nach'(004) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP,
          (8)  'Zeit'(005) COLOR COL_HEADING NO-GAP, sy-vline NO-GAP.
  ULINE /(61).
* display flights
  LOOP AT it_spfli.
    WRITE: / sy-vline NO-GAP,
             it_spfli-carrid COLOR COL_KEY NO-GAP, sy-vline NO-GAP,
             it_spfli-connid COLOR COL_NORMAL NO-GAP, sy-vline NO-GAP,
             it_spfli-cityfrom COLOR COL_NORMAL NO-GAP, sy-vline NO-GAP,
             it_spfli-cityto COLOR COL_NORMAL NO-GAP, sy-vline NO-GAP,
             it_spfli-deptime COLOR COL_NORMAL NO-GAP, sy-vline NO-GAP.
  ENDLOOP.
  ULINE /(61).
* tell user what is going on
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text   = TEXT-007
    EXCEPTIONS
      OTHERS = 1.
* start Excel
  CREATE OBJECT h_excel 'EXCEL.APPLICATION'.
*  PERFORM ERR_HDL.

  SET PROPERTY OF h_excel  'Visible' = 1.
*  CALL METHOD OF H_EXCEL 'FILESAVEAS' EXPORTING #1 = 'c:\kis_excel.xls'
  .

*  PERFORM ERR_HDL.
* tell user what is going on
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text   = TEXT-008
    EXCEPTIONS
      OTHERS = 1.
* get list of workbooks, initially empty
  CALL METHOD OF h_excel 'Workbooks' = h_mapl.
  PERFORM err_hdl.
* add a new workbook
  CALL METHOD OF h_mapl 'Add' = h_map.
  PERFORM err_hdl.
* tell user what is going on
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text   = TEXT-009
    EXCEPTIONS
      OTHERS = 1.
* output column headings to active Excel sheet
  PERFORM fill_cell USING 1 1 1 'Flug'(001).
  PERFORM fill_cell USING 1 2 0 'Nr'(002).
  PERFORM fill_cell USING 1 3 1 'Von'(003).
  PERFORM fill_cell USING 1 4 1 'Nach'(004).
  PERFORM fill_cell USING 1 5 1 'Zeit'(005).
  LOOP AT it_spfli.
* copy flights to active EXCEL sheet
    h = sy-tabix + 1.
    PERFORM fill_cell USING h 1 0 it_spfli-carrid.
    PERFORM fill_cell USING h 2 0 it_spfli-connid.
    PERFORM fill_cell USING h 3 0 it_spfli-cityfrom.
    PERFORM fill_cell USING h 4 0 it_spfli-cityto.
    PERFORM fill_cell USING h 5 0 it_spfli-deptime.
  ENDLOOP.

* changes by Kishore  - start
*  CALL METHOD OF H_EXCEL 'Workbooks' = H_MAPL.
  CALL METHOD OF h_excel 'Worksheets' = h_mapl." EXPORTING #1 = 2.

  PERFORM err_hdl.
* add a new workbook
  CALL METHOD OF h_mapl 'Add' = h_map EXPORTING #1 = 2.
  PERFORM err_hdl.
* tell user what is going on
  SET PROPERTY OF h_map 'NAME' = 'COPY'.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE = 0
      text   = TEXT-009
    EXCEPTIONS
      OTHERS = 1.
* output column headings to active Excel sheet
  PERFORM fill_cell USING 1 1 1 'Flug'(001).
  PERFORM fill_cell USING 1 2 0 'Nr'(002).
  PERFORM fill_cell USING 1 3 1 'Von'(003).
  PERFORM fill_cell USING 1 4 1 'Nach'(004).
  PERFORM fill_cell USING 1 5 1 'Zeit'(005).
  LOOP AT it_spfli.
* copy flights to active EXCEL sheet
    h = sy-tabix + 1.
    PERFORM fill_cell USING h 1 0 it_spfli-carrid.
    PERFORM fill_cell USING h 2 0 it_spfli-connid.
    PERFORM fill_cell USING h 3 0 it_spfli-cityfrom.
    PERFORM fill_cell USING h 4 0 it_spfli-cityto.
    PERFORM fill_cell USING h 5 0 it_spfli-deptime.
  ENDLOOP.
* changes by Kishore  - end
* disconnect from Excel
*      CALL METHOD OF H_EXCEL 'FILESAVEAS' EXPORTING  #1 = 'C:\SKV.XLS'.

  FREE OBJECT h_excel.
  PERFORM err_hdl.
*---------------------------------------------------------------------*
*       FORM FILL_CELL                                                *
*---------------------------------------------------------------------*
*       sets cell at coordinates i,j to value val boldtype bold       *
*---------------------------------------------------------------------*
FORM fill_cell USING i j bold val.
  CALL METHOD OF h_excel 'Cells' = h_zl EXPORTING #1 = i #2 = j.
  PERFORM err_hdl.
  SET PROPERTY OF h_zl 'Value' = val .
  PERFORM err_hdl.
  GET PROPERTY OF h_zl 'Font' = h_f.
  PERFORM err_hdl.
  SET PROPERTY OF h_f 'Bold' = bold .
  PERFORM err_hdl.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ERR_HDL
*&---------------------------------------------------------------------*
*       outputs OLE error if any                                       *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM err_hdl.
  IF sy-subrc <> 0.
    WRITE: / 'Fehler bei OLE-Automation:'(010), sy-subrc.
    STOP.
  ENDIF.
ENDFORM.                    " ERR_HDL
