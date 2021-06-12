class ZNCPRH_CL006 definition
  public
  final
  create public .

public section.

  class-methods CREATE_ITAB_DYN
    importing
      !IV_GJAHR_BEG type GJAHR
      !IV_GJAHR_END type GJAHR
      !IV_ROW type DATA
      !IV_COL type DATA
    exporting
      !ER_DATA type ref to DATA .
protected section.
private section.
ENDCLASS.



CLASS ZNCPRH_CL006 IMPLEMENTATION.


  METHOD create_itab_dyn.
    FIELD-SYMBOLS:
      <lt_tab>  TYPE STANDARD TABLE,
      <ls_line> TYPE any,
      <lv_type> TYPE any.
    DATA:
      go_descriptor  TYPE REF TO cl_abap_structdescr,
      lo_structdescr TYPE REF TO cl_abap_structdescr,
      lo_typedescr   TYPE REF TO cl_abap_typedescr,
      lo_tabledescr  TYPE REF TO cl_abap_tabledescr,
      ls_descriptor  TYPE abap_compdescr,
      lt_comp_all    TYPE cl_abap_structdescr=>component_table.
    FIELD-SYMBOLS:
      <component>            TYPE LINE OF abap_component_tab.
    DATA:
      lt_key   TYPE abap_keydescr_tab,
      lv_dim   TYPE uj_dim_member,
      lv_count TYPE i,
      lv_gjahr TYPE gjahr.
    go_descriptor ?= cl_abap_typedescr=>describe_by_data( iv_row ).
    LOOP AT go_descriptor->components INTO ls_descriptor.
      ASSIGN COMPONENT ls_descriptor-name OF STRUCTURE iv_row TO <lv_type>.
      APPEND INITIAL LINE TO lt_comp_all ASSIGNING <component>.
      <component>-type ?= cl_abap_datadescr=>describe_by_data( <lv_type> ).
      <component>-name =  ls_descriptor-name.
    ENDLOOP.
    lv_count = iv_gjahr_end - iv_gjahr_beg + 1.
    lv_gjahr = iv_gjahr_beg.
    go_descriptor ?= cl_abap_typedescr=>describe_by_data( iv_col ).
    DO lv_count TIMES.
      LOOP AT go_descriptor->components INTO ls_descriptor.
        ASSIGN COMPONENT ls_descriptor-name OF STRUCTURE iv_col TO <lv_type>.
        APPEND INITIAL LINE TO lt_comp_all ASSIGNING <component>.
        <component>-type ?= cl_abap_datadescr=>describe_by_data( <lv_type> ).
        <component>-name =  ls_descriptor-name && lv_gjahr .
      ENDLOOP.
      lv_gjahr = lv_gjahr + 1.
    ENDDO.
    lo_structdescr = cl_abap_structdescr=>create( lt_comp_all ).
* create table description for structure
    lo_tabledescr = cl_abap_tabledescr=>create(
                    p_line_type  = lo_structdescr
*                    P_KEY = LT_KEY
                    p_table_kind = cl_abap_tabledescr=>tablekind_std
                    p_unique     = abap_false ).
* create data object
    CREATE DATA er_data TYPE HANDLE lo_tabledescr.
    ASSIGN er_data->* TO <lt_tab>.
  ENDMETHOD.
ENDCLASS.
