class ZNCPRH_CL008 definition
  public
  final
  create public .

public section.

  class-methods KUR_DONUSUM_01
    importing
      value(I_DATE) type DATUM optional
      value(I_WAERS) type WAERS optional
      value(C_WAERS) type WAERS optional
      value(I_NETPR) type NETPR optional
    exporting
      !E_NETPR type NETPR .
  class-methods KUR_DONUSUM_02
    importing
      value(I_DATE) type DATUM optional
      value(I_WAERS) type WAERS optional
      value(C_WAERS) type WAERS optional
      value(I_NETPR) type NETPR optional
    exporting
      value(E_NETPR) type NETPR .
  class-methods VALUE_TO_BYTECODE
    importing
      value(I_VALUE) type STRING optional
    returning
      value(E_BYTE) type XSTRING .
  class-methods BYTECODE_TO_VALUE
    importing
      !I_BYTE type XSTRING
    returning
      value(E_VALUE) type STRING .
  class-methods GET_TABLE_STRUCTURE
    importing
      !ITAB type ref to DATA
    returning
      value(STRUCT) type EXTDFIEST .
protected section.
private section.
ENDCLASS.



CLASS ZNCPRH_CL008 IMPLEMENTATION.


  METHOD bytecode_to_value.
    DATA cl_ps TYPE REF TO cl_hard_wired_encryptor.
    CREATE OBJECT cl_ps.
    DATA lresult TYPE string .
    CALL METHOD cl_ps->decrypt_bytes2string
      EXPORTING
        the_byte_array = i_byte
      RECEIVING
        result         = lresult.
* CATCH cx_encrypt_error .
*ENDTRY.
*TRY.
    DATA pp TYPE string .
    CALL METHOD cl_ps->decrypt_string2string
      EXPORTING
        the_string = lresult
      RECEIVING
        result     = e_value.
  ENDMETHOD.


  METHOD get_table_structure.
    DATA: descrref   TYPE REF TO cl_abap_typedescr,
          no_header  TYPE c,
          structref  TYPE REF TO cl_abap_structdescr,
          tableref   TYPE REF TO cl_abap_tabledescr,
          l_helpid   TYPE string,
          l_typename TYPE dfies-tabname,
          l_compname TYPE dfies-fieldname,
          exttab     TYPE extdfiest,
          extwa      TYPE extdfies.

    FIELD-SYMBOLS: <t>         TYPE any,
                   <f>         TYPE any,
                   <tab>       TYPE INDEX TABLE,
                   <component> TYPE abap_compdescr.

    DATA: ddiccomptab TYPE ddfields,
          isddic      TYPE abap_bool,
          extdfies_wa LIKE LINE OF struct,
          b_no_table  TYPE c.          " flags table is not available

    FIELD-SYMBOLS <ddiccomp> TYPE dfies.

****Get a pointer to the data table
    ASSIGN itab->* TO <tab>.
***Read the first record initializing a work area and making sure it

    READ TABLE <tab> INDEX 1 ASSIGNING <t>.
    IF sy-subrc NE 0.
      b_no_table = 'X'.
    ELSE.
      b_no_table = ' '.
    ENDIF.


****Get Type Description by Data Reference
    tableref ?= cl_abap_typedescr=>describe_by_data_ref( itab ).

    TRY.
****Is the type definition a pointer to a structure?
        structref ?= tableref->get_table_line_type( ).
****Is the structure a Data Diction Type?
        isddic = structref->is_ddic_type( ).
        IF isddic EQ abap_true.
****Kernel and Dynamic data defintions can't come from the Data

          IF structref->absolute_name+6(2) EQ '%_'.
            isddic = abap_false.
          ENDIF.
        ENDIF.
        IF isddic EQ abap_true.
****Definition is in the data Dictionary- We can read details from the

****DDic Structure
          ddiccomptab = structref->get_ddic_field_list( ).
          LOOP AT ddiccomptab ASSIGNING <ddiccomp>.
            MOVE-CORRESPONDING <ddiccomp> TO extdfies_wa.
*          extdfies_wa-fieldname = <ddiccomp>-fieldname.
*          extdfies_wa-coltitle  = <ddiccomp>-reptext.
*          extdfies_wa-inttype   = <ddiccomp>-inttype.
*          extdfies_wa-convexit  = <ddiccomp>-convexit.
            APPEND extdfies_wa TO struct.
          ENDLOOP.
        ELSE.
          IF b_no_table IS INITIAL.
****Not in DDic - Get a Type description of the Workarea so we can
            descrref = cl_abap_typedescr=>describe_by_data( <t> ).
            TRY.
****Get the structure of our type description for the workarea
                structref ?= descrref.
****Loop through the list of components(fields) in our work area
                LOOP AT structref->components ASSIGNING <component>.
                  extdfies_wa-fieldname = <component>-name.
                  extdfies_wa-coltitle  = <component>-name.
