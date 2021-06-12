*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P031_I001
*&---------------------------------------------------------------------*

TABLES :sscrfields.
CLASS lcl_class DEFINITION DEFERRED.
TYPES: BEGIN OF ty_data,

         gbasl          TYPE  zekre_dd086,
         gbits          TYPE  wretail_se_sibs_datto,
         statet         TYPE  zegre_dd52,
         districtt      TYPE  zekre_dd002,
         zzdonersermaye TYPE  zekre_dd036,
       END OF ty_data.

DATA: gt_data TYPE TABLE OF zekre_t089,
      gs_data TYPE zekre_t089.
*DATA : gt_data TYPE TABLE OF ty_data,
*       gs_data TYPE ty_data.

DATA: gt_excel TYPE TABLE OF ty_data,
      gs_excel TYPE ty_data.
CONSTANTS: gc_batch       TYPE icon-id   VALUE '@BW@'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_file(200) TYPE c MODIF ID exc LOWER CASE,
             p_header    TYPE c AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: FUNCTION KEY 1.
SELECTION-SCREEN END OF BLOCK b1.
