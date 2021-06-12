*&---------------------------------------------------------------------*
*& Report ZNCPRH_P035
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p035.

INCLUDE zncprh_p035_i001.
INCLUDE zncprh_p035_i002.
INCLUDE zncprh_p035_i003.

START-OF-SELECTION.

  lcl_eventhandler=>get_data( ).

  lcl_eventhandler=>init_controls( ).

  lcl_eventhandler=>link_container( ).

END-OF-SELECTION.

  CALL SCREEN 0100.