****Get a pointer to the individual component(field) that we are

                  ASSIGN COMPONENT sy-tabix OF STRUCTURE <t> TO <f>.
****Ask for the help ID (F1 help) belonging to field  - this will give

****LIKE reference that this field was created from - See DESCRIBE

****Help for a useful example

                  IF l_helpid IS NOT INITIAL.
****Split the help-id into structure - element
                    SPLIT l_helpid AT '-'
                            INTO l_typename l_compname.
                    extdfies_wa-tabname = l_typename.
*****Get details about the structure or table part of the helpid
                    CALL FUNCTION 'DD_INT_TABLINFO_GET'
                      EXPORTING
                        typename       = l_typename
                      TABLES
                        extdfies_tab   = exttab
                      EXCEPTIONS
                        not_found      = 1
                        internal_error = 2
                        OTHERS         = 3.
                    IF sy-subrc EQ 0.
****Read the details about the element portion of the help-id from the
****we just received using the field name from the original component
                      READ TABLE exttab INTO extwa WITH KEY fieldname =
                  extdfies_wa-fieldname.
                      IF sy-subrc EQ 0.
                        extdfies_wa-coltitle = extwa-coltitle.
                        extdfies_wa-convexit = extwa-convexit.
                      ELSE.
****No entry for the original component name, try the one from the
                        READ TABLE exttab INTO extwa WITH KEY fieldname
                    = l_compname.
                        IF sy-subrc EQ 0.
                          extdfies_wa-coltitle = extwa-coltitle.
                          extdfies_wa-convexit = extwa-convexit.
                        ELSE.
****No Luck so far -> Lets ask the ABAP Descriptor class to try and

****using a reference to the component we are processing
                          DATA: elemref TYPE REF TO cl_abap_elemdescr,
                                ddicobj TYPE dd_x031l_table.
                          FIELD-SYMBOLS <ddic> TYPE x031l.
****Descriptor for tte Element
                          descrref = cl_abap_typedescr=>describe_by_data( <f> ).
                          TRY.
****Can we cast this to an DDic element descriptor?
                              elemref ?= descrref.
****Read the DDic defintion for this element
                              ddicobj = elemref->get_ddic_object( ).
****Get the Conversion Exit recorded in the DDic for this element
                              READ TABLE ddicobj INDEX 1 ASSIGNING <ddic>.
                              IF sy-subrc EQ 0.
                                extdfies_wa-convexit = <ddic>-convexit.
                              ENDIF.
****Catch all Global Execptions - like bad casts
                            CATCH cx_root.               "#EC CATCH_ALL
                                                        "#EC NO_HANDLER
                          ENDTRY.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
****Use Describe Field on the Element to get its basic data type
                  DESCRIBE FIELD <f> TYPE extdfies_wa-inttype.

                  APPEND extdfies_wa TO struct.
                ENDLOOP.
****Catch all Global Execptions - like bad casts
              CATCH cx_root.                             "#EC CATCH_ALL
                no_header = 'X'.
            ENDTRY.
          ELSE.
            no_header = 'X'.
          ENDIF.
        ENDIF.

****Catch all Global Execptions - like bad casts
      CATCH cx_root.                                     "#EC CATCH_ALL
        no_header = 'X'.
    ENDTRY.
  ENDMETHOD.


  METHOD kur_donusum_01.
    DATA : lv_kursf TYPE  kursf,
           lv_netpr TYPE netpr.
    " lv_netpr TYPE FINS_VTCUR12 ." netpr.
    IF  i_waers = c_waers.
      e_netpr = i_netpr.
    ELSE.
      CASE i_waers.
        WHEN 'TRY'.
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
            EXPORTING
*             CLIENT           = SY-MANDT
              date             = i_date
              foreign_amount   = 1
              foreign_currency = i_waers
              local_currency   = c_waers
              type_of_rate     = 'M'
            IMPORTING
              exchange_rate    = lv_kursf
            EXCEPTIONS
              no_rate_found    = 1
              overflow         = 2
              no_factors_found = 3
              no_spread_found  = 4
              derived_2_times  = 5
              OTHERS           = 6.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ELSE.
            lv_netpr = lv_kursf * i_netpr.
          ENDIF.

        WHEN OTHERS.
          CASE c_waers.
            WHEN 'TRY'.
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
*                 CLIENT           = SY-MANDT
                  date             = i_date
                  foreign_amount   = 1
                  foreign_currency = i_waers
                  local_currency   = 'TRY'
                  type_of_rate     = 'M'
                IMPORTING
                  exchange_rate    = lv_kursf
                EXCEPTIONS
                  no_rate_found    = 1
                  overflow         = 2
                  no_factors_found = 3
                  no_spread_found  = 4
                  derived_2_times  = 5
                  OTHERS           = 6.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ELSE.
                lv_netpr = lv_kursf * i_netpr.
              ENDIF.
            WHEN OTHERS.
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
*                 CLIENT           = SY-MANDT
                  date             = i_date
                  foreign_amount   = 1
                  foreign_currency = i_waers
                  local_currency   = 'TRY'
                  type_of_rate     = 'M'
                IMPORTING
                  exchange_rate    = lv_kursf
                EXCEPTIONS
                  no_rate_found    = 1
                  overflow         = 2
                  no_factors_found = 3
                  no_spread_found  = 4
                  derived_2_times  = 5
                  OTHERS           = 6.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ELSE.
                lv_netpr = lv_kursf * i_netpr.
                CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                  EXPORTING
