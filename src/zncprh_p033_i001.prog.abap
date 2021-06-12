*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P033_I001
*&---------------------------------------------------------------------*

CLASS lcl_report DEFINITION DEFERRED.
TYPES : BEGIN OF gty_header.
          INCLUDE TYPE zncprh_s026.
          TYPES : rowcolor(4),
        END OF gty_header.

TYPES : BEGIN OF gty_item.
          INCLUDE TYPE zncprh_s027.
          TYPES : rowcolor(4) TYPE c,
          celltab     TYPE lvc_t_styl,
        END OF gty_item.

DATA : gr_report TYPE REF TO lcl_report.

DATA : gt_header       TYPE TABLE OF gty_header,
       gs_header       LIKE LINE OF gt_header,
       gt_item         TYPE TABLE OF gty_item,
       gt_item_default TYPE TABLE OF gty_item,
       gt_item_main    TYPE TABLE OF gty_item,
       gs_item         LIKE LINE OF gt_item.
