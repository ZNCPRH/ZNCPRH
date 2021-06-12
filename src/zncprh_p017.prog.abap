*&---------------------------------------------------------------------*
*& Report ZNCPRH_P017
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p017.

TYPE-POOLS: shlp.


DATA:
  gd_repid  TYPE syrepid,
  gt_knb1   TYPE STANDARD TABLE OF knb1,
  gt_values TYPE STANDARD TABLE OF ddshretval.

START-OF-SELECTION.

  gd_repid = syst-repid.

  SELECT * FROM knb1 INTO TABLE gt_knb1 UP TO 100 ROWS.

  DATA : ls_f4 TYPE LINE OF ddshmarks,
         lt_f4 TYPE ddshmarks.

  ls_f4 = 0003.
  APPEND ls_f4 TO lt_f4.

  ls_f4 = 0006.
  APPEND ls_f4 TO lt_f4.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      ddic_structure   = 'KNB1'
      retfield         = 'KUNNR'  " overwritten in callback !!!
*     PVALKEY          = ' '
*     DYNPPROG         = ' '
*     DYNPNR           = ' '
*     DYNPROFIELD      = ' '
*     STEPL            = 0
*     WINDOW_TITLE     =
*     VALUE            = ' '
      value_org        = 'S'  " structure
      multiple_choice  = 'X'
*     DISPLAY          = ' '
      callback_program = gd_repid
      callback_form    = 'CALLBACK_F4'
*     MARK_TAB         = lt_f4
*   IMPORTING
*     USER_RESET       =
    TABLES
      value_tab        = gt_knb1
*     FIELD_TAB        =
      return_tab       = gt_values
*     DYNPFLD_MAPPING  =
    EXCEPTIONS
      parameter_error  = 1
      no_values_found  = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_structure_name = 'DDSHRETVAL'
    TABLES
      t_outtab         = gt_values
    EXCEPTIONS
      program_error    = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  CALLBACK_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM callback_f4
            TABLES record_tab STRUCTURE seahlpres
            CHANGING shlp TYPE shlp_descr
                     callcontrol LIKE ddshf4ctrl.
* define local data
  DATA:
    ls_intf LIKE LINE OF shlp-interface,
    ls_prop LIKE LINE OF shlp-fieldprop.



  " Hide unwanted fields
  CLEAR: ls_prop-shlpselpos,
         ls_prop-shlplispos.
  ls_prop-defaultval = 'X'.
  MODIFY shlp-fieldprop FROM ls_prop
    TRANSPORTING shlpselpos shlplispos
  WHERE ( fieldname NE 'BUKRS'  AND
          fieldname NE 'KUNNR'  AND
          fieldname NE 'PERNR' ).


  " Overwrite selectable fields on search help
  REFRESH: shlp-interface.
  ls_intf-shlpfield = 'BUKRS'.
  ls_intf-valfield  = 'X'.
  APPEND ls_intf TO shlp-interface.
  ls_intf-shlpfield = 'KUNNR'.
  APPEND ls_intf TO shlp-interface.


ENDFORM.                    " CALLBACK_F4
