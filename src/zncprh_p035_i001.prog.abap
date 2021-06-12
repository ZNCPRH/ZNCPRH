*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P035_I001
*&---------------------------------------------------------------------*

TYPE-POOLS: abap.

DATA:
  gd_repid    TYPE syrepid,
  gd_okcode   TYPE ui_func,
*
  go_docking1 TYPE REF TO cl_gui_docking_container,
  go_docking2 TYPE REF TO cl_gui_docking_container,
  go_grid1    TYPE REF TO cl_gui_alv_grid,
  go_grid2    TYPE REF TO cl_gui_alv_grid,
  gs_layout1  TYPE lvc_s_layo,
  gs_layout2  TYPE lvc_s_layo,
  gs_variant1 TYPE disvariant,
  gs_variant2 TYPE disvariant.


DATA:
  gt_outtab1 TYPE STANDARD TABLE OF knb1,
  gt_outtab2 TYPE STANDARD TABLE OF knvv.
