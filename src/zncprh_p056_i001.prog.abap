*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P056_I001
*&---------------------------------------------------------------------*
CLASS gc_main DEFINITION DEFERRED.
TABLES: pa0001,toahr.

DATA go_main TYPE REF TO gc_main.
DATA : gv_sapobject TYPE saeanwdid,
       gv_archiv_id TYPE saearchivi,
       gv_ar_object TYPE saeobjart.

CONSTANTS : gc_orj TYPE zncprh_de026 VALUE 'ORJ',
            gc_rsz TYPE zncprh_de026 VALUE 'RSZ'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-bl1.
SELECT-OPTIONS: s_pernr FOR pa0001-pernr.
PARAMETERS :    p_ardat TYPE toahr-ar_date OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
