*&---------------------------------------------------------------------*
*& Report ZNCPRH_P031
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p031.

INCLUDE zncprh_p031_i001.
INCLUDE zncprh_p031_i002.


INITIALIZATION.

  DATA(gc_class) = NEW lcl_class( ).
  sscrfields-functxt_01 = gc_batch && TEXT-002 .

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  gc_class->get_filename( CHANGING file = p_file ).


AT SELECTION-SCREEN.

  gc_class->click_example( ).

START-OF-SELECTION.
  gc_class->modify_data( ).
