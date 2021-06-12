*&---------------------------------------------------------------------*
*& Report ZNCPRH_P051
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p051.

PARAMETERS : p_connid TYPE spfli-connid MATCHCODE OBJECT zncprh_sh001,
             "ZNCPRH_FG001_002 SH Exit FM  exiti
             p_ctyfr  TYPE spfli-cityfrom MODIF ID m1,
             p_ctyto  TYPE spfli-cityto MODIF ID m1.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-group1 EQ 'M1'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
