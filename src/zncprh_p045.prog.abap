*&---------------------------------------------------------------------*
*& Report ZNCPRH_P045
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p045.

INCLUDE zncprh_p045_i001.
INCLUDE zncprh_p045_i002.

INITIALIZATION.

  DATA(gc_class) = NEW lcl_class( ).
*
START-OF-SELECTION.
  gc_class->modify_data( ).


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  gc_class->get_filename( CHANGING file = p_file ).
