*&---------------------------------------------------------------------*
*& Report ZNCPRH_P025
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZNCPRH_P025.

TYPE-POOLS: sbdst, slis.

*&---------------------------------------------------------------------*
*& Defined your variables in here
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_table,
         no(5),
         carrid   TYPE s_carr_id,
         connid   TYPE s_conn_id,
         distance TYPE   s_distance,
       END OF ty_table.

TYPES: BEGIN OF ty_data,
         datum    TYPE datum,
         uname    TYPE sy-uname,
         name(80),
         total(80),
       END OF ty_data.

DATA: t_table  TYPE TABLE OF ty_table,
      t_data   TYPE STANDARD TABLE OF ty_data,
      wa_table TYPE ty_table,
      wa_data  TYPE ty_data.


*&---------------------------------------------------------------------*
*& Change your parameter in here
*&---------------------------------------------------------------------*
CONSTANTS:
  c_classname  TYPE sbdst_classname   VALUE 'ZNCPRH_P025',
  c_classtype  TYPE sbdst_classtype   VALUE 'OT',
  c_object_key TYPE sbdst_object_key  VALUE '',
  c_file_desc  TYPE bds_propva        VALUE 'WORD',
  c_tabname    TYPE x030l-tabname     VALUE ''. "if using table structure

*&---------------------------------------------------------------------*
*& Do not change this data definition
*&---------------------------------------------------------------------*
DATA: go_control      TYPE REF TO i_oi_container_control,
      go_bds_instance TYPE REF TO cl_bds_document_set,
      go_word         TYPE REF TO i_oi_word_processor_document,
      go_document     TYPE REF TO i_oi_document_proxy,
      go_handle       TYPE REF TO i_oi_mail_merge.

DATA: t_signature  TYPE sbdst_signature,
      t_uris       TYPE sbdst_uri,
      t_components TYPE sbdst_components,
      t_namecol    TYPE soi_namecol_table,
      t_info       TYPE soi_cols_table,

      t_rfcf       TYPE STANDARD TABLE OF rfc_fields,

      wa_signature TYPE bapisignat,
      wa_uris      TYPE bapiuri,
      wa_namecol   TYPE soi_namecol_item,
      wa_rfcf      TYPE rfc_fields,
      wa_info      TYPE soi_cols,

      d_ret        TYPE i,
      d_url        TYPE c LENGTH 256,
      d_has        TYPE i,
      d_int        TYPE i.

CONSTANTS:
  c_merge      TYPE c           VALUE 'X',
  c_word       TYPE c LENGTH 40 VALUE 'Word.Document',
  c_excel      TYPE c LENGTH 40 VALUE 'Excel.Sheet',
  c_lang_id    TYPE sy-langu    VALUE 'id',
  c_newline    TYPE abap_char1  VALUE cl_abap_char_utilities=>cr_lf,
  c_objecttype TYPE c LENGTH 40 VALUE 'Word.Document'.

DEFINE m_namecol.
  wa_namecol-name = &1.
  wa_namecol-column = &2.
  APPEND wa_namecol TO t_namecol.
END-OF-DEFINITION.

START-OF-SELECTION.
  PERFORM f_get_data.
  PERFORM f_create_basic_objects.
  PERFORM f_set_fields_table.
  PERFORM f_set_display.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
FORM f_get_data.

  FIELD-SYMBOLS: <tab> TYPE ty_table.

  wa_data-datum = sy-datum.
  wa_data-uname = sy-uname.

  SELECT SINGLE name_textc
    FROM user_addr
    INTO wa_data-name
    WHERE bname = sy-uname.

  APPEND wa_data TO t_data.

  SELECT carrid connid distance
    FROM spfli
    INTO CORRESPONDING FIELDS OF TABLE t_table.

  LOOP AT t_table ASSIGNING <tab>.
    <tab>-no = sy-tabix.
    CONDENSE <tab>-no.
  ENDLOOP.

ENDFORM.                    "f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_create_basic_objects
*&      NO NEED TO CHANGE THIS ROUTINE
*&---------------------------------------------------------------------*
FORM f_create_basic_objects.

  FREE go_bds_instance.

  c_oi_container_control_creator=>get_container_control(
    IMPORTING control = go_control ).

  go_control->init_control(
    r3_application_name      = 'Microsoft Word'
    inplace_enabled          = space
    inplace_scroll_documents = 'X'
    parent                   = cl_gui_container=>default_screen
    register_on_close_event  = 'X'
    register_on_custom_event = 'X'
    no_flush                 = 'X' ).

  wa_signature-prop_name  = 'DESCRIPTION'.
  wa_signature-prop_value = c_file_desc.
  APPEND wa_signature TO t_signature.

  CREATE OBJECT go_bds_instance.

