*&---------------------------------------------------------------------*
*& Report ZNCPRH_P053
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p053.

INCLUDE zncprh_p053_i001.
INCLUDE zncprh_p053_i002.
INCLUDE zncprh_p053_i003.
INCLUDE zncprh_p053_i004.

INITIALIZATION.

  g_object = NEW #( ).

START-OF-SELECTION.
  g_object->get_data( ).

END-OF-SELECTION.
  g_object->container_alv( EXPORTING  iv_tabnam   = gv_tabname
                                      iv_strucnam = gv_strname  ).

  CALL SCREEN 100.
