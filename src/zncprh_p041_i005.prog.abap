*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P041_I005
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'GUI'.
  SET TITLEBAR 'TITLE'.

  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE  sy-ucomm.
    WHEN 'BACK' OR '%EX' OR' RW' OR '&F03' OR '&F12'.
      LEAVE TO SCREEN 0.
    WHEN ''.
    WHEN OTHERS .
      CALL METHOD cl_gui_cfw=>dispatch.
  ENDCASE.

  CALL METHOD cl_gui_cfw=>flush.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'GUI'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.
  CASE  sy-ucomm.
    WHEN 'BACK' OR '%EX' OR' RW'.
      LEAVE TO SCREEN 0.
    ENDCASE.

ENDMODULE.                 " USER_COMMAND_0101  INPUT