*  go_bds_instance->get_info(
*    EXPORTING
*      classname       = c_classname
*      classtype       = c_classtype
*      object_key      = c_object_key
*    CHANGING
*      components      = t_components
*      signature       = t_signature
*    EXCEPTIONS
*      nothing_found   = 1
*      error_kpro      = 2
*      internal_error  = 3
*      parameter_error = 4
*      not_authorized  = 5
*      not_allowed     = 6 ).
*
*  IF sy-subrc = 1.
*    MESSAGE 'There are no documents that meet the search criteria'
*       TYPE 'E'.
*  ELSEIF sy-subrc NE 0.
*    MESSAGE 'Error in the Business Document Service (BDS)'
*       TYPE 'E'.
*  ENDIF.

  CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_URL'
        EXPORTING
          classname       = c_classname
          classtype       = c_classtype
          client          = sy-mandt
          url_lifetime    = 'T'
        TABLES
          signature       = t_signature
        EXCEPTIONS
          nothing_found   = 1
          parameter_error = 2
          not_allowed     = 3
          error_kpro      = 4
          internal_error  = 5
          not_authorized  = 6
          OTHERS          = 7.

  go_bds_instance->get_with_url(
    EXPORTING
      classname       = c_classname
      classtype       = c_classtype
      object_key      = c_object_key
    CHANGING
      uris            = t_uris
      signature       = t_signature
    EXCEPTIONS
      nothing_found   = 1
      error_kpro      = 2
      internal_error  = 3
      parameter_error = 4
      not_authorized  = 5
      not_allowed     = 6 ).

  IF sy-subrc = 1.
    MESSAGE 'There are no documents that meet the search criteria'
       TYPE 'E'.
  ELSEIF sy-subrc NE 0.
    MESSAGE 'Error in the Business Document Service (BDS)'
       TYPE 'E'.
  ENDIF.

  READ TABLE t_uris INTO wa_uris INDEX 1.
  d_url = wa_uris-uri.

  go_control->get_document_proxy(
    EXPORTING
      document_type      = c_objecttype
      register_container = 'X'
    IMPORTING
      document_proxy     = go_document ).

  go_document->open_document(
    document_title = 'Demo BDS'
    open_inplace   = space
    document_url   = d_url ).

  go_document->has_mail_merge_interface(
    IMPORTING is_available = d_has ).

ENDFORM.                    "f_create_basic_objects

*&---------------------------------------------------------------------*
*&      Form  f_set_fields_table
*&      NO NEED TO CHANGE THIS ROUTINE
*&---------------------------------------------------------------------*
FORM f_set_fields_table.
  FREE: t_namecol.

  PERFORM f_dyn_analyse_table
              TABLES
                 t_data
                 t_rfcf
              USING
                 c_tabname
              CHANGING
                 d_ret.

*{Change this part based on your Field definition on your Ms.Word
  m_namecol:  'DATUM' '1',
              'UNAME' '2',
              'NAME'  '3',
              'TOTAL'  '4'.

*}

  LOOP AT t_namecol INTO wa_namecol.
    READ TABLE t_rfcf INTO wa_rfcf INDEX wa_namecol-column.
    IF sy-subrc EQ 0.
      wa_rfcf-fieldname = wa_namecol-name.
      MODIFY t_rfcf INDEX wa_namecol-column FROM wa_rfcf.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "f_set_fields_table

*&---------------------------------------------------------------------*
*&      Form  f_dyn_analyse_table
*&      NO NEED TO CHANGE THIS ROUTINE
*&---------------------------------------------------------------------*
FORM f_dyn_analyse_table TABLES   ft_data
                                  ft_rfcf STRUCTURE rfc_fields
                         USING    fu_tabname
                         CHANGING fc_return TYPE i.

  DATA: offset    LIKE rfc_fields-offset VALUE 0,
        slen      TYPE i,
        n         TYPE i,
        pos       TYPE i VALUE 1,
        alignment TYPE i.

  REFRESH ft_rfcf.
  fc_return = 0.
  slen = strlen( fu_tabname ).

  IF slen NE 0.
    CALL FUNCTION 'RFC_GET_STRUCTURE_DEFINITION'
      EXPORTING
        tabname          = fu_tabname
      TABLES
        fields           = ft_rfcf
      EXCEPTIONS
        table_not_active = 1
        OTHERS           = 2.
    IF sy-subrc NE 0.
      fc_return = 1.
    ENDIF.

  ELSE.
*  unicode system, note 652435
    PERFORM dyn_analyse_single IN PROGRAM saplcndp
                TABLES
                   ft_rfcf
                USING
                   ft_data
                CHANGING
                   pos
                   n
                   offset
                   alignment.
  ENDIF.

ENDFORM.                    " F_DYN_ANALYSE_TABLE

*&---------------------------------------------------------------------*
*&      Form  f_set_display
*&---------------------------------------------------------------------*
FORM f_set_display.
  DATA: ld_count TYPE sy-tabix.
  FIELD-SYMBOLS: <tab>   TYPE ty_table,
                 <value>.

  FREE: go_handle.

  DESCRIBE TABLE t_table LINES d_int.

* Get number of column in table
  LOOP AT t_table ASSIGNING <tab>.
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE <tab> TO <value>.
      IF sy-subrc = 0.
        ADD 1 TO ld_count.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
    EXIT.
  ENDLOOP.

  "passing information of numbers of column in table
  DO ld_count TIMES.
    wa_info-colindex = sy-index.
    APPEND wa_info TO t_info.
  ENDDO.

  go_document->get_mail_merge_interface( IMPORTING mm_interface = go_handle ).
  go_document->get_wordprocessor_interface( IMPORTING wp_interface = go_word ).
  go_word->insert_table(
      data_table      = t_table "Value Table: Contains Data to be Transferred
      info_table      = t_info  "Info Table: Specifies the Columns to be Transferred
      lowerbound      = 1       "First Line of Internal Table to be Transferred
      upperbound      = d_int   "Last Line of Intenral Table to be Transferred
      doctable_number = 1       "Number of the Document Table to be Filled
      clearoption     = 2       "Overwrite Behavior (for Document Table Contents)
      startrow        = 2       "Line in the Document Table from Which Data is to be Inserted
      varsize         = 'X'     "Adjust Size of Document Table to Fit?
  ).

  go_handle->set_data_source(
    CHANGING
      data_table    = t_data
      fields_table  = t_rfcf ).

  DESCRIBE TABLE t_data LINES d_int.

  go_handle->merge_range(
      first = 1
      last  = d_int ).

  go_handle->view( ).
*  fc_document->close_document( ).

ENDFORM.                    " F_SET_DISPLAY
