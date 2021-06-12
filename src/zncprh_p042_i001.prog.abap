*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P042_I001
*&---------------------------------------------------------------------*
TABLES : /BNT/PJ01, /BNT/PJ01R.
DATA : BEGIN OF gs_pj01,
  pjid TYPE /BNT/PJID,
  pjnm TYPE /BNT/PJNM,
  END OF gs_pj01,
         gt_pj01 LIKE STANDARD TABLE OF gs_pj01.
*--------------------------------------------------------------------*

DATA : BEGIN OF gs_pj01r_alv."Alv Structure
        INCLUDE STRUCTURE /BNT/PJ01R.
DATA ename TYPE emnam.
DATA rltp_ddtext TYPE ddtext.
DATA enddate_refresh TYPE checkbox.
DATA : END OF gs_pj01r_alv.

DATA : gt_pj01r_alv LIKE STANDARD TABLE OF gs_pj01r_alv,
       gt_pj01r     TYPE STANDARD TABLE OF /BNT/PJ01R,"DB Tablosu İtab
       gs_pj01r     TYPE /BNT/PJ01R. "DB Tab Structure

DATA : BEGIN OF gs_ename,"
   pernr TYPE persno,
   ename TYPE emnam,
END OF gs_ename,
gt_ename LIKE STANDARD TABLE OF gs_ename.


DATA : BEGIN OF gs_rltp,
  domvalue_l TYPE domvalue_l,
  ddtext     TYPE   ddtext,
  END OF gs_rltp.
DATA gt_rltp LIKE STANDARD TABLE OF gs_rltp.

DATA : gv_pj01r_date LIKE sy-datum,
       gv_pj01r_fname TYPE char4.

CLASS class DEFINITION DEFERRED.
DATA cl TYPE REF TO class.

DATA : gr_custom_container TYPE REF TO cl_gui_custom_container,
       gr_splitter         TYPE REF TO cl_gui_splitter_container,
       gr_pj01_container   TYPE REF TO cl_gui_container,
       gr_pj01r_container  TYPE REF TO cl_gui_container,
       gr_pj01_grid        TYPE REF TO cl_gui_alv_grid ,
       gr_pj01r_grid       TYPE REF TO cl_gui_alv_grid .



DATA: gt_fcat_pj01      TYPE lvc_t_fcat,
      gs_fcat_pj01      TYPE lvc_s_fcat,
      gt_fcat_pj01r     TYPE lvc_t_fcat,
      gs_fcat_pj01r     TYPE lvc_s_fcat,
      gs_layout         TYPE lvc_s_layo,
      gs_refresh        TYPE lvc_s_stbl,
      gs_toolbar        TYPE stb_button,
      gs_exclude_pj01r  TYPE ui_func,
      gt_exclude_pj01r  TYPE ui_functions,
      gs_exclude_pj01   TYPE ui_func,
      gt_exclude_pj01   TYPE ui_functions.
*      gt_row            TYPE lvc_t_row,
*      gs_row            TYPE lvc_s_row.
