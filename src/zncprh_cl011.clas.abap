CLASS zncprh_cl011 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    "//AMDPnin kimliğini belirten interface
  CONSTANTS: gv_vblen TYPE vbeln VALUE '2'.
    TYPES:
      BEGIN OF ty_op,
        sign(1)   TYPE c,
        option(2) TYPE c,
        low(10)   TYPE c,
        high(10)  TYPE c,
      END OF ty_op .
    TYPES:
      tt_op TYPE TABLE OF ty_op .
    TYPES:
      tt_vbak TYPE TABLE OF vbak .
**********************************************************************
    TYPES:
      BEGIN OF ty_itab,
        mandt TYPE mandt,
        bukrs TYPE bukrs,
        belnr TYPE belnr_d,
        gjahr TYPE gjahr,
        buzei TYPE buzei,
      END OF ty_itab .
    TYPES:
      tt_itab TYPE TABLE OF zncprh_ddl003 .
    TYPES:
      gt_tmp TYPE TABLE OF zncprh_ddl003 .
**********************************************************************
    METHODS: get_data_between
      IMPORTING VALUE(it_vbeln) TYPE tt_op
      EXPORTING VALUE(et_vbak)  TYPE tt_vbak,
      get_data_dynamic
        IMPORTING VALUE(iv_where) TYPE string
        EXPORTING VALUE(et_data)  TYPE tt_itab.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zncprh_cl011 IMPLEMENTATION.
  METHOD get_data_between BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
         OPTIONS READ-ONLY USING vbak.
    et_vbak = SELECT * FROM vbak
              WHERE vbeln BETWEEN
                ( select low from :it_vbeln ) and ( select high from :it_vbeln  )
                order by vbeln;
  ENDMETHOD.
  METHOD get_data_dynamic BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
         OPTIONS READ-ONLY USING zncprh_ddl003.

    gt_tmp = select distinct * from ZNCPRH_DDL003;
    et_data = APPLY_FILTER ( :gt_tmp , :iv_where );

  ENDMETHOD.
ENDCLASS.
