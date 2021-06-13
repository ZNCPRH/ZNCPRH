*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P510_I001
*&---------------------------------------------------------------------*

TYPE-POOLS:
  slis.

CLASS cl_event_receiver       DEFINITION DEFERRED.
CLASS cl_base_event_receiver  DEFINITION DEFERRED.

DATA:
  gt_usr TYPE TABLE OF usr02,
  gs_usr TYPE usr02.

DATA:
  go_grid                TYPE REF TO cl_gui_alv_grid,
  go_custom_container    TYPE REF TO cl_gui_custom_container,
  go_event_receiver      TYPE REF TO cl_event_receiver,
  go_base_event_receiver TYPE REF TO cl_base_event_receiver,
  ok_code                TYPE sy-ucomm,
  gt_fcat                TYPE lvc_t_fcat.
