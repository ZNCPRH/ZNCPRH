*&---------------------------------------------------------------------*
*& Report ZNCPRH_P005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p005.

INCLUDE : zncprh_p005_i001,
          zncprh_p005_i002.

INITIALIZATION.
  IF obj IS INITIAL.
    CREATE OBJECT obj.
  ENDIF.

START-OF-SELECTION.
  obj->get_submit_ziw58( ).
  obj->get_submit_zerp32( ).

END-OF-SELECTION.
  obj->get_excell_ziw58( ).
  obj->get_excell_zerp32( ).
  obj->get_mail( ).
