*&---------------------------------------------------------------------*
*& Report ZNCPRH_P033
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p033.

INCLUDE zncprh_p033_i001.
INCLUDE zncprh_p033_i002.
INCLUDE zncprh_p033_i003.

INITIALIZATION.
  gr_report = NEW lcl_report( ) .
  gr_report->set_initial( ).

START-OF-SELECTION.
  gr_report->get_data( ).

END-OF-SELECTION.
  IF lines( gt_header ) <> 0.
    gr_report->call_screen( ).
  ENDIF.
