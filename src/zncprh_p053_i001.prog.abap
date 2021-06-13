*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P053_I001
*&---------------------------------------------------------------------*
class lcl_main DEFINITION DEFERRED.
TABLES : mara,icon.
DATA : gt_out       TYPE TABLE OF zncprh_s038.
DATA : BEGIN OF gt_log OCCURS 0.
DATA : matnr LIKE mara-matnr.
       INCLUDE STRUCTURE bapiret2  .
       DATA : END OF gt_log.
data: g_object TYPE REF TO lcl_main.
DATA: gv_tabname TYPE string VALUE 'GT_OUT',
      gv_strname TYPE string VALUE 'ZNCPRH_S038'.


**-
SELECTION-SCREEN BEGIN OF BLOCK b1.
SELECT-OPTIONS : s_matnr FOR mara-matnr.
SELECTION-SCREEN END OF BLOCK b1.
