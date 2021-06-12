*&---------------------------------------------------------------------*
*& Report ZNCPRH_P026
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p026.



* TEXT SYMBOLS
* H01	N.ro fattura SD
* H02	Org. comm.le
* H03	Tipo fattura
* H04	Tipo documento
* H05	Divisa
* H06	Importo netto
* H07	Importo IVA
* H08	Società
* H09	N.ro documento
* H10	Esercizio
* H11	Data reg.

* SELECTION TEXT
* S_EMAIL	Indirizzi email
* S_ERDAT	Data creazione



TABLES: vbrk, bkpf.

DATA: BEGIN OF it_data OCCURS 0,
        vbeln LIKE vbrk-vbeln,
        vkorg LIKE vbrk-vkorg,
        fkart LIKE vbrk-fkart,
        vbtyp LIKE vbrk-vbtyp,
        waerk LIKE vbrk-waerk,
        netwr LIKE vbrk-netwr,
        mwsbk LIKE vbrk-mwsbk,
        bukrs LIKE bkpf-bukrs,
        belnr LIKE bkpf-belnr,
        gjahr LIKE bkpf-gjahr,
        budat LIKE bkpf-budat,
      END OF it_data.

DATA: wa_email(40) TYPE c.    "TYPE ad_smtpadr limitata a 40 per la s.o.

* Preparazione email
DATA: it_excel TYPE TABLE OF zncprh_s023,
* ztt_excel_data type table of ZTR_EXCEL_DATA
      s_excel  TYPE zncprh_s023.
* ztr_excel_data
* SHEET_NRO   INT4            INT4  10  0 Numero naturale
* ROW_NRO   INT4            INT4  10  0 Numero naturale
* COLUMN_NRO    INT4            INT4  10  0 Numero naturale
* VALUE           TEXT128   CHAR  128 0 Field area (128 bytes)
* JUSTIFY   ZJUSTIFY    CHAR  1 0 Justify
* - C	Center
* - L	Left
* - R	Right
* - J	Justify
* BOLD            CHECKBOX     CHAR 1 0 Casella di spunta Reporting
* ITALIC    CHECKBOX     CHAR 1 0 Casella di spunta Reporting
* UNDERLINE   CHECKBOX     CHAR 1 0 Casella di spunta Reporting
* NUMBERFORMAT    ZNUMBERFORMAT    CHAR 20  0 Formato numerico (upper/lower case)
* - String  Tratta numero come testo
* - Testo	Tratta numero come testo
* - V	Valuta
* - D	Data
* - #,##0	       0 decimals
* - #,##0.0	       1 decimals
* - #,##0.00         2 decimals
* - #,##0.000	       3 decimals
* - #,##0.0000  4 decimals
* - ......... Others
* BORDER_BOTTOM ZLINEBORDER	   CHAR	1	0	Line border
* - 1	Continuous
* - 2	Continuous
* - 3	Continuous
* - A	Dash
* - B	DashDot
* - C	DashDotDot
* - D	Dot
* - E	Double
* - F	SlantDashDot
* BORDER_LEFT	  ZLINEBORDER	   CHAR	1	0	Line border
* BORDER_RIGHT    ZLINEBORDER	   CHAR	1	0	Line border
* BORDER_TOP    ZLINEBORDER    CHAR 1 0 Line border
* FONTNAME    ZFONTNAME    CHAR 15  0 Nome font
* - .......... EXCEL Font name
* CHAR_SIZE	  ZSIZE	   	   CHAR	2	0	Dimensione carattere
* - ..         Caracter size
* CHAR_COLOR    ZCOLOR     CHAR 6 0 Colore
* - 000000  Black
* - FFFFFF  White
* - FF0000  Red
* - 00FF00  Green
* - 0000FF  Blue
* - FFFF00  Yellow
* - FF00FF  Magenta
* - 00FFFF  Cyan
* - ......      Others color
* BACK_COLOR    ZCOLOR     CHAR 6 0 Colore

DATA: w_doc_type(3),
      w_xml_table   TYPE solix_tab,
      w_xml_size    TYPE i.

************************************************************************
*            °°°°°°°°   SCHERMO DI SELEZIONE   °°°°°°°°°               *
************************************************************************
SELECTION-SCREEN: BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS: s_erdat FOR vbrk-erdat.
SELECTION-SCREEN END   OF BLOCK blk1.

SELECTION-SCREEN: BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-t02.
SELECT-OPTIONS: s_email  FOR wa_email
NO INTERVALS DEFAULT 'necip.ertug@detaysoft.com' LOWER CASE.
SELECTION-SCREEN END   OF BLOCK blk2.

*--------------------------------------------------------------------
* s t a r t - o f - s e l e c t i o n.
*--------------------------------------------------------------------
START-OF-SELECTION.

  REFRESH it_data.

*_ Leggo le fatture SD contabilizzate
  SELECT a~vbeln    a~vkorg    a~fkart    a~vbtyp
         a~waerk    a~netwr    a~mwsbk
         b~bukrs    b~belnr    b~gjahr    b~budat

    INTO CORRESPONDING FIELDS OF TABLE it_data
    FROM vbrk AS a
    JOIN bkpf AS b
      ON b~awtyp = 'VBRK'
     AND b~awkey = a~vbeln
   WHERE a~erdat IN s_erdat
   ORDER BY b~budat b~bukrs b~gjahr b~belnr.


