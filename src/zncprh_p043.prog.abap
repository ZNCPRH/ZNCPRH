*&---------------------------------------------------------------------*
*& Report ZNCPRH_P043
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZNCPRH_P043.

TYPES tt_type TYPE STANDARD TABLE OF zncprh_s032 WITH DEFAULT KEY.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_dosya TYPE rlgrap-filename,
             p_test  TYPE xfeld.
"test
SELECTION-SCREEN END OF BLOCK b1.



AT SELECTION-SCREEN OUTPUT.
  SET PF-STATUS 'SEL_PBO'.

AT SELECTION-SCREEN .
  CASE sy-ucomm.
    WHEN 'GETSAMPLE'.
      PERFORM get_sample_excel.
  ENDCASE.


FORM get_sample_excel.
  FIELD-SYMBOLS <ft_tab> TYPE ANY TABLE.


  DATA(lt_kim) = VALUE tt_type( (   BUKRSTX = 'Detay'
                                    PERSATX = 'Sivas'
                                    BTRTLTX = 'Merkez'
                                    PERNR   = '00001362'
                                    FNAM    = 'NcpRhErtg' )

                                  ( BUKRSTX = 'Detay'
                                    PERSATX = 'Sivas'
                                    BTRTLTX = 'İlçe'
                                    PERNR   = '00009999'
                                    FNAM    = 'Noname' )

                                   ).
  ASSIGN lt_kim TO <ft_tab>.
  DATA(lv_sname) = 'ZNCPRH_S032'.



  zncprh_cl003=>get_instance( )->get_sample_excel( i_fname  = 'Ornek.xls'
                                                   it_table = <ft_tab>
                                                   i_str    = CONV #( lv_sname )  ).
ENDFORM.
