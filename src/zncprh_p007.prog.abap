*&---------------------------------------------------------------------*
*& Report ZNCPRH_P007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p007.

DATA : ls_vekp TYPE vekp.
DATA : go_struct TYPE REF TO cl_abap_structdescr.
DATA : go_tc TYPE REF TO cl_abap_datadescr.

DATA : ls_comp TYPE abap_compdescr.
DATA : lv_value TYPE char255.
FIELD-SYMBOLS : <fs_fs>.

SELECT SINGLE * FROM vekp INTO ls_vekp .

PERFORM get_fields USING ls_vekp.

*&---------------------------------------------------------------------*
*&      Form  GET_FIELDS
*&---------------------------------------------------------------------*
FORM get_fields USING p_structure.

  go_struct ?= cl_abap_typedescr=>describe_by_data( p_structure  ).

  LOOP AT go_struct->components INTO ls_comp.
    CHECK ls_comp-name IS NOT INITIAL.
    ASSIGN COMPONENT ls_comp-name OF STRUCTURE p_structure TO  <fs_fs>.
    IF sy-subrc EQ 0.
      lv_value =  <fs_fs>.
      IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_date.
        WRITE <fs_fs> TO lv_value.
*         DD/MM/YYYY.
      ENDIF.

      IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_time.
        WRITE  <fs_fs>  TO lv_value.
      ENDIF.

      IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat OR
         ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat16 OR
         ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat34 OR
         ls_comp-type_kind EQ cl_abap_typedescr=>typekind_packed.
        WRITE <fs_fs>  TO lv_value DECIMALS 2 LEFT-JUSTIFIED.
      ENDIF.

      "ls_comp-name  - FIELD NAME
      "lv_value      - FIELD VALUE

    ENDIF.
  ENDLOOP.

  " Sa
ENDFORM.
