*&---------------------------------------------------------------------*
*& Report ZNCPRH_P010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p010.

*----------------------------------------------------------------------*
*                   U S E R  D A T A                                   *
*                                                                      *
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_vbak         ,
         vbeln   TYPE vbak-vbeln,
         erdat   TYPE erdat,
         auart   TYPE auart,
         kunnr   TYPE kunnr,
         t_color TYPE lvc_t_scol,
         test    TYPE char30,
       END   OF ty_vbak         .

DATA : t_vbak   TYPE STANDARD TABLE OF ty_vbak .


*&---------------------------------------------------------------------*
*&                     I N C L U D E S                                 *
*&                                                                     *
*&---------------------------------------------------------------------*

INCLUDE zncprh_p010_i001.



*&---------------------------------------------------------------------*
*&              S T A R T - O F - S E L E C T I O N                    *
*&                                                                     *
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT vbeln erdat auart kunnr
         INTO CORRESPONDING FIELDS OF TABLE t_vbak
         FROM  vbak
         UP TO 20 ROWS.

*&---------------------------------------------------------------------*
*&                        M E T H O D S                                *
*&                                                                     *
*&---------------------------------------------------------------------*

  " Create ALV...
*----------------------------------------------------------------------*
  lcl_class=>generate_output( CHANGING itab = t_vbak ).

  " Change Field Catalog...
*----------------------------------------------------------------------*
  lcl_class=>change_fcat( i_fieldname = 'TEST'
                          i_short_txt = 'Test'
                          i_med_txt   = 'Test Col'
                          i_long_txt  = 'Test Column' ).
  " Start Process...
*----------------------------------------------------------------------*
  lcl_class=>start_process( ).

  " Link Click...
*----------------------------------------------------------------------*
  lcl_class=>on_link_click( row = 1  column = 'VBELN' ).

  " Set_Color...
*----------------------------------------------------------------------*
  lcl_class=>set_colors( EXPORTING i_color     = '1'
                                   i_col_colmn = 'T_COLOR'
                                   i_colmn     = 'ERDAT'
                         CHANGING  co_alv      = o_alv
                                   i_table     = t_vbak ).

  lcl_class=>set_colors( EXPORTING i_color     = '5'
                                   i_col_colmn = 'T_COLOR'
                                   i_colmn     = 'VBELN'
                         CHANGING  co_alv      = o_alv
                                   i_table     = t_vbak ).

*&---------------------------------------------------------------------*
*&               E N D - O F - S E L E C T I O N                       *
*&                                                                     *
*&---------------------------------------------------------------------*
END-OF-SELECTION.

  " Display ALV...
  o_alv->display( ).


*  *PERFORMS

*&---------------------------------------------------------------------*
*&                      P E R F O R M S                                *
*&                                                                     *
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*              F O R M   O N _ L I N K _ C L I C K                     *
*                                                                      *
*                                                                      *
* Öneriler :                                                           *
* - Hotspot ile yapacağınız işi burada belirtiniz.                     *
*                                                                      *
*----------------------------------------------------------------------*

FORM on_link_click USING column row.

*      READ TABLE t_vbak INTO s_vbak INDEX row.
*    IF s_vbak-vbeln IS NOT INITIAL.
*      MESSAGE i398(00) WITH 'You have selected' s_vbak-vbeln.
*    ENDIF.

ENDFORM.                    "on_link_click
*----------------------------------------------------------------------*
*         F O R M  H A N D L E _ U S E R _ C O M M A N D               *
*                                                                      *
*                                                                      *
* Öneriler :                                                           *
* - Buttonun yapacağı işi burada belirtiniz.                           *
* - Birden fazla buttonu yönetmek istiyorsanız case içinde kullanınız. *
*                                                                      *
*----------------------------------------------------------------------*

FORM handle_user_command USING i_ucomm TYPE salv_de_function.

  CASE i_ucomm.
    WHEN 'TEST'.
      MESSAGE : 'Butona Tıkladınız.' TYPE 'I'.
  ENDCASE.

ENDFORM.                    " HANDLE_USER_COMMAND
*----------------------------------------------------------------------*
*         F O R M  H A N D L E _ U S E R _ C O M M A N D               *
*                                                                      *
*                                                                      *
* Öneriler :                                                           *
* - Double_Click işlemi gerçekleşince ne olmasını istiyorsanız         *
* buraya ekleyiniz.                                                    *
*----------------------------------------------------------------------*

FORM on_double_click USING p_row
                           p_column
                           p_text_i07.


*  DATA: l_row_string TYPE string ,
*        l_col_string TYPE string ,
*        l_row        TYPE char128.
*
*  WRITE p_row TO l_row LEFT-JUSTIFIED.
*
*  CONCATENATE text-i02 l_row    INTO l_row_string SEPARATED BY space.
*  CONCATENATE text-i03 p_column INTO l_col_string SEPARATED BY space.
*
*  MESSAGE i000(0k) WITH p_text_i07 l_row_string l_col_string.


ENDFORM.                    " ON_DOUBLE_CLICK
