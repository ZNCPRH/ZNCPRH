*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P035_I003
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_001'.  " contains push button "DETAIL"
*  SET TITLEBAR 'xxx'.


* Refresh display of detail ALV list
  CALL METHOD go_grid2->refresh_table_display
*    EXPORTING
*      IS_STABLE      =
*      I_SOFT_REFRESH =
    EXCEPTIONS
      OTHERS = 2.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  TRANSLATE gd_okcode TO UPPER CASE.

  IF sy-ucomm EQ '&F03'.
    SET SCREEN 0. LEAVE SCREEN.
  ENDIF.

  CASE sy-ucomm.
    WHEN 'BACK' OR
         'EXIT' OR
         'CANC' OR
         '&F03' OR
         '&F12' .
      SET SCREEN 0. LEAVE SCREEN.

*   User has pushed button "Display Details"
    WHEN 'DETAIL'.
      lcl_eventhandler=>customer_show_details( ).
    WHEN 'FULLSCREEN'.
      lcl_eventhandler=>toggle_display( ).
    WHEN OTHERS.
  ENDCASE.

  CLEAR: gd_okcode.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