*                   CLIENT           = SY-MANDT
                    date             = i_date
                    foreign_amount   = 1
                    foreign_currency = 'TRY'
                    local_currency   = c_waers
                    type_of_rate     = 'M'
                  IMPORTING
                    exchange_rate    = lv_kursf
                  EXCEPTIONS
                    no_rate_found    = 1
                    overflow         = 2
                    no_factors_found = 3
                    no_spread_found  = 4
                    derived_2_times  = 5
                    OTHERS           = 6.
                IF sy-subrc <> 0.
* Implement suitable error handling here
                ELSE.
                  lv_netpr = lv_kursf * lv_netpr.
                ENDIF.

              ENDIF.
          ENDCASE.

      ENDCASE.

      e_netpr = lv_netpr.
    ENDIF.

  ENDMETHOD.


  METHOD kur_donusum_02.
    DATA : lv_kursf TYPE  kursf,
           lv_netpr TYPE fins_vtcur12 . " netpr.
    IF  i_waers = c_waers.
      e_netpr = i_netpr.
    ELSE.
      CASE i_waers.
        WHEN 'TRY'.
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
            EXPORTING
*             CLIENT           = SY-MANDT
              date             = i_date
              foreign_amount   = 1
              foreign_currency = i_waers
              local_currency   = c_waers
              type_of_rate     = 'Y'
            IMPORTING
              exchange_rate    = lv_kursf
            EXCEPTIONS
              no_rate_found    = 1
              overflow         = 2
              no_factors_found = 3
              no_spread_found  = 4
              derived_2_times  = 5
              OTHERS           = 6.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ELSE.
            lv_netpr = lv_kursf * i_netpr.
          ENDIF.

        WHEN OTHERS.
          CASE c_waers.
            WHEN 'TRY'.
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
*                 CLIENT           = SY-MANDT
                  date             = i_date
                  foreign_amount   = 1
                  foreign_currency = i_waers
                  local_currency   = 'TRY'
                  type_of_rate     = 'Y'
                IMPORTING
                  exchange_rate    = lv_kursf
                EXCEPTIONS
                  no_rate_found    = 1
                  overflow         = 2
                  no_factors_found = 3
                  no_spread_found  = 4
                  derived_2_times  = 5
                  OTHERS           = 6.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ELSE.
                lv_netpr = lv_kursf * i_netpr.
              ENDIF.
            WHEN OTHERS.
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
*                 CLIENT           = SY-MANDT
                  date             = i_date
                  foreign_amount   = 1
                  foreign_currency = i_waers
                  local_currency   = 'TRY'
                  type_of_rate     = 'Y'
                IMPORTING
                  exchange_rate    = lv_kursf
                EXCEPTIONS
                  no_rate_found    = 1
                  overflow         = 2
                  no_factors_found = 3
                  no_spread_found  = 4
                  derived_2_times  = 5
                  OTHERS           = 6.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ELSE.
                lv_netpr = lv_kursf * i_netpr.
                CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                  EXPORTING
*                   CLIENT           = SY-MANDT
                    date             = i_date
                    foreign_amount   = 1
                    foreign_currency = 'TRY'
                    local_currency   = c_waers
                    type_of_rate     = 'Y'
                  IMPORTING
                    exchange_rate    = lv_kursf
                  EXCEPTIONS
                    no_rate_found    = 1
                    overflow         = 2
                    no_factors_found = 3
                    no_spread_found  = 4
                    derived_2_times  = 5
                    OTHERS           = 6.
                IF sy-subrc <> 0.
* Implement suitable error handling here
                ELSE.
                  lv_netpr = lv_kursf * lv_netpr.
                ENDIF.

              ENDIF.
          ENDCASE.

      ENDCASE.

      e_netpr = lv_netpr.
    ENDIF.

  ENDMETHOD.


  METHOD value_to_bytecode.
    DATA cl_ps TYPE REF TO cl_hard_wired_encryptor.
    CREATE OBJECT cl_ps.
    DATA ll TYPE string.
*TRY.
    CALL METHOD cl_ps->encrypt_string2string
      EXPORTING
        the_string = i_value
      RECEIVING
        result     = ll.
* CATCH cx_encrypt_error .
*ENDTRY.
*TRY.
    DATA lx TYPE xstring.
    CALL METHOD cl_ps->encrypt_string2bytes
      EXPORTING
        the_string = ll
      RECEIVING
        result     = e_byte.
  ENDMETHOD.
ENDCLASS.
