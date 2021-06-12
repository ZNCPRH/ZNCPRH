*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P041_I001
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZP1685_P79_I001
*&---------------------------------------------------------------------*
TYPE-POOLS : slis.
TABLES: trdir, seoclass, tfdir, enlfdir, dd02l, tadiv, dd40l, transfdesc.

TYPES : BEGIN OF ty_dd40l,
          typename TYPE dd40l-typename,
          rowtype  TYPE dd40l-rowtype,
          as4user  TYPE dd40l-as4user,
          ddtext   TYPE dd40t-ddtext,
        END OF ty_dd40l.


TYPES : BEGIN OF ty_solix,
          program_name TYPE string,
          program_type TYPE string,
          solix        TYPE STANDARD TABLE OF solix WITH DEFAULT KEY,
        END OF ty_solix.

TYPES : BEGIN OF ty_source_data,
          program_name TYPE string,
          program_type TYPE string,
          source_code  TYPE re_t_string,
        END OF ty_source_data.

TYPES : BEGIN OF ty_node_key,
          parent TYPE lvc_nkey,
          child  TYPE lvc_nkey,
          otype  TYPE zncprh_t005-otype,
          name1  TYPE zncprh_t005-name1,
          mnfld  TYPE zncprh_t005-mnfld,
        END OF ty_node_key.

TYPES : ty_html       TYPE STANDARD TABLE OF string,
        ty_source_tab TYPE STANDARD TABLE OF ty_source_data,
        ty_solix_tab  TYPE STANDARD TABLE OF ty_solix.

DATA : gt_t022      TYPE STANDARD TABLE OF zncprh_t004, "Döküman
       gt_t023      TYPE STANDARD TABLE OF zncprh_t005, "Tree
       gt_t023_chck TYPE STANDARD TABLE OF zncprh_t005, "Tree
       gt_t024_tree TYPE STANDARD TABLE OF zncprh_t006, "Tree içerik
       gt_t024      TYPE STANDARD TABLE OF zncprh_t006. "Program İçerik

DATA : gt_node_key TYPE STANDARD TABLE OF ty_node_key,
       gs_node_key TYPE ty_node_key,
       gt_tree_key TYPE STANDARD TABLE OF ty_node_key,
       gs_tree_key TYPE ty_node_key.

DATA : gv_program_node_key TYPE lvc_nkey,
       gv_upd_flag(1),
       gv_down_flag(1),
       gv_popup_flag(1).


CLASS : cl_gui_column_tree DEFINITION LOAD,
        cl_gui_cfw DEFINITION LOAD.

CLASS : lcl_report DEFINITION DEFERRED,
        lcl_convert DEFINITION DEFERRED .

DATA : gr_report  TYPE REF TO lcl_report,
       gr_convert TYPE REF TO lcl_convert.


SELECTION-SCREEN: BEGIN OF SCREEN 500 AS WINDOW TITLE TEXT-001.

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.

SELECTION-SCREEN BEGIN OF LINE."Table Select Options
PARAMETERS: r_table RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 5(15) trtable.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(15) tptable.
SELECT-OPTIONS: sotable FOR dd02l-tabname.
SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rtabtype RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 5(15) trtabtyp.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE."Table Type Options
SELECTION-SCREEN COMMENT 10(15) tptabtyp.
SELECT-OPTIONS: sotabtyp FOR dd40l-typename.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE."Message Class
PARAMETERS: rmess RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 5(18) tpmes.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(18) tmname.
PARAMETERS: pmname LIKE t100-arbgb MEMORY ID mmname.
SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE."Function modules
PARAMETERS: rfunc RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 5(30) trfunc.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(15) tpfname.
SELECT-OPTIONS: sofname FOR tfdir-funcname.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE."Function Group
SELECTION-SCREEN COMMENT 10(15) tfgroup.
SELECT-OPTIONS: sofgroup FOR enlfdir-area.
SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE."XSLT Transformation
PARAMETERS: rxslt RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 5(30) trxslt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(15) tpxslt.
SELECT-OPTIONS: soxslt FOR transfdesc-xsltdesc.
SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE."Classes
PARAMETERS: rclass RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 5(30) trclass.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(15) tpcname.
SELECT-OPTIONS: soclass FOR seoclass-clsname.
SELECTION-SCREEN END OF LINE.

* Programs / includes
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rprog RADIOBUTTON GROUP r1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(18) tprog.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(15) trpname.
SELECT-OPTIONS: soprog FOR trdir-name.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN : END OF BLOCK b1.

SELECTION-SCREEN : END OF SCREEN 500.
