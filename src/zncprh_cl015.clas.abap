CLASS zncprh_cl015 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    CLASS-METHODS: stringdata_string_operation
                   FOR TABLE FUNCTION zncprh_cds018.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zncprh_cl015 IMPLEMENTATION.
  METHOD stringdata_string_operation
         BY DATABASE FUNCTION FOR HDB LANGUAGE
         SQLSCRIPT OPTIONS READ-ONLY
         USING zncprh_t012.
    RETURN SELECT id AS id,
                      id_desc AS id_desc,
                      substr_before ( substr_after( id_desc , '_' ), '.' ) as required_value
                      FROM zncprh_t012 ;
  ENDMETHOD.
ENDCLASS.
