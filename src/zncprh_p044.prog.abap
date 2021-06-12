*&---------------------------------------------------------------------*
*& Report ZNCPRH_P044
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p044.

TABLES : zncprh_t007.

TYPE-POOLS: spta.

TYPES:  tty_emp     TYPE STANDARD TABLE OF zncprh_s033.
TYPES:  tty_result  TYPE STANDARD TABLE OF zncprh_s034.

DATA : gt_result TYPE TABLE OF zncprh_s034,
       gt_emp    TYPE  TABLE OF zncprh_s033.

DATA: gv_snd_task TYPE i,
      gv_ptask    TYPE i,
      gv_rcv_task TYPE i.

FIELD-SYMBOLS: <gfs_result> TYPE zncprh_s034.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS:
  p_rfcgr TYPE spta_rfcgr OBLIGATORY MEMORY ID spta_rfcgr,
  p_file  TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.


include zncprh_p044_i001.

INITIALIZATION.
* Not just anybody may execute this report

  AUTHORITY-CHECK OBJECT 'S_ADMI_FCD'
    ID 'S_ADMI_FCD' FIELD 'PADM'.
  IF NOT sy-subrc IS INITIAL.
    RAISE no_authority_for_report.
  ENDIF.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file .

  PERFORM f_get_file .

START-OF-SELECTION.

  PERFORM f_sub_get_data USING  p_file
                         CHANGING gt_emp.

  DELETE FROM zncprh_t007 WHERE tplnr NE space.
  COMMIT WORK AND WAIT.

PERFORM f_sub_upload_data USING    gt_emp
                          CHANGING gt_result.
