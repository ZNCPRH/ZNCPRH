*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P010_I001
*&---------------------------------------------------------------------*
 DATA : o_alv TYPE REF TO cl_salv_table .

*----------------------------------------------------------------------*
*       C L A S S  L C L _ C L A S S   D E F I N I T I O N             *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*

 CLASS lcl_class DEFINITION.

 PUBLIC SECTION.
*----------------------------------------------------------------------*
*                   C L A S S      D A T A                             *
*                                                                      *
*----------------------------------------------------------------------*

  CLASS-DATA :

    lo_functions TYPE REF TO cl_salv_functions_list  ,
    lo_class     TYPE REF TO lcl_class               ,
    mo_events    TYPE REF TO cl_salv_events_table    ,
    lo_cols      TYPE REF TO cl_salv_columns_table   ,
    lo_col       TYPE REF TO cl_salv_column_table    ,
    lo_table     TYPE REF TO cl_salv_table           ,
    i_funct      TYPE        sy-ucomm                .


*----------------------------------------------------------------------*
*                   C L A S S      M E T H O D                         *
*                                                                      *
*----------------------------------------------------------------------*

  CLASS-METHODS:

    generate_output
      CHANGING  itab           TYPE        ANY TABLE             ,

    start_process                                                ,

    event_handler                                                ,

    change_fcat
      IMPORTING i_fieldname    TYPE        slis_tabname OPTIONAL
                i_short_txt    TYPE        scrtext_s    OPTIONAL
                i_med_txt      TYPE        scrtext_m    OPTIONAL
                i_long_txt     TYPE        scrtext_l    OPTIONAL ,

    set_pf_status
      CHANGING  co_alv         TYPE REF TO cl_salv_table         ,

    set_layout
      CHANGING  co_alv         TYPE REF TO cl_salv_table         ,

    on_link_click
      FOR EVENT link_click     OF          cl_salv_events_table
      IMPORTING row
                column                                           ,

    set_colors
      IMPORTING i_col_colmn    TYPE        slis_tabname
                i_color        TYPE        char6
                i_colmn        TYPE        slis_tabname
      CHANGING  co_alv         TYPE REF TO cl_salv_table
                i_table        TYPE        ANY TABLE             ,

    on_user_command
      FOR EVENT added_function OF          cl_salv_events
      IMPORTING                            e_salv_function       ,

    on_double_click
      FOR EVENT double_click   OF          cl_salv_events_table
      IMPORTING row
                column                                           .


 ENDCLASS.                    "lcl_report DEFINITION
*----------------------------------------------------------------------*
*       C L A S S  L C L _ C L A S S  I M P L E M E N T A T I O N      *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*
 CLASS lcl_class IMPLEMENTATION.

*----------------------------------------------------------------------*
*            G E N E R A T E _ O U T P U T   M E T H O D               *
*                                                                      *
*                                                                      *
* - Generate_output methodu mesaj döndermek için kullanılıyor.         *
*----------------------------------------------------------------------*

 METHOD generate_output.

   DATA: lx_msg TYPE REF TO cx_salv_msg.
   TRY.
       cl_salv_table=>factory(
         IMPORTING
           r_salv_table = o_alv
         CHANGING
           t_table      = itab
           ).
     CATCH cx_salv_msg INTO lx_msg.
   ENDTRY.
 ENDMETHOD.                    "generate_output
*----------------------------------------------------------------------*
*               S T A R T _ P R O C E S S   M E T H O D                *
*                                                                      *
*                                                                      *
* - Start_process methodunda kullanıcının içeriye müdahale edemediği   *
* methodlar burada tetikleniyor.                                       *
*----------------------------------------------------------------------*

 METHOD start_process.

   " Set Status...
   lcl_class=>set_pf_status( CHANGING co_alv    = o_alv ).

   " Set Layout...
   lcl_class=>set_layout(    CHANGING co_alv    = o_alv ).

   " Event Handler...
   lcl_class=>event_handler( ).

 ENDMETHOD.                    "start_process
*----------------------------------------------------------------------*
*             E V E N T   H A N D L E R   M E T H O D                  *
*                                                                      *
*                                                                      *
* - Event handler methodlar burada tetikleniyor.                       *
*----------------------------------------------------------------------*

 METHOD event_handler.

   CREATE OBJECT lo_class.
   mo_events = o_alv->get_event( ).

   SET HANDLER lo_class->on_double_click FOR mo_events.

 ENDMETHOD.                    "event_handler
*----------------------------------------------------------------------*
*           S E T _ P F _ S T A T U S   M E T H O D                    *
*                                                                      *
*                                                                      *
* - Status eklemek için kullanılan method.                             *
*----------------------------------------------------------------------*

 METHOD set_pf_status.

    co_alv->set_screen_status(
      EXPORTING
        report        = sy-repid
        pfstatus      = 'GUI'
        set_functions =  co_alv->c_functions_all ).

 ENDMETHOD.                    "set_pf_status
