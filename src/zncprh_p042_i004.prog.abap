*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P042_I004
*&---------------------------------------------------------------------*
*----------------------------------------------------------------*

INITIALIZATION.

  IF cl IS INITIAL.
    CREATE OBJECT cl.
  ENDIF.

  cl->pj01_fieldcatalog( ).

  cl->pj01r_fieldcatalog( ).

  cl->container_alv( ).

  cl->exclude_functions( ).


START-OF-SELECTION.

  cl->selects( ).

END-OF-SELECTION.

  cl->pj01_alv( ).

  CALL SCREEN 0100.
