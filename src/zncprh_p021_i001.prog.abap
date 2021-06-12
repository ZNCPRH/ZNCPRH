*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P021_I001
*&---------------------------------------------------------------------*

DATA:
  oref_container   TYPE REF TO cl_gui_custom_container,
  iref_control     TYPE REF TO i_oi_container_control,
  iref_document    TYPE REF TO i_oi_document_proxy,
  iref_spreadsheet TYPE REF TO i_oi_spreadsheet,
  iref_error       TYPE REF TO i_oi_error.

DATA:
  v_document_url TYPE c LENGTH 256,
  i_sheets       TYPE soi_sheets_table,
  wa_sheets      TYPE soi_sheets,
  i_data         TYPE soi_generic_table,
  wa_data        TYPE soi_generic_item,
  lt_rdata       TYPE soi_dimension_table,
  ls_rdata       TYPE soi_dimension_item,
  i_ranges       TYPE soi_range_list.

PARAMETERS:
  p_file TYPE  localfile
   DEFAULT 'C:\Users\P1362\Desktop\malat Emirleri Raporu 14.04.2021.xlsx' OBLIGATORY,
  p_rows TYPE i DEFAULT 300 OBLIGATORY, "Rows (Maximum 65536)
  p_cols TYPE i DEFAULT 15 OBLIGATORY.    "Columns (Maximum 256)
