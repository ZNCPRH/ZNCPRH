*&---------------------------------------------------------------------*
*& Report ZNCPRH_P021
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p021.

INCLUDE : zncprh_p021_i001,
          zncprh_p021_i002.

INITIALIZATION.

  PERFORM init.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM sub_file_f4.

START-OF-SELECTION.

  PERFORM start_of_sel.