*----------------------------------------------------------------------*
*                S E T _ L A Y O U T   M E T H O D                     *
*                                                                      *
*                                                                      *
* - layoutları düzenlemek için kullanılan method.                      *
*----------------------------------------------------------------------*

 METHOD set_layout.

   DATA: lo_layout  TYPE REF TO cl_salv_layout,
         lf_variant TYPE slis_vari,
         ls_key    TYPE salv_s_layout_key.

   lo_layout = co_alv->get_layout( ).

   ls_key-report = sy-repid.
   lo_layout->set_key( ls_key ).
   lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

   lf_variant = 'DEFAULT'.
   lo_layout->set_initial_layout( lf_variant ).

 ENDMETHOD.                    "set_layout
*----------------------------------------------------------------------*
*          O N _ L I N K _ C L I C K   M E T H O D                     *
*                                                                      *
*                                                                      *
* - Hotspot için kullanıyoruz bu methodu.                              *
*----------------------------------------------------------------------*

 METHOD on_link_click.

   lo_cols = o_alv->get_columns( ).

   TRY.

       lo_col ?= lo_cols->get_column( column ).

     CATCH cx_salv_not_found.

   ENDTRY.

   lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).

   PERFORM on_link_click USING column row.

 ENDMETHOD.                    "on_link_click
*----------------------------------------------------------------------*
*               S E T _ C O L O R  M E T H O D                         *
*                                                                      *
*                                                                      *
* - Seçtiğiniz kolonu ve rengi parametre olarak methoda yollayınız.    *
* - Birden fazla alan boyamak isterseniz methodu birden fazla çağırın. *
*----------------------------------------------------------------------*

 METHOD set_colors.

   DATA: lo_cols_tab TYPE REF TO cl_salv_columns_table,
         lo_col_tab  TYPE REF TO cl_salv_column_table.
   DATA: ls_color    TYPE        lvc_s_colo.    " Colors strucutre

   DATA: lt_s_color TYPE lvc_t_scol,
         ls_s_color TYPE lvc_s_scol,
         l_count    TYPE i.

   lo_cols_tab = co_alv->get_columns( ).

   INCLUDE <color>.

   TRY.
       lo_col_tab ?= lo_cols_tab->get_column( i_colmn ).
       ls_color-col = i_color.
       lo_col_tab->set_color( ls_color ).
     CATCH cx_salv_not_found.
   ENDTRY.

   ls_s_color-fname     = i_col_colmn.

   CLEAR  lt_s_color.

   TRY.
       lo_cols_tab->set_color_column( i_col_colmn ).

     CATCH cx_salv_data_error.                        "#EC NO_HANDLER
   ENDTRY.
 ENDMETHOD.                    "set_colors
*----------------------------------------------------------------------*
*               S E T _ C O L O R  M E T H O D                         *
*                                                                      *
*                                                                      *
* - Eklemek istediğiniz kolonu fname ini ve textlerini parametre       *
* olarak çağırınız.                                                    *
* - Birden fazla alan eklemek isterseniz methodu birden fazla çağırın. *
*----------------------------------------------------------------------*

 METHOD change_fcat.

   DATA: lo_cols TYPE REF TO cl_salv_columns.
   lo_cols = o_alv->get_columns( ).

   lo_cols->set_optimize( 'X' ).

   DATA: lo_column TYPE REF TO cl_salv_column.

   TRY.
       lo_column = lo_cols->get_column( i_fieldname ).
       lo_column->set_long_text( i_long_txt ).
       lo_column->set_medium_text( i_med_txt ).
       lo_column->set_short_text( i_short_txt ).
       lo_column->set_output_length( 10 ).
     CATCH cx_salv_not_found.                         "#EC NO_HANDLER
   ENDTRY.

 ENDMETHOD.                    "change_Fcat
*----------------------------------------------------------------------*
*          O N _ U S E R _ C O M M A N D    M E T H O D                *
*                                                                      *
*                                                                      *
* - GUIye eklediğiniz buttonu bu methodun içindeki perfomdan           *
* yönetebilirsiniz.                                                    *
*----------------------------------------------------------------------*

 METHOD on_user_command.

   i_funct = sy-ucomm.

   CASE sy-ucomm.
     WHEN i_funct.
       PERFORM handle_user_command USING e_salv_function.
   ENDCASE.
 ENDMETHOD.                    "on_user_command
*----------------------------------------------------------------------*
*               F O R M    D O U B L E _ C L I C K                     *
*                                                                      *
*                                                                      *
* Dikkat Edilmesi Gerekilen yerler :                                   *
* - Eğer row veya column işlemleri yapacaksanız e_row e_column         *
* - parametrelerini göndermek zorundasınız.                            *
*----------------------------------------------------------------------*

 METHOD on_double_click.

  PERFORM on_double_click USING row column TEXT-i07.

 ENDMETHOD.                    "on_double_click
ENDCLASS.
