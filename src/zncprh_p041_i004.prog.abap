*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P041_I004
*&---------------------------------------------------------------------*

INITIALIZATION.

  IF gr_report IS INITIAL.
    CREATE OBJECT gr_report.
  ENDIF.

  IF gr_convert IS INITIAL.
    CREATE OBJECT gr_convert.
  ENDIF.

  gr_report->initialization( ).

AT SELECTION-SCREEN.

  gr_report->at_selection_screen( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR soprog-low.

  gr_report->at_selection_screen_s_program( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR soclass-low.

  gr_report->at_selection_screen_s_class( ).

START-OF-SELECTION.

  gr_report->start_of_selection( ).

END-OF-SELECTION.

  gr_report->end_of_selection( ).
