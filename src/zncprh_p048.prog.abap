*&---------------------------------------------------------------------*
*& Report ZNCPRH_P048
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p048.
PARAMETERS : p_carrid TYPE sflight-carrid,
             p_connid TYPE sflight-connid.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_connid.

  DATA : BEGIN OF f4_tab OCCURS 0,
           carrid TYPE sflight-carrid,
           connid TYPE sflight-connid,
         END OF f4_tab.
*   CLEAR lin.


  DATA : dynpread TYPE TABLE OF dynpread WITH HEADER LINE.
  REFRESH dynpread.
  CLEAR dynpread.
  dynpread-fieldname = 'P_CARRID'.

  APPEND dynpread.
  CLEAR dynpread.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dynpread
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc IS INITIAL.
    READ TABLE dynpread WITH KEY fieldname = 'P_CARRID'.
    IF sy-subrc IS INITIAL.
      SELECT carrid connid FROM sflight
            INTO TABLE f4_tab
             WHERE carrid = dynpread-fieldvalue.
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = 'CONNID'
          dynpprog    = sy-repid
          dynpnr      = sy-dynnr
          dynprofield = 'P_CONNID'
          value_org   = 'S'
        TABLES
          value_tab   = f4_tab.
    ENDIF.
  ENDIF.
