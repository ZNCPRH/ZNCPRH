*&---------------------------------------------------------------------*
*& Report ZNCPRH_P510
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p510.

INCLUDE zncprh_p510_i001.
INCLUDE zncprh_p510_i002.
INCLUDE zncprh_p510_i003.
INCLUDE zncprh_p510_i004.

START-OF-SELECTION.


  SELECT * FROM usr02 UP TO 30 ROWS
    APPENDING CORRESPONDING FIELDS OF TABLE gt_usr
    ORDER BY bname.

  PERFORM create_fieldcat.

  CALL SCREEN 0100.
