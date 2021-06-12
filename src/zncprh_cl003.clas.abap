CLASS zncprh_cl003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*"* public components of class /DSL/HE_CL001
*"* do not include other source files here!!!

    CLASS-METHODS get_instance
      RETURNING
        VALUE(r_object) TYPE REF TO zncprh_cl003 .
    METHODS get_sample_excel
      IMPORTING
        VALUE(it_table) TYPE ANY TABLE
        VALUE(i_str)    TYPE dd02l-tabname
        VALUE(i_fname)  TYPE string .
    METHODS create_fcat
      IMPORTING
        VALUE(i_str)   TYPE dd02l-tabname
      RETURNING
        VALUE(rt_fcat) TYPE lvc_t_fcat .
    CLASS-METHODS class_constructor .
  PROTECTED SECTION.
*"* protected components of class /DSL/HE_CL001
*"* do not include other source files here!!!
  PRIVATE SECTION.
*"* private components of class /DSL/HE_CL001
*"* do not include other source files here!!!

    CLASS-DATA mr_object TYPE REF TO zncprh_cl003 .
ENDCLASS.



CLASS ZNCPRH_CL003 IMPLEMENTATION.


  METHOD class_constructor.
    CREATE OBJECT mr_object.
  ENDMETHOD.


  METHOD create_fcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = i_str
      CHANGING
        ct_fieldcat      = rt_fcat.
    DELETE rt_fcat WHERE fieldname = 'MANDT'.
  ENDMETHOD.


  METHOD get_instance.
    r_object = mr_object.
  ENDMETHOD.


  METHOD get_sample_excel.

    DATA(r_result)  =  cl_salv_ex_util=>factory_result_data_table(
                            t_fieldcatalog =  me->create_fcat( i_str )
                            r_data         =  REF #( it_table )
                            t_sort         =  VALUE #( ( )  )
                            s_layout       =  VALUE #( zebra = 'X'
                            cwidth_opt     = 'X' )
                                                      ).

    cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform(
                            EXPORTING r_result_data  = r_result
                                      xml_type       = '10'
                                      xml_version    = '2.6'
                                      gui_type       = '02'"???
                                      xml_flavour    = 'C1F0S0S1S2R1I0'
                            IMPORTING xml            = DATA(lv_xml)
                                                   ).
    cl_salv_export_xml_dialog=>download(
    s_xml_choice = VALUE if_salv_bs_xml=>s_type_xml_choice(
                            default_file_name =  i_fname
                            frontend          = 'Y'
                            initial_directory = 'C:\TEMP'
                            version           = '02'
                            xml_type          = '10'
                            key               = '99' )
                            xml               = lv_xml ).

    "HANA Olmayanlar için
*  METHOD GET_SAMPLE_EXCEL.
*
*  DATA : r_result  TYPE REF TO cl_salv_ex_result_data_table,
*         r_data    TYPE REF TO data,
*         ls_layout TYPE lvc_s_layo,
*         lv_xml    TYPE xstring,
*         if_xml    TYPE if_salv_bs_xml=>s_type_xml_choice,
*         lv_way    TYPE string.
*
*  ls_layout-zebra = 'X'.
*  ls_layout-cwidth_opt = 'X'.
*
*  GET REFERENCE OF it_table INTO r_data.
*  r_result  =  cl_salv_ex_util=>factory_result_data_table(
*                         t_fieldcatalog =  me->create_fcat( i_str )
*                         r_data         =  r_data
*                         s_layout       = ls_layout
*                                                   ).
*
*  cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform(
*                          EXPORTING r_result_data  = r_result
*                                    xml_type       = '10'
*                                    xml_version    = '2.6'
*                                    gui_type       = '02'"???
*                                    xml_flavour    = 'C1F0S0S1S2R1I0'
*                          IMPORTING xml            = lv_xml
*                                                 ).
*
*  CALL METHOD cl_gui_frontend_services=>get_desktop_directory
*    CHANGING
*      desktop_directory = lv_way
*    EXCEPTIONS
*      cntl_error        = 1.
*  CALL METHOD cl_gui_cfw=>update_view.
*
*  IF lv_way IS INITIAL.
*    lv_way = 'C:\TEMP'.
*  ENDIF.
*
*  if_xml-default_file_name = i_fname.
*  if_xml-frontend          = 'Y'.
*  if_xml-initial_directory = lv_way.
*  if_xml-version           = '02'.
*  if_xml-xml_type          = '10'.
*  if_xml-key               = '99'.
*
*  cl_salv_export_xml_dialog=>download(
*  s_xml_choice = if_xml
*  xml          = lv_xml ).
*ENDMETHOD.
  ENDMETHOD.
ENDCLASS.
