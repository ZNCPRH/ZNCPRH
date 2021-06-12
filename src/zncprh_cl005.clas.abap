
CLASS zncprh_cl005  DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS create
      IMPORTING
        VALUE(it_fcat)  TYPE lvc_t_fcat
      RETURNING
        VALUE(r_object) TYPE REF TO zncprh_cl005 .
    METHODS create_structure
      RETURNING
        VALUE(rs_structure) TYPE REF TO data .
    METHODS create_table
      IMPORTING
        VALUE(i_table_kind) TYPE abap_tablekind DEFAULT cl_abap_tabledescr=>tablekind_std
      RETURNING
        VALUE(rt_table)     TYPE REF TO data .
    METHODS free .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA m_object TYPE REF TO zncprh_cl005 .
    DATA mt_components TYPE REF TO cl_abap_structdescr=>component_table .
    DATA m_structure TYPE REF TO cl_abap_structdescr .

    METHODS create_components
      IMPORTING
        VALUE(it_fcat) TYPE lvc_t_fcat .
    METHODS create_structure_type .
ENDCLASS.



CLASS ZNCPRH_CL005 IMPLEMENTATION.


  METHOD create.
    IF it_fcat[] IS INITIAL.
* TODO raise empty fieldcatalog.
    ENDIF.

    IF m_object IS INITIAL.
      m_object = NEW zncprh_cl005( ).

      m_object->create_components( it_fcat ).
    ENDIF.

    r_object = m_object.
  ENDMETHOD.


  METHOD create_components.
    DATA : l_field TYPE REF TO data.
    DATA : lo_data TYPE REF TO cl_abap_datadescr.

    me->mt_components = NEW #( ).
    LOOP AT it_fcat
       INTO DATA(ls_fcat).

      CASE ls_fcat-inttype.
        WHEN 'C'.
          CREATE DATA l_field TYPE c LENGTH ls_fcat-intlen.
        WHEN 'N'.
          CREATE DATA l_field TYPE n LENGTH ls_fcat-intlen.
        WHEN 'P'.
          CREATE DATA l_field TYPE p LENGTH ls_fcat-intlen DECIMALS ls_fcat-decimals.
        WHEN 'D'.
          CREATE DATA l_field TYPE d.
        WHEN 'T'.
          CREATE DATA l_field TYPE t.
        WHEN 'F'.
          CREATE DATA l_field TYPE f.
        WHEN 'I'.
          CREATE DATA l_field TYPE i.
        WHEN 'X'.
          CREATE DATA l_field TYPE x.
      ENDCASE.

      CHECK l_field IS NOT INITIAL.

      lo_data ?= cl_abap_datadescr=>describe_by_data_ref( l_field ).

      CHECK lo_data IS NOT INITIAL.

      APPEND VALUE #( name = ls_fcat-fieldname
                      type = lo_data )
          TO me->mt_components->*.

      FREE : lo_data,
             l_field.
    ENDLOOP.
  ENDMETHOD.


  METHOD create_structure.
    IF me->m_structure IS INITIAL.
* TODO raise no structure type.
    ENDIF.

    CREATE DATA rs_structure TYPE HANDLE me->m_structure.
  ENDMETHOD.


  METHOD create_structure_type.
    TRY.
        me->m_structure ?= cl_abap_structdescr=>create( p_components = me->mt_components->* ).
      CATCH cx_sy_struct_creation INTO DATA(oref).  "
        DATA(l_text) = oref->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD create_table.
    DATA : lo_table TYPE REF TO cl_abap_tabledescr.

    IF me->m_structure IS INITIAL.
      me->create_structure_type( ).
    ENDIF.

    TRY.
        lo_table ?= cl_abap_tabledescr=>create( p_line_type  = me->m_structure
                                                p_table_kind = i_table_kind

                                              ).
      CATCH cx_sy_table_creation INTO DATA(oref).    "
        DATA(l_text) = oref->get_text( ).
    ENDTRY.

    CREATE DATA rt_table TYPE HANDLE lo_table.
  ENDMETHOD.


  METHOD free.
    FREE : m_object,
           mt_components,
           m_structure.
  ENDMETHOD.
ENDCLASS.
