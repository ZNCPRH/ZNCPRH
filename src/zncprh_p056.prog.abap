*&---------------------------------------------------------------------*
*& Report ZNCPRH_P056
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p056.

INCLUDE zncprh_p056_i001.
INCLUDE zncprh_p056_i002.

INITIALIZATION.
  CREATE OBJECT go_main.
  go_main->init( ).

AT SELECTION-SCREEN OUTPUT.
  go_main->at_sel_scr( ).

START-OF-SELECTION.
  go_main->get_image( ).

END-OF-SELECTION.
  go_main->set_image( ).