END-OF-SELECTION.

  IF s_email[] IS NOT INITIAL
  AND it_data[] IS NOT INITIAL.
    PERFORM crea_attachment.
*    PERFORM send_mail.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  CREA_ATTACHMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM crea_attachment .

  DATA: w_row       TYPE i,
        w_border(4) TYPE c,                     "Top Right Bottom Left
        w_value(40),
        ctr_lines   TYPE i.

  DATA: BEGIN OF it_tot OCCURS 0,
          waerk LIKE vbrk-waerk,
          netwr LIKE vbrk-netwr,
          mwsbk LIKE vbrk-mwsbk,
        END OF it_tot.

* MACRO
  DEFINE cella.            " load one cell
    CLEAR s_excel.
    MOVE &1            TO s_excel-sheet_nro.
    MOVE &2            TO s_excel-row_nro.
    MOVE &3            TO s_excel-column_nro.
    MOVE &4            TO s_excel-value.
    MOVE &5            TO s_excel-bold.
    MOVE &6            TO s_excel-justify.
    MOVE &7            TO s_excel-numberformat.
    MOVE &8            TO w_border.
    MOVE w_border+0(1) TO s_excel-border_top.
    MOVE w_border+1(1) TO s_excel-border_right.
    MOVE w_border+2(1) TO s_excel-border_bottom.
    MOVE w_border+3(1) TO s_excel-border_left.
    MOVE &9            TO s_excel-back_color.
    APPEND s_excel TO it_excel.
  END-OF-DEFINITION.

  REFRESH it_excel.

* Header
  cella 1 1 1 sy-repid      ' ' 'C' '' '    ' '      ' .

  MOVE 3 TO w_row.

* Header BOLD
  cella 1 w_row  1  TEXT-h01 'X' 'C' '' '3 33' 'FFFF00' .  "vbeln
  cella 1 w_row  2  TEXT-h02 'X' 'C' '' '3 3 ' 'FFFF00' .  "vkorg
  cella 1 w_row  3  TEXT-h03 'X' 'C' '' '3 3 ' 'FFFF00' .  "fkart
  cella 1 w_row  4  TEXT-h04 'X' 'C' '' '3 3 ' 'FFFF00' .  "vbtyp
  cella 1 w_row  5  TEXT-h05 'X' 'C' '' '3 3 ' 'FFFF00' .  "waerk
  cella 1 w_row  6  TEXT-h06 'X' 'R' '' '3 3 ' 'FFFF00' .  "netwr
  cella 1 w_row  7  TEXT-h07 'X' 'R' '' '3 3 ' 'FFFF00' .  "mwsbk
  cella 1 w_row  8  TEXT-h08 'X' 'C' '' '3 3 ' 'FFFF00' .  "bukrs
  cella 1 w_row  9  TEXT-h09 'X' 'C' '' '3 3 ' 'FFFF00' .  "belnr
  cella 1 w_row 10  TEXT-h10 'X' 'C' '' '3 3 ' 'FFFF00' .  "gjahr
  cella 1 w_row 11  TEXT-h11 'X' 'C' '' '333 ' 'FFFF00' .  "budat

  REFRESH it_tot.

* Detail rows
  LOOP AT it_data.
    ADD 1 TO w_row.
    cella 1 w_row  1 it_data-vbeln       ''  'C' ' ' '' '' .
    cella 1 w_row  2 it_data-vkorg       ''  'C' ' ' '' '' .
    cella 1 w_row  3 it_data-fkart       ''  'C' ' ' '' '' .
    cella 1 w_row  4 it_data-vbtyp       ''  'C' ' ' '' '' .
    cella 1 w_row  5 it_data-waerk       ''  'C' ' ' '' '' .
    WRITE it_data-netwr TO w_value CURRENCY it_data-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
    cella 1 w_row  6 w_value             ''  'R' 'V' '' '' .
    WRITE it_data-mwsbk TO w_value CURRENCY it_data-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
    cella 1 w_row  7 w_value             ''  'R' 'V' '' '' .
    cella 1 w_row  8 it_data-bukrs       ''  'C' ' ' '' '' .
    cella 1 w_row  9 it_data-belnr       ''  'C' ' ' '' '' .
    cella 1 w_row 10 it_data-gjahr       ''  'C' ' ' '' '' .
    cella 1 w_row 11 it_data-budat       ''  'C' 'D' '' '' .

*_ do sum
    CLEAR it_tot.
    MOVE-CORRESPONDING it_data TO it_tot.
    CASE it_data-vbtyp.
      WHEN 'M'.                     " fattura
      WHEN 'P'.                     " nota di debito
      WHEN 'N'.                     " storno fattura
        MULTIPLY it_tot-netwr BY -1.
        MULTIPLY it_tot-mwsbk BY -1.
      WHEN 'O'.                     " accredito
        MULTIPLY it_tot-netwr BY -1.
        MULTIPLY it_tot-mwsbk BY -1.
    ENDCASE.
    COLLECT it_tot.

  ENDLOOP.

