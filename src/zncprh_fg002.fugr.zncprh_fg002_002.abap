FUNCTION ZNCPRH_FG002_002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_EDITABLE) TYPE  XFELD OPTIONAL
*"     VALUE(I_TITLE) TYPE  GUI_TITLE OPTIONAL
*"     VALUE(I_ADD_COMMENT) TYPE  XFELD OPTIONAL
*"     VALUE(IS_HEADER) TYPE  THEAD OPTIONAL
*"  EXPORTING
*"     VALUE(E_CANCEL) TYPE  XFELD
*"  CHANGING
*"     VALUE(CT_TEXT) TYPE  THXY_NOTE OPTIONAL
*"----------------------------------------------------------------------

 lcl_text_editor=>create( title    = i_title
                               editable = i_editable
                               texts    = ct_text
                               option   = 'SMALL'
                                ).

  CALL SCREEN 101 STARTING AT 5 5.

  IF lcl_text_editor=>is_user_canceled( ).
    e_cancel = lcl_text_editor=>is_user_canceled( ).
  ELSE.
    lcl_text_editor=>get_text(  EXPORTING  option   = 'SMALL' IMPORTING e_texts = ct_text ).
  ENDIF.

  lcl_text_editor=>free_all( ).


ENDFUNCTION.
