*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P045_I001
*&---------------------------------------------------------------------*

TABLES :sscrfields.
CLASS lcl_class DEFINITION DEFERRED.

DATA : g_object TYPE REF TO lcl_class.


TYPES : BEGIN OF ty_data.
    INCLUDE STRUCTURE zncprh_t007.
TYPES END OF ty_data.


DATA :gt_data TYPE TABLE OF ty_data,
      gs_data TYPE ty_data.


DATA: gt_excel TYPE TABLE OF ty_data,
      gs_excel TYPE ty_data.
CONSTANTS: gc_batch       TYPE icon-id   VALUE '@BW@'.


data : ls_Data TYPE ZNCPRH_S033 ,
       lt_data TYPE TABLE OF ZNCPRH_S033.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_file(200) TYPE c MODIF ID exc LOWER CASE,
             p_header    TYPE c AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: FUNCTION KEY 1.
SELECTION-SCREEN END OF BLOCK b1.
