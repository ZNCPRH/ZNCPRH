CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    METHODS : get_submit_ziw58 ,
      get_submit_zerp32 ,
      get_excell_ziw58 ,
      get_excell_zerp32 ,
      get_mail ,
      get_excel_1.
    METHODS : get_init EXPORTING date TYPE sy-datum.
ENDCLASS.
CLASS lcl_main IMPLEMENTATION.
  METHOD get_excel_1.
    FIELD-SYMBOLS : <fs_fs> TYPE any.
    DATA : lv_string TYPE string.
    DATA : lv_value TYPE char255.
    DATA : itab TYPE REF TO data.
    DATA : struct TYPE extdfiest,
           wa     TYPE extdfies.
    CREATE DATA itab TYPE TABLE OF ('ZNCPRH_S001').

    struct = zncprh_cl008=>get_table_structure( itab = itab ).


    LOOP AT gt_itab INTO gs_itab.

      IF sy-tabix NE 1.
        lv_string = lv_string && gc_crlf.
      ENDIF.

      LOOP AT struct INTO DATA(ls_struct).
        DATA(lv_tabix) = sy-tabix.
        CHECK ls_struct-fieldname IS NOT INITIAL.

        IF lv_tabix EQ 1 AND lv_string IS INITIAL.
          lv_string = lv_string && ls_struct-reptext && gc_tab.
          lv_string = lv_string && gc_crlf.
        ENDIF.

        ASSIGN COMPONENT ls_struct-fieldname OF STRUCTURE gs_itab TO <fs_fs>.

        IF sy-subrc EQ 0.
          lv_value = <fs_fs>.
          IF ls_struct-inttype EQ cl_abap_typedescr=>typekind_date.
            WRITE <fs_fs> TO lv_value.
          ENDIF.
          IF ls_struct-inttype EQ cl_abap_typedescr=>typekind_time.
            WRITE <fs_fs> TO lv_value.
          ENDIF.
          IF ls_struct-inttype EQ cl_abap_typedescr=>typekind_decfloat   OR
             ls_struct-inttype EQ cl_abap_typedescr=>typekind_decfloat16 OR
             ls_struct-inttype EQ cl_abap_typedescr=>typekind_decfloat34 OR
             ls_struct-inttype EQ cl_abap_typedescr=>typekind_packed.
            WRITE <fs_fs> TO lv_value DECIMALS 2 LEFT-JUSTIFIED.
          ENDIF.
          lv_string = lv_string && lv_value && gc_tab.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    TRY.
        cl_bcs_convert=>string_to_solix(
   	EXPORTING
        iv_string = lv_string
        iv_codepage = '4103'
        iv_add_bom = 'X'
    IMPORTING
        et_solix = gt_binary_content
        ev_size = gv_size ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.
  ENDMETHOD.
  METHOD get_submit_ziw58.
    DATA : lv_date TYPE sy-datum.
    "submit settings
    cl_salv_bs_runtime_info=>set(
          EXPORTING display   = abap_false
                    metadata  = abap_false
                    data      = abap_true ).

    me->get_init( IMPORTING date = lv_date ).


    "Submit..
    SUBMIT zpm_talep_rapor
      AND RETURN
        WITH p_sevk = 'X'
        WITH p_kabl = 'X'
        WITH p_acik = 'X'
        WITH p_bekl = 'X'
        WITH s_ztlp = '01'
        WITH s_qmar = 'T3'
*       WITH s_qmda = lv_date
          EXPORTING LIST TO MEMORY.


    "Get Submit Data...
    TRY.
        cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = gr_pay_data ).
        ASSIGN gr_pay_data->* TO <gt_pay_data>.
      CATCH cx_salv_bs_sc_runtime_info INTO DATA(root).
        DATA(error) = root->get_text( ).
        MESSAGE error TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
    cl_salv_bs_runtime_info=>clear_all( ).


    MOVE-CORRESPONDING <gt_pay_data> TO gt_itab.
  ENDMETHOD.
  METHOD get_submit_zerp32.
    DATA : lv_date TYPE sy-datum.
    "submit settings
    cl_salv_bs_runtime_info=>set(
          EXPORTING display   = abap_false
                    metadata  = abap_false
                    data      = abap_true ).

    me->get_init( IMPORTING date = lv_date ).


    SUBMIT "zerpisemrirpr
      and RETURN
