*&---------------------------------------------------------------------*
*& Report ZNCPRH_P004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p004.

DATA : itab TYPE REF TO data.
DATA : struct TYPE extdfiest,
       wa     TYPE extdfies.
CREATE DATA itab TYPE TABLE OF ('ZNCPRH_S001').

struct = zncprh_cl008=>get_table_structure( itab = itab ).

BREAK-POINT.
