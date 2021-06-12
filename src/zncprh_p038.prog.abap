*&---------------------------------------------------------------------*
*& Report ZNCPRH_P038
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p038.

DATA: lv_icon_xstr TYPE            xstring,
      lv_icon_url  TYPE            string.
*             ls_icon          TYPE            /dsl/oc_s015.


END-OF-SELECTION.
  CALL SCREEN 0101.

MODULE user_command_0101 INPUT.
  IF sy-ucomm EQ 'F12'.
    RETURN.
  ENDIF.
  ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.

*
*
  DATA: w_lines TYPE i.
  TYPES pict_line(256) TYPE c.
  DATA: container TYPE REF TO cl_gui_custom_container,
        editor    TYPE REF TO cl_gui_textedit,
        picture   TYPE REF TO cl_gui_picture,
        pict_tab  TYPE TABLE OF pict_line,
        url(255)  TYPE c.
  DATA: graphic_url(255).
  DATA: BEGIN OF graphic_table OCCURS 0,
          line(255) TYPE x,
        END OF graphic_table.
  DATA: l_graphic_conv TYPE i.
  DATA: l_graphic_offs TYPE i.
  DATA: graphic_size TYPE i.
  DATA: l_graphic_xstr TYPE xstring.

  CALL METHOD cl_gui_cfw=>flush.
  CREATE OBJECT:
      container EXPORTING container_name = 'CONT01',
      picture EXPORTING parent = container.
*Method which takes the object "WINNY" - uploaded through SE78
*into the ABAP memory. Change name to object to be displayed in
*screen


  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object = 'GRAPHICS'
      p_name   = 'HES'
      p_id     = 'BMAP'
      p_btype  = 'BCOL'
    RECEIVING
      p_bmp    = l_graphic_xstr.

  graphic_size = xstrlen( l_graphic_xstr ).
  l_graphic_conv = graphic_size.
  l_graphic_offs = 0.
  WHILE l_graphic_conv > 255.
    graphic_table-line = l_graphic_xstr+l_graphic_offs(255).
    APPEND graphic_table.
    l_graphic_offs = l_graphic_offs + 255.
    l_graphic_conv = l_graphic_conv - 255.
  ENDWHILE.
  graphic_table-line = l_graphic_xstr+l_graphic_offs(l_graphic_conv).
  APPEND graphic_table.
  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type     = 'IMAGE'
      subtype  = 'X-UNKNOWN'
      size     = graphic_size
      lifetime = 'T'
    TABLES
      data     = graphic_table
    CHANGING
      url      = url.
  CALL METHOD picture->load_picture_from_url
    EXPORTING
      url = url.
  CALL METHOD picture->set_display_mode
    EXPORTING
      display_mode = picture->display_mode_fit_center.
ENDMODULE.                 " STATUS_9000  OUTPUT
