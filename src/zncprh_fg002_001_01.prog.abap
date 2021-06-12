*&---------------------------------------------------------------------*
*& Include          ZNCPRH_FG002_001_01
*&---------------------------------------------------------------------*
CLASS lcl_text_editor DEFINITION INHERITING FROM cl_gui_textedit FINAL.
  PUBLIC SECTION.
    TYPES tt_stable TYPE STANDARD TABLE OF text132 WITH DEFAULT KEY.

    CLASS-DATA : ms_header TYPE  thead .
    CLASS-DATA : m_cont TYPE REF TO cl_gui_custom_container,
                 m_text TYPE REF TO lcl_text_editor.

    CLASS-DATA : m_cont_small TYPE REF TO cl_gui_custom_container,
                 m_text_small TYPE REF TO lcl_text_editor.
    CLASS-METHODS get_instance RETURNING VALUE(r_object) TYPE REF TO lcl_text_editor.

    CLASS-METHODS create
      IMPORTING
        title    TYPE gui_title DEFAULT 'Açıklama'
        editable TYPE xfeld DEFAULT space
        texts    TYPE table OPTIONAL
        option   TYPE char10
        kimya    TYPE xfeld OPTIONAL
        header   TYPE thead OPTIONAL.

    CLASS-DATA m_kimya    TYPE xfeld.

    CLASS-METHODS create_text_object
      IMPORTING
        !max_number_chars           TYPE i OPTIONAL
        VALUE(style)                TYPE i DEFAULT 0
        !wordwrap_mode              TYPE i DEFAULT wordwrap_at_windowborder
        !wordwrap_position          TYPE i DEFAULT -1
        !wordwrap_to_linebreak_mode TYPE i DEFAULT false
        !filedrop_mode              TYPE i DEFAULT dropfile_event_off
        VALUE(parent)               TYPE REF TO cl_gui_container
        VALUE(lifetime)             TYPE i OPTIONAL
        VALUE(name)                 TYPE string OPTIONAL
      RETURNING
        VALUE(r_editor)             TYPE REF TO lcl_text_editor.

    CLASS-METHODS get_text
      IMPORTING option         TYPE char10
      EXPORTING
                VALUE(e_texts) TYPE table.

    CLASS-METHODS is_user_canceled
      RETURNING
        VALUE(r_subrc) TYPE xfeld.


    CLASS-METHODS class_constructor.

    " CLASS-METHODS : add_text IMPORTING VALUE(i_header)  TYPE thead.

    CLASS-METHODS free_all.

    METHODS get_title
      RETURNING
        VALUE(r_title) TYPE gui_title.

    METHODS set_text_to_display
      IMPORTING option TYPE char10.

    METHODS get_text_from_display
      IMPORTING option TYPE char10  .

    METHODS user_canceled.

  PRIVATE SECTION.
    CLASS-DATA : m_title    TYPE gui_title,
                 m_editable TYPE xfeld,
                 m_canceled TYPE xfeld.

    CLASS-DATA : m_texts       TYPE REF TO data,
                 m_texts_small TYPE REF TO data.
ENDCLASS.


