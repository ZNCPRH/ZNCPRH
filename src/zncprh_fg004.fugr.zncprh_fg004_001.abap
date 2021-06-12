FUNCTION ZNCPRH_FG004_001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(EV_JSON) TYPE  STRING
*"----------------------------------------------------------------------


DATA : lt_object TYPE TABLE OF objec,
         lt_struct TYPE TABLE OF struc,
         lt_gdstr  TYPE TABLE OF gdstr.

  TYPES: BEGIN OF ty_data,
           objid  TYPE             hrobjid,
           seqnr  TYPE             numc10,
           parent TYPE             numc10,
           json   TYPE             string,
         END OF ty_data.

  DATA: lt_data TYPE TABLE OF    ty_data,
        ls_data TYPE             ty_data,
        json    TYPE             string.

  DATA: lv_slmtn   TYPE   string,
        lv_sprnt   TYPE   string,
        lv_sgmtn   TYPE   string,
        lv_src     TYPE   string,
        lv_jsn     TYPE   string,
        lv_bin_len TYPE   i,
        ls_match   TYPE   match_result.

  DATA: lv_cnt  TYPE i,
        lv_cnt1 TYPE i,
        lv_cnt2 TYPE i.


  DEFINE prepare_json.
    REPLACE ALL OCCURRENCES OF: '"' IN &1 WITH '\"' , '"' IN &2 WITH '\"'.
    json =   '   { "SAPCode": "'        && &1   && '",' &&
             '   "ParentSAPCode": [ ' &&  ' ' && &2   && '∩' && &3 && ' ] } ' .
  END-OF-DEFINITION.

  SELECT DISTINCT objid FROM hrp9300
*    INNER JOIN hrp1001 AS hr1001 ON  hr1001~otype EQ 'O'
*                                 AND hr1001~objid EQ hr93~objid
*                                 AND hr1001~plvar EQ '01'
*                                 AND hr1001~rsign EQ 'A'
*                                 AND hr1001~relat EQ '002'
*                                 AND hr1001~istat EQ '1'
*                                 AND hr1001~begda LE @sy-datum
*                                 AND hr1001~endda GE @sy-datum
     INTO TABLE @DATA(lt_hrp9300)
       WHERE plvar  EQ '01'
       AND   otype  EQ 'O'
       AND   istat  EQ '1'
       AND   begda  LE @sy-datum
       AND   endda  GE @sy-datum
       AND   obtype GE 80.


  CHECK lt_hrp9300 IS NOT INITIAL.

  SELECT objid FROM hrp1001 INTO TABLE @DATA(lt_hrp1001)
    FOR ALL ENTRIES IN @lt_hrp9300
    WHERE objid EQ @lt_hrp9300-objid
    AND   otype EQ 'O'
    AND   plvar EQ '01'
    AND   rsign EQ 'A'
    AND   relat EQ '002'
    AND   istat EQ '1'
    AND   begda LE @sy-datum
    AND   endda GE @sy-datum.


  LOOP AT lt_hrp9300 INTO DATA(ls_hrp9300).

    READ TABLE lt_hrp1001 TRANSPORTING NO FIELDS
               WITH KEY objid = ls_hrp9300-objid.

    CHECK sy-subrc EQ 0.

    CALL FUNCTION 'RH_PM_GET_STRUCTURE'
      EXPORTING
        plvar           = '01'
        otype           = 'O'
        objid           = ls_hrp9300-objid
        begda           = sy-datum
        endda           = sy-datum
        wegid           = 'O-O'
      TABLES
        objec_tab       = lt_object
        struc_tab       = lt_struct
        gdstr_tab       = lt_gdstr
      EXCEPTIONS
        not_found       = 1
        ppway_not_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT lt_struct INTO DATA(ls_struct).

      ls_data-objid  = ls_struct-objid.
      ls_data-seqnr  = ls_struct-seqnr.
      ls_data-parent = ls_struct-pup.

      prepare_json ls_data-objid ls_data-seqnr ls_data-parent.

      ls_data-json = json.

      APPEND ls_data TO lt_data.
      CLEAR:json,ls_data.
    ENDLOOP.

    SORT lt_data BY seqnr parent.
    LOOP AT lt_data INTO ls_data.
      IF ls_data-parent IS INITIAL.
        IF ev_json IS INITIAL.
          ev_json = '[' && ev_json  && ls_data-json.
        ELSE.
          ev_json = ev_json  && ',' &&  ls_data-json.
        ENDIF.
      ELSE.
        CLEAR lv_src.

        lv_src =  ls_data-parent.
        CLEAR ls_match.
        FIND ALL OCCURRENCES OF lv_src IN ev_json RESULTS ls_match.
        CHECK ls_match-offset NE 0.


        lv_slmtn = ev_json(ls_match-offset).
        lv_sprnt = ev_json+ls_match-offset(21).

        lv_cnt  = strlen( lv_slmtn ).
        lv_cnt2 = strlen( ev_json ) -  strlen( lv_slmtn ).
        lv_sgmtn = ev_json+lv_cnt(lv_cnt2).
        CONCATENATE lv_slmtn   ls_data-json  ',' lv_sgmtn INTO ev_json.
      ENDIF.

    ENDLOOP.
    SHIFT ev_json LEFT DELETING LEADING ','.
    CONDENSE ev_json.

    REFRESH : lt_struct,lt_object,lt_gdstr,lt_data.
    CLEAR : lv_src,ls_match,lv_slmtn,lv_sprnt.
    CLEAR : lv_cnt,lv_cnt2,lv_sgmtn,lv_cnt1.

    WHILE 1 EQ 1.
      SEARCH ev_json FOR '∩' .
      IF sy-fdpos IS NOT INITIAL.
        lv_cnt1  = sy-fdpos - 10.
        lv_cnt2  = sy-fdpos + 11.
        lv_cnt   = strlen( ev_json ) - 21 - lv_cnt1.

        lv_slmtn = ev_json(lv_cnt1).
        lv_sgmtn = ev_json+lv_cnt2(lv_cnt).
        CLEAR ev_json.
        CONCATENATE   lv_slmtn lv_sgmtn INTO ev_json.
      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.

    REPLACE ALL OCCURRENCES OF '[ ] }, ]' IN ev_json WITH '[ ] } ]'.
    REPLACE ALL OCCURRENCES OF '} ] }, ]' IN ev_json WITH '} ] } ]'.

    REPLACE ALL OCCURRENCES OF '} ] }, ]' IN ev_json WITH '} ] } ]'.
    REPLACE ALL OCCURRENCES OF '} ] }, ]' IN ev_json WITH '} ] } ]'.

    REFRESH : lt_struct,lt_object,lt_gdstr,lt_data.
    CLEAR : lv_src,ls_match,lv_slmtn,lv_sprnt.
    CLEAR : lv_cnt,lv_cnt2,lv_sgmtn,lv_cnt1.
  ENDLOOP.


  DATA(ev_json_str) = strlen( ev_json ).
  ev_json_str = ev_json_str - 1.
  IF ev_json+ev_json_str(1) NE ']'.
    ev_json = ev_json && ']'.
  ENDIF.


ENDFUNCTION.
