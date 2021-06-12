*&---------------------------------------------------------------------*
*& Report ZNCPRH_P032
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p032.

INCLUDE zncprh_p032_i001.
INCLUDE zncprh_p032_i002.
INCLUDE zncprh_p032_i003.


INITIALIZATION.


  IF g_object IS NOT BOUND.
    CREATE OBJECT g_object.
  ENDIF.
  g_object->init( ).

  SELECTION-SCREEN FUNCTION KEY 1.

AT SELECTION-SCREEN.
  g_object->at_selection_screen( ).

AT SELECTION-SCREEN OUTPUT.
  g_object->at_selection_output( ).

  IF gv_infty IS INITIAL.
    gv_infty = p_infty.
  ENDIF.


  IF p_file IS NOT INITIAL AND gv_infty NE p_infty.
    CLEAR p_file.
  ENDIF.

  LOOP AT SCREEN.
    IF  screen-name EQ 'DMODE'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


* at selection screen on value request for ..
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file .
  g_object->get_file_name( ).


* start of selection ..
START-OF-SELECTION .

  g_object->fill_fcat( ).
  g_object->get_data( ).

* end of selection ..
END-OF-SELECTION .
  g_object->handle_user_command_click1( ).

  CALL SCREEN 0100 .