CLASS lcl_text_editor IMPLEMENTATION.

  METHOD create.
    DATA : l_table_type TYPE REF TO cl_abap_tabledescr.

    m_title    = title.
    m_editable = editable.
    ms_header    = header."

    l_table_type ?= cl_abap_tabledescr=>describe_by_data( texts ).

    CASE option.
      WHEN 'LARGE'.
        CREATE DATA m_texts TYPE HANDLE l_table_type.
        ASSIGN m_texts->* TO FIELD-SYMBOL(<text_tab>).
        CHECK sy-subrc EQ 0.
        <text_tab> = texts.
      WHEN 'SMALL'.
        CREATE DATA m_texts_small TYPE HANDLE l_table_type.
        ASSIGN m_texts_small->* TO  <text_tab>.
        CHECK sy-subrc EQ 0.
        <text_tab> = texts.
      WHEN OTHERS.
    ENDCASE.


  ENDMETHOD.

  METHOD get_instance.
    " r_object = m_text .
  ENDMETHOD.


  METHOD create_text_object.

    CREATE OBJECT r_editor
      EXPORTING
        max_number_chars           = max_number_chars
        style                      = style
        wordwrap_mode              = wordwrap_mode
        wordwrap_position          = wordwrap_position
        wordwrap_to_linebreak_mode = wordwrap_to_linebreak_mode
        filedrop_mode              = filedrop_mode
        parent                     = parent
        lifetime                   = lifetime
        name                       = name.

    IF m_editable EQ space.
      r_editor->set_readonly_mode(
*      EXPORTING
*        readonly_mode          = TRUE    " read-only mode; eq 0: OFF ; ne 0: ON
      EXCEPTIONS
        error_cntl_call_method = 1
        invalid_parameter      = 2
        OTHERS                 = 3
      ).
      IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_title.
    r_title = me->m_title.
  ENDMETHOD.


  METHOD set_text_to_display.
    CHECK m_texts IS BOUND OR m_texts_small IS BOUND.
    CASE option.
      WHEN 'LARGE'.
        ASSIGN m_texts->* TO FIELD-SYMBOL(<text_tab>).
      WHEN 'SMALL'.
        ASSIGN m_texts_small->* TO <text_tab>.
      WHEN OTHERS.
    ENDCASE.

    " ASSIGN m_texts->* TO FIELD-SYMBOL(<text_tab>).
    me->set_text_as_r3table(
      EXPORTING
        table           = <text_tab>   " table with text
      EXCEPTIONS
        error_dp        = 1
        error_dp_create = 2
        OTHERS          = 3
    ).
  ENDMETHOD.

  METHOD get_text_from_display.
    CHECK m_texts IS BOUND OR m_texts_small IS BOUND.


    CASE option.
      WHEN 'LARGE'.
        ASSIGN m_texts->* TO FIELD-SYMBOL(<text_tab>).
      WHEN 'SMALL'.
        ASSIGN m_texts_small->* TO <text_tab>.
      WHEN OTHERS.
    ENDCASE.

    "  ASSIGN m_texts->* TO FIELD-SYMBOL(<text_tab>).
    me->get_text_as_r3table(
      EXPORTING
       only_when_modified      = cl_gui_textedit=>true
      IMPORTING
        table                  = <text_tab>    " text as R/3 table
*            is_modified            =     " modify status of text
      EXCEPTIONS
        error_dp               = 1
        error_cntl_call_method = 2
        error_dp_create        = 3
        potential_data_loss    = 4
        OTHERS                 = 5 ).
  ENDMETHOD.

  METHOD get_text.


    CASE option .
      WHEN 'SMALL'.
        ASSIGN m_texts_small->* TO FIELD-SYMBOL(<text_tab>).
        CHECK sy-subrc EQ 0.
        e_texts = <text_tab>.
      WHEN 'LARGE'.
        ASSIGN m_texts->* TO <text_tab>.
        CHECK sy-subrc EQ 0.
        e_texts = <text_tab>.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD free_all.
    CLEAR : m_title,
            m_editable,
            m_canceled.


    DATA(ls_header) = lcl_text_editor=>ms_header.

    "  FREE OBJECT  : lcl_text_editor , lcl_text_editor=>m_text..

    IF m_cont IS NOT INITIAL AND m_text IS NOT INITIAL." AND gv_ucomm <> 'OK'.""OK 'DA REFRESH VAR !!


*      CALL FUNCTION 'FREE_TEXT_MEMORY'
**      EXPORTING
**        local_cat = SPACE    " Text catalog local
*        EXCEPTIONS
*          not_found = 1
*          OTHERS    = 2.
*
*      IF sy-subrc <> 0.
**     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*
*      CALL METHOD lcl_text_editor=>m_text->delete_text( ).
*      CALL METHOD lcl_text_editor=>m_text->free_all( ).


      CALL METHOD cl_gui_cfw=>flush.
      CALL METHOD lcl_text_editor=>m_cont->free( ).
      CALL METHOD lcl_text_editor=>m_text->free( ).



      FREE : m_texts ,lcl_text_editor=>m_text , lcl_text_editor=>m_cont.

    ENDIF.

    IF m_cont_small IS NOT INITIAL AND m_text_small IS NOT INITIAL.

      CALL METHOD cl_gui_cfw=>flush.
      CALL METHOD lcl_text_editor=>m_cont_small->free( ).
      CALL METHOD lcl_text_editor=>m_text_small->free( ).


      FREE : m_texts_small ,lcl_text_editor=>m_text_small , lcl_text_editor=>m_cont_small.

    ENDIF.


  ENDMETHOD.

*
  METHOD class_constructor.

    " m_text  = NEW #( ).
  ENDMETHOD.

  METHOD is_user_canceled.
    r_subrc = m_canceled.
  ENDMETHOD.

  METHOD user_canceled.
    m_canceled = 'X'.
  ENDMETHOD.


ENDCLASS.

