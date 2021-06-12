CLASS zncprh_cl013 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    TYPES: BEGIN OF ty_vbeln,
             vbeln TYPE vbeln,
             ernam TYPE ernam,
           END OF ty_vbeln,
           tt_vbeln TYPE TABLE OF ty_vbeln.

    CLASS-METHODS :
      insert_ IMPORTING VALUE(iv_client) TYPE mandt,
      delete_ IMPORTING VALUE(iv_client) TYPE mandt,
      update_ IMPORTING VALUE(iv_client) TYPE mandt
      .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zncprh_cl013 IMPLEMENTATION.
  METHOD insert_ BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
                    USING vbak zncprh_t008.

    tt_vbeln = SELECT mandt , vbeln , ernam FROM vbak WHERE mandt = iv_client;

    insert into zncprh_t008 SELECT * FROM :tt_vbeln;
  ENDMETHOD.

  METHOD delete_ BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
                    USING vbak zncprh_t008.
    tt_vbeln = SELECT mandt , vbeln , ernam FROM vbak WHERE mandt = iv_client;
    DELETE FROM  zncprh_t008 WHERE vbeln in ( select vbeln FROM :tt_vbeln );
  ENDMETHOD.

  METHOD update_ BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
                    USING vbak zncprh_t008.
    tt_vbeln = SELECT mandt , vbeln , ernam
               FROM vbak WHERE mandt = iv_client;

    UPDATE zncprh_t008 SET ernam = 'Reha'
    WHERE mandt = iv_client
    AND vbeln in ( select vbeln FROM :tt_vbeln ) ;

  ENDMETHOD.

ENDCLASS.
