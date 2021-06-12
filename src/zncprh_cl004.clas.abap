

CLASS zncprh_cl004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*"* public components of class /DSL/HE_CL003
*"* do not include other source files here!!!

    CLASS-METHODS get_instance
      RETURNING
        VALUE(r_object) TYPE REF TO zncprh_cl004 .
    CLASS-METHODS class_constructor .
    METHODS constructor .
    METHODS show_progress
      IMPORTING
        VALUE(i_tabix) TYPE sy-tabix OPTIONAL
        VALUE(i_count) TYPE sy-tabix OPTIONAL
        VALUE(i_text)  TYPE text120 OPTIONAL .
  PROTECTED SECTION.
*"* protected components of class /DSL/HE_CL003
*"* do not include other source files here!!!
  PRIVATE SECTION.
*"* private components of class /DSL/HE_CL003
*"* do not include other source files here!!!

    CLASS-DATA my_class TYPE REF TO zncprh_cl004 .
ENDCLASS.



CLASS ZNCPRH_CL004 IMPLEMENTATION.


  METHOD class_constructor.
    CREATE OBJECT my_class.
  ENDMETHOD.


  METHOD constructor.
  ENDMETHOD.


  METHOD get_instance.
    r_object = my_class.
  ENDMETHOD.


  METHOD show_progress.
    DATA: w_text            TYPE string,
          w_percentage      TYPE p,
          w_percent_char(3) ,
          gd_percent        TYPE i.

    CHECK i_count IS NOT INITIAL.
    w_percentage = ( i_tabix / i_count ) * 100.
    w_percent_char = w_percentage.
    SHIFT w_percent_char LEFT DELETING LEADING ' '.

    IF w_percentage GT gd_percent OR i_tabix EQ 1.
      w_text = |{ i_text }  %{ w_percent_char } tamamlandı..! |.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = w_percentage
          text       = w_text.

      gd_percent = w_percentage.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