*

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZGUI'.
*
**
*  BREAK-POINT.
*
*  IF lcl_text_editor=>m_cont IS INITIAL AND gv_ucomm = 'ADD_TEXT' AND lcl_text_editor=>ms_header IS NOT INITIAL."eklenen texti göster !
*    "Show Before text !
*    DATA(lt_before_text) =  zdviga_cl003=>get_instance( )->read_text(
*     is_header = VALUE #( tdid = lcl_text_editor=>ms_header-tdid tdname = lcl_text_editor=>ms_header-tdname
*      tdspras = lcl_text_editor=>ms_header-tdspras tdobject = lcl_text_editor=>ms_header-tdobject )  ).
*
*    lcl_text_editor=>create( "title    = "i_title
*                             editable =  ''
*                             texts    = lt_before_text
*                             option   = 'LARGE'
*                             header = lcl_text_editor=>ms_header
*                              ).
*  ENDIF.




  lcl_text_editor=>m_cont = NEW cl_gui_custom_container( container_name = 'CONT01' ).

  lcl_text_editor=>m_text = lcl_text_editor=>create_text_object( EXPORTING
*        max_number_chars           =
*        style                      = 0
*        wordwrap_mode              = WORDWRAP_AT_WINDOWBORDER
*        wordwrap_position          = -1
*        wordwrap_to_linebreak_mode = FALSE
*        filedrop_mode              = DROPFILE_EVENT_OFF
      parent                     =  lcl_text_editor=>m_cont
*        lifetime                   =
*        name                       =
  ).


  "ENDIF.
  lcl_text_editor=>m_text->set_text_to_display(  EXPORTING option = 'LARGE' ).


  CALL METHOD cl_gui_cfw=>flush.
  CALL METHOD cl_gui_cfw=>update_view.

ENDMODULE.

MODULE user_command_0100 INPUT.
  DATA  :lt_text     TYPE thxy_note,
         lv_cancel   TYPE xfeld,
         lt_new_text TYPE thxy_note.

  CASE gv_ucomm.
    WHEN 'CANCEL'.
      lcl_text_editor=>m_text->user_canceled( ).
      LEAVE TO SCREEN 0.

    WHEN 'ADD_TEXT'."
*
*      IF lcl_text_editor=>ms_header IS NOT INITIAL.
*        zdviga_cl003=>get_instance( )->add_text( i_header = lcl_text_editor=>ms_header ).
*      ENDIF.
*
*      CALL METHOD lcl_text_editor=>m_text->delete_text.
*
*      DATA(lt_before_text) =  zdviga_cl003=>get_instance( )->read_text(
*         is_header = VALUE #( tdid = lcl_text_editor=>ms_header-tdid tdname = lcl_text_editor=>ms_header-tdname
*          tdspras = lcl_text_editor=>ms_header-tdspras tdobject = lcl_text_editor=>ms_header-tdobject )  ).
*
*
*      DATA lt_stab TYPE lcl_text_editor=>tt_stable.
*
*      lt_stab = VALUE #( FOR gy IN lt_before_text
*                            ( gy-tdline ) ).
*
*      CALL METHOD lcl_text_editor=>m_text->set_text_as_r3table
*        EXPORTING
*          table  = lt_stab
*        EXCEPTIONS
*          OTHERS = 1.
*
*        MESSAGE | Yorumlar eklenmiştir | TYPE 'S'.
    WHEN 'OK'.
      lcl_text_editor=>m_text_small->get_text_from_display( option = 'LARGE' ).
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.


MODULE status_0101 OUTPUT.
  SET PF-STATUS 'ZGUI2'.
  lcl_text_editor=>m_cont_small = NEW cl_gui_custom_container( container_name = 'CONT02' ).

  lcl_text_editor=>m_text_small = lcl_text_editor=>create_text_object( EXPORTING
*        max_number_chars           =
*        style                      = 0
*        wordwrap_mode              = WORDWRAP_AT_WINDOWBORDER
*        wordwrap_position          = -1
*        wordwrap_to_linebreak_mode = FALSE
*        filedrop_mode              = DROPFILE_EVENT_OFF
      parent                     =  lcl_text_editor=>m_cont_small
*        lifetime                   =
*        name                       =
  ).

  lcl_text_editor=>m_text_small->set_text_to_display( EXPORTING option = 'SMALL' ).

ENDMODULE.

MODULE user_command_0101 INPUT.
  CASE gv_ucomm.
    WHEN 'CANCEL'.
      lcl_text_editor=>m_text_small->user_canceled( ).
      LEAVE TO SCREEN 0.
    WHEN 'OK'.
      lcl_text_editor=>m_text_small->get_text_from_display( option = 'SMALL' ).
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
