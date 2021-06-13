*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P053_I004
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       MODULE PBO OUTPUT                                             *
*---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  SET PF-STATUS 'MAIN100'.
  SET TITLEBAR 'MAIN100'.
ENDMODULE.

MODULE pai INPUT.
  CASE sy-ucomm.
    WHEN '&F03' OR '&F12' OR '&F15'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN OTHERS.
*     do nothing
  ENDCASE.
ENDMODULE.
