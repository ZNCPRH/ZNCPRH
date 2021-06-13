*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P054_I001
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Types and Data
*&---------------------------------------------------------------------*

CONSTANTS:
  gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
  gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

TYPES : BEGIN OF ty_fin ,
          line TYPE string,
        END OF ty_fin .

DATA : g_email         TYPE char200 .
DATA : ascilines(1024) TYPE c OCCURS 0 WITH HEADER LINE.
DATA : list            TYPE TABLE OF abaplist WITH HEADER LINE.
DATA : i_final         TYPE TABLE OF ty_fin .

*&---------------------------------------------------------------------*
*&      Selection Screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME .
PARAMETERS : p_report TYPE trdir-name    OBLIGATORY,
             p_vari   TYPE rsvar-variant OBLIGATORY.
SELECTION-SCREEN SKIP 1 .

PARAMETER : p_trim TYPE char01 AS   CHECKBOX ,
            p_neg  TYPE char01 AS CHECKBOX .
SELECTION-SCREEN SKIP 1 .

SELECT-OPTIONS : s_to FOR g_email NO INTERVALS OBLIGATORY,
                 s_cc FOR g_email NO INTERVALS .
SELECTION-SCREEN END OF BLOCK b1 .
