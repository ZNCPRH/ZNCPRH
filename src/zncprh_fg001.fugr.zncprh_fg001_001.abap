FUNCTION zncprh_fg001_001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_TABLE) TYPE  ANY OPTIONAL
*"     REFERENCE(I_FULL_ALV) TYPE  XFELD OPTIONAL
*"     REFERENCE(I_TITLE) TYPE  SY-TITLE OPTIONAL
*"     REFERENCE(IT_SUM_FIELDS) TYPE  CCGLD_FIELDNAMES OPTIONAL
*"----------------------------------------------------------------------

  DATA lr_table   TYPE REF TO cl_salv_table.
  DATA lr_funct   TYPE REF TO cl_salv_functions .
  DATA lr_columns TYPE REF TO cl_salv_columns_table .
  DATA lr_column  TYPE REF TO cl_salv_column_table.
  DATA lr_functions  TYPE REF TO cl_salv_functions.
  DATA lr_display    TYPE REF TO cl_salv_display_settings.

  DATA: lo_aggrs TYPE REF TO cl_salv_aggregations.
  FIELD-SYMBOLS <ft_table> TYPE  ANY TABLE.

  ASSIGN it_table TO <ft_table>.

  cl_salv_table=>factory(
    IMPORTING
      r_salv_table = lr_table
    CHANGING
      t_table      = <ft_table> ).

  "lr_funct = lr_table->get_functions( ).
*    lr_funct->set_all( abap_true ).
  lr_columns = lr_table->get_columns( ).
  lr_columns->set_optimize( 'X' ).
*
  "  lr_table->set_screen_status(
  "      pfstatus      =  'GUI'
  "      report        =  sy-cprog"'SALV_DEMO_TABLE_SELECTIONS'
  "      set_functions =  lr_table->c_functions_all ).

  "Menu Buttons
  lr_functions = lr_table->get_functions( )."Gui Butonları Atama
  lr_functions->set_all( abap_true )."Gui Butonları Basma

  lr_display = lr_table->get_display_settings( ).
  IF i_title IS NOT INITIAL.

    lr_display->set_list_header( i_title ).

  ENDIF.

  IF it_sum_fields IS NOT INITIAL.
    lo_aggrs = lr_table->get_aggregations( ).
    LOOP AT it_sum_fields INTO DATA(ls_sum_fields).
      TRY.
          lo_aggrs->add_aggregation(
           EXPORTING
             columnname  = CONV #( ls_sum_fields )
             aggregation = if_salv_c_aggregation=>total ).
        CATCH cx_salv_data_error .
        CATCH cx_salv_not_found .
        CATCH cx_salv_existing .

      ENDTRY.
    ENDLOOP.
  ENDIF.
  IF i_full_alv <> 'X'.

    lr_table->set_screen_popup(
      start_column = 1
      end_column   = 120
      start_line   = 1
      end_line     = 12 ).
  ENDIF.

*    "başlıkları ayarla
*    lr_column ?= lr_columns->get_column( 'REFCARID' ).
*    lr_column->set_long_text( 'Referans Form' ).
*    lr_column->set_medium_text( 'Referans Form' ).
*    lr_column->set_short_text( 'Ref Form' ).

  lr_table->display( ).




ENDFUNCTION.