* Print totals
  SORT it_tot.
  DESCRIBE TABLE it_tot LINES ctr_lines.
  LOOP AT it_tot.
    ADD 1 TO w_row.
    IF ctr_lines = 1.               "Only one row
      cella 1 w_row  5 it_tot-waerk   'X'  'C' ''  '2122' 'CCFFCC' .
      WRITE it_tot-netwr TO w_value CURRENCY it_tot-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
      cella 1 w_row  6 w_value        'X'  'R' 'V' '212 ' 'CCFFCC' .
      WRITE it_tot-mwsbk TO w_value CURRENCY it_tot-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
      cella 1 w_row  7 w_value        'X'  'R' 'V' '222 ' 'CCFFCC' .
    ELSEIF sy-tabix = 1.            "First of more rows
      cella 1 w_row  5 it_tot-waerk   'X'  'C' ''  '2112' 'CCFFCC' .
      WRITE it_tot-netwr TO w_value CURRENCY it_tot-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
      cella 1 w_row  6 w_value        'X'  'R' 'V' '211 ' 'CCFFCC' .
      WRITE it_tot-mwsbk TO w_value CURRENCY it_tot-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
      cella 1 w_row  7 w_value        'X'  'R' 'V' '221 ' 'CCFFCC' .
    ELSEIF sy-tabix = ctr_lines.    "Last of more rows
      cella 1 w_row  5 it_tot-waerk   'X'  'C' ''  ' 122' 'CCFFCC' .
      WRITE it_tot-netwr TO w_value CURRENCY it_tot-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
      cella 1 w_row  6 w_value        'X'  'R' 'V' ' 12 ' 'CCFFCC' .
      WRITE it_tot-mwsbk TO w_value CURRENCY it_tot-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
      cella 1 w_row  7 w_value        'X'  'R' 'V' ' 22 ' 'CCFFCC' .
    ELSE.                            "Next, but not last, of more rows
      cella 1 w_row  5 it_tot-waerk   'X'  'C' ''  ' 112' 'CCFFCC' .
      WRITE it_tot-netwr TO w_value CURRENCY it_tot-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
      cella 1 w_row  6 w_value        'X'  'R' 'V' ' 11 ' 'CCFFCC' .
      WRITE it_tot-mwsbk TO w_value CURRENCY it_tot-waerk NO-ZERO NO-GROUPING LEFT-JUSTIFIED.
      cella 1 w_row  7 w_value        'X'  'R' 'V' ' 21 ' 'CCFFCC' .
    ENDIF.
  ENDLOOP.

* Create XML Module
  CALL FUNCTION 'ZNCPRH_FG003_001'
    EXPORTING
      i_excel_data       = it_excel
    IMPORTING
      e_doc_type         = w_doc_type
      e_xml_table        = w_xml_table
      e_xml_size         = w_xml_size
    EXCEPTIONS
      posizione_mancante = 1
      posizione_ripetuta = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " CREA_ATTACHMENT

FORM send_mail .

  DATA att             TYPE STANDARD TABLE OF rmps_post_content WITH HEADER LINE.
  DATA t_recipient     TYPE TABLE OF zncprh_s024.
* zt_mail_dest type table of ZMAIL_DEST
  DATA s_recipient     TYPE zncprh_s024.
* ZMAIL_DEST
* EMAIL     AD_SMTPADR  CHAR  241 0 Indirizzo e-mail
* UNAME     UNAME   CHAR  12  0 Nome utente
* HIGH_PRIORITY   CHECKBOX    CHAR  1 0 Casella di spunta Reporting
* CARBON_COPY     CHECKBOX    CHAR  1 0 Casella di spunta Reporting
  DATA w_subject       TYPE string.
  DATA w_return        TYPE bapiret2.
  DATA t_body          TYPE bcsy_text.
  DATA s_body          TYPE soli.

* Subject
  MOVE 'IXML Excel' TO w_subject.

* Body
  REFRESH t_body.

* Attachment
  REFRESH att.

* Creation of the Document Attachment
  CLEAR att.
  CONCATENATE 'V3_' sy-datum '_' sy-uzeit INTO att-subject.
  MOVE w_doc_type     TO att-doc_type.
  MOVE 'X'            TO att-binary.
  MOVE w_xml_table    TO att-cont_hex.
  MOVE w_xml_size     TO att-docsize..
  APPEND att.

* Recipient
  REFRESH t_recipient.
  CLEAR s_recipient.
  LOOP AT s_email.
    MOVE s_email-low TO s_recipient-email.
    APPEND s_recipient TO t_recipient.
  ENDLOOP.

* Send EMAIL
  CALL FUNCTION 'ZNCPRH_FG003_002'
    EXPORTING
      subject     = w_subject
      message     = '.'
      mailbody    = t_body
      attachments = att[]
      recipients  = t_recipient
    IMPORTING
      return      = w_return
    EXCEPTIONS
      no_body     = 1
      bcs_error   = 2
      OTHERS      = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " SEND_MAIL