*       WITH p_atm = 'X'
*       WITH p_tmm = 'X'
      WITH s_tlptrh = lv_date
        EXPORTING LIST TO MEMORY.

    "Get Submit Data...
    UNASSIGN <gt_pay_data>.
    TRY.
        cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = gr_pay_data ).
        ASSIGN gr_pay_data->* TO <gt_pay_data>.
      CATCH cx_salv_bs_sc_runtime_info INTO DATA(root).
        DATA(error) = root->get_text( ).
        MESSAGE error TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
    cl_salv_bs_runtime_info=>clear_all( ).


    MOVE-CORRESPONDING <gt_pay_data> TO gt_atama.
  ENDMETHOD.

  METHOD get_excell_ziw58.
    DATA : lv_string TYPE string.
    DATA : lv_tabix TYPE sy-tabix.
    DATA : go_struct TYPE REF TO cl_abap_structdescr.
    DATA : go_tc TYPE REF TO cl_abap_datadescr.
    DATA : ls_comp TYPE abap_compdescr.
    DATA : lv_value TYPE char255.
    FIELD-SYMBOLS : <fs_fs> TYPE any.
    CLEAR gt_fcat.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_bypassing_buffer     = 'X'
        i_structure_name       = 'ZPM_S_TALEP_RAPOR'
      CHANGING
        ct_fieldcat            = gt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.


    go_struct ?= cl_abap_typedescr=>describe_by_data( gs_itab ).



    LOOP AT gt_itab INTO gs_itab.
      IF sy-tabix NE 1.
        lv_string = lv_string && gc_crlf.
      ENDIF.

      LOOP AT go_struct->components INTO ls_comp.
        lv_tabix = sy-tabix.

        CHECK ls_comp-name IS NOT INITIAL.

        IF lv_tabix EQ 1 AND lv_string IS INITIAL.

          LOOP AT go_struct->components INTO DATA(ls_comp2).

            READ TABLE gt_fcat INTO gs_fcat WITH KEY fieldname = ls_comp2-name.
            lv_string = lv_string && gs_fcat-reptext && gc_tab.

          ENDLOOP.
          lv_string = lv_string && gc_crlf.

        ENDIF.

        ASSIGN COMPONENT ls_comp-name OF STRUCTURE gs_itab TO <fs_fs>.

        IF sy-subrc EQ 0.
          lv_value = <fs_fs>.

          IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_date.
            WRITE <fs_fs> TO lv_value.
          ENDIF.

          IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_time.
            WRITE <fs_fs> TO lv_value.
          ENDIF.

          IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat   OR
             ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat16 OR
             ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat34 OR
             ls_comp-type_kind EQ cl_abap_typedescr=>typekind_packed.
            WRITE <fs_fs> TO lv_value DECIMALS 2 LEFT-JUSTIFIED.
          ENDIF.

          lv_string = lv_string && lv_value && gc_tab.

        ENDIF.
      ENDLOOP.
    ENDLOOP.


    TRY.
        cl_bcs_convert=>string_to_solix(
   	EXPORTING
        iv_string = lv_string
        iv_codepage = '4103'
        iv_add_bom = 'X'
    IMPORTING
        et_solix = gt_binary_content
        ev_size = gv_size ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.
  ENDMETHOD.
  METHOD get_excell_zerp32.
    DATA : lv_string TYPE string.
    DATA : lv_tabix TYPE sy-tabix.
    DATA : go_struct TYPE REF TO cl_abap_structdescr.
    DATA : go_tc TYPE REF TO cl_abap_datadescr.
    DATA : ls_comp TYPE abap_compdescr.
    DATA : lv_value TYPE char255.
    FIELD-SYMBOLS : <fs_fs> TYPE any.
    CLEAR gt_fcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_bypassing_buffer     = 'X'
        i_structure_name       = 'ZERP_ISEMIR_STRU'
      CHANGING
        ct_fieldcat            = gt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    go_struct ?= cl_abap_typedescr=>describe_by_data( gs_atama ).

    CLEAR lv_string.
    LOOP AT gt_atama INTO gs_atama.
      IF sy-tabix NE 1.
        lv_string = lv_string && gc_crlf.
      ENDIF.
      LOOP AT go_struct->components INTO ls_comp.
        lv_tabix = sy-tabix.
        CHECK ls_comp-name IS NOT INITIAL.
        IF lv_tabix EQ 1 AND lv_string IS INITIAL.
          LOOP AT go_struct->components INTO DATA(ls_comp2).
            READ TABLE gt_fcat INTO gs_fcat WITH KEY fieldname = ls_comp2-name.
            lv_string = lv_string && gs_fcat-reptext && gc_tab.
          ENDLOOP.
          lv_string = lv_string && gc_crlf.
        ENDIF.
        ASSIGN COMPONENT ls_comp-name OF STRUCTURE gs_atama TO <fs_fs>.
        IF sy-subrc EQ 0.
          lv_value = <fs_fs>.
          IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_date.
            WRITE <fs_fs> TO lv_value.
          ENDIF.
          IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_time.
            WRITE <fs_fs> TO lv_value.
          ENDIF.
          IF ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat OR
          ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat16 OR
          ls_comp-type_kind EQ cl_abap_typedescr=>typekind_decfloat34 OR
          ls_comp-type_kind EQ cl_abap_typedescr=>typekind_packed.
            WRITE <fs_fs> TO lv_value DECIMALS 2 LEFT-JUSTIFIED.
          ENDIF.
          lv_string = lv_string && lv_value && gc_tab.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    TRY.
        cl_bcs_convert=>string_to_solix(
    EXPORTING
        iv_string = lv_string
        iv_codepage = '4103'
        iv_add_bom = 'X'
    IMPORTING
        et_solix = gt_binary_content2
        ev_size = gv_size2 ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.
  ENDMETHOD.

  METHOD get_mail.
    DATA : ip_rec TYPE bcsy_smtpa.
    DATA : ls_rec LIKE LINE OF ip_rec.
    DATA : ip_sender TYPE so_rec_ext.
    DATA : lv_size TYPE i.
    DATA : lv_size2 TYPE i.
    DATA : lt_body TYPE srm_t_solisti1.
    DATA : ls_body LIKE LINE OF lt_body.


    CONDENSE gv_size.
    CONDENSE gv_size2.

    lv_size = gv_size.
    lv_size2 = gv_size2.

    ip_sender = 'info@x.com'.

    ls_rec = 'info@y.com'.
    APPEND ls_rec TO ip_rec.

    ls_body-line = |<html> Sayin x|.
    APPEND ls_body TO lt_body.

    zncprh_cl002=>send_mail_basic(
      EXPORTING
        ip_rec          = ip_rec                  " BCS: SMTP adresleri ile dahili tablo
*        ip_rec_cc       =                  " BCS: SMTP adresleri ile dahili tablo
        ip_body         = lt_body                 " Solisti1 için tablo
        ip_sender       = ip_sender                 " Harici adres (SMTP/X.400...)
        ip_size         = lv_size
        ip_size2        = lv_size2
        ip_content_hex  = gt_binary_content                 " GBT: Tablo tipi olarak SOLIX
        ip_content_hex2 = gt_binary_content2                 " GBT: Tablo tipi olarak SOLIX
    ).
  ENDMETHOD.
  METHOD get_init.
    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = sy-datum
        days      = '01'
        months    = '00'
        signum    = '-'
        years     = '00'
      IMPORTING
        calc_date = date.
  ENDMETHOD.
ENDCLASS.
