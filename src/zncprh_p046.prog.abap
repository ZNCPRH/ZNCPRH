*&---------------------------------------------------------------------*
*& Report ZNCPRH_P046
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p046.

DATA : wa_data TYPE zncprh_t007.

DATA : BEGIN OF is_data ,
         tplnr   TYPE tplnr,
         zzilart TYPE ingrp,
         qmgrp   TYPE qmgrp,
         zzdcr   TYPE char24,
         proid   TYPE char25,
       END OF is_data,


       it_data      LIKE STANDARD TABLE OF is_data, " internal table with contentss
       it_data_temp LIKE STANDARD TABLE OF is_data. " Internal table to store the content to be processed

DATA : lv_appsvr TYPE rzllitab-classname VALUE 'SPACE'.         " All the application servers assinged to an instance
" are grouped in the table rzllitab "       You can see the instance data's in tcode rz12

DATA : lv_total     TYPE i,           " Total no of dialog work process available in the group server
       lv_available TYPE i,           " No of dialog work process that are free.
       lv_occupied  TYPE i,           " No of occupied dialog process
       lv_diff      TYPE i,           " Percentage difference of available work process
       lv_split     TYPE i.           " No of partitions the main data is to be split

DATA : lv_lines     TYPE i,               " No of records in the internal table
       lv_lines_tab TYPE i,           " No of lines per tab
       lv_start     TYPE i,               " Start point for processing
       lv_end       TYPE i.                 " End point for processing

DATA : lv_task   TYPE string,           " Name of the task to be created
       lv_index  TYPE string,          " Variable for index
       lv_sent   TYPE i,               " No of package sent
       lv_comp   TYPE i,               " No of package completed
       lv_result TYPE flag.           " Variable to collect the result.

DATA : lv_result_string TYPE string.  " Result string

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS:
  p_rfcgr TYPE spta_rfcgr OBLIGATORY MEMORY ID spta_rfcgr,
  p_file  TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.


* Call the function module spbt_initialize the list of application server available and those that are free

  CALL FUNCTION 'SPBT_INITIALIZE'
    EXPORTING
      group_name                     = lv_appsvr
    IMPORTING
      max_pbt_wps                    = lv_total
      free_pbt_wps                   = lv_available
    EXCEPTIONS
      invalid_group_name             = 1
      internal_error                 = 2
      pbt_env_already_initialized    = 3
      currently_no_resources_avail   = 4
      no_pbt_resources_found         = 5
      cant_init_different_pbt_groups = 6
      OTHERS                         = 7.

  IF sy-subrc = 0.
* Split the data to be processed into no of work processes.
    lv_occupied = lv_total - lv_available.
* Calculate the difference in percentage
    lv_diff = ( lv_available * 100 ) / lv_total.
* Based on the available no of workprocess split the data

    IF lv_diff <= 25.
      lv_split = lv_available DIV 2.
    ELSEIF lv_diff BETWEEN 25 AND 50.
      lv_split = lv_available * 2 DIV 3.
    ELSEIF lv_diff >= 50.
      lv_split = lv_available * 3 DIV 4.
    ENDIF.

  ENDIF.

  DATA:lv_filename   TYPE string.
  CLEAR lv_filename.

  MOVE p_file TO lv_filename.


  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'DAT'
      has_field_separator     = 'X'
    TABLES
      data_tab                = it_data
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  "* Split the internal table accordingly.

  lv_lines = lines( it_data ).

  lv_lines_tab = lv_lines / lv_split.

  DO lv_split TIMES.

    lv_index = sy-index.

    CONCATENATE 'task' lv_index INTO lv_task.

    lv_start = lv_start + lv_lines_tab.
    lv_end   = lv_lines_tab + 1.

    IF lv_index = 1.
      lv_start = 0.
    ENDIF.

    IF lv_split = lv_index.
      lv_end = 0.
    ENDIF.

    it_data_temp[] =  it_data[].

    IF lv_start IS NOT INITIAL.
      DELETE it_data_temp TO lv_start.
    ENDIF.

    IF lv_end IS NOT INITIAL.
      DELETE it_data_temp FROM lv_end.
    ENDIF.


    "* Process the record set
* Call the function module to update the data.
* Here each and everytime the function module is called it will be called in a dialog work process that is free
    CALL FUNCTION 'ZNCPRH_FG005_003'
      STARTING NEW TASK lv_task DESTINATION IN GROUP lv_appsvr
*      performing update_status on end of task
      TABLES
        data = it_data_temp.
    IF sy-subrc = 0.
      lv_sent = lv_sent + 1.
    ENDIF.
  ENDDO.

  COMMIT WORK.
  WAIT UNTIL lv_comp >= lv_sent.



*&---------------------------------------------------------------------*
*&      Form  UPDATE_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA  text
*      -->P_=  text
*      -->P_IT_DATA_TEMP  text
*----------------------------------------------------------------------*
form update_status using lv_task.

  lv_comp = lv_comp + 1.

  receive results from function 'ZNCPRH_FG005_003'
  importing
    lv_result = lv_result.

  if lv_result is initial.
    lv_result_string = 'Success'.
  else.
    lv_result_string = 'Failure'.
  endif.

  concatenate 'The data passed via task' lv_task 'updation is' lv_result_string into lv_result_string separated by space.

  write : / lv_result_string.

endform.                    " UPDATE_STATUS
