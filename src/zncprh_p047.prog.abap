*&---------------------------------------------------------------------*
*& Report ZNCPRH_P047
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p047.

    DATA : l_jobname      TYPE btcjob,
           l_jobcount     TYPE btcjobcnt,
           lv_daily_count TYPE i,
           lv_uzeit       TYPE sy-uzeit,
           lv_datum       TYPE sy-datum.


    SELECT SINGLE * FROM qmih INTO @DATA(ls_qmih)
      WHERE qmnum EQ '1'.

    IF ls_qmih-plnnr IS NOT INITIAL AND
        ls_qmih-plnal IS NOT INITIAL .

      l_jobname =  'ZPM' && '3'
                   && ls_qmih-plnnr && ls_qmih-plnal.

      CONDENSE l_jobname NO-GAPS.

      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          jobname  = l_jobname
        IMPORTING
          jobcount = l_jobcount
        EXCEPTIONS
          OTHERS   = 1.
      IF sy-subrc = 0.

        lv_datum = sy-datum.

        IF sy-uzeit GE '235830'.

          CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
            EXPORTING
              date      = lv_datum
              days      = '01'
              months    = '00'
              signum    = '+'
              years     = '00'
            IMPORTING
              calc_date = lv_datum.
        ENDIF.

        lv_uzeit = sy-uzeit + 90.

        SUBMIT zpmiga_p042
                    VIA JOB  l_jobname
                      NUMBER  l_jobcount
                        WITH p_aufnr = '3'
                         WITH p_plnnr = ls_qmih-plnnr
                          WITH p_plnal = ls_qmih-plnal
                           AND RETURN.


        CALL FUNCTION 'JOB_CLOSE'
          EXPORTING
            jobcount             = l_jobcount
            jobname              = l_jobname
         "  strtimmed            = 'X'
            sdlstrtdt            = lv_datum
            sdlstrttm            = CONV btcstime( lv_uzeit )
          EXCEPTIONS
            cant_start_immediate = 1
            invalid_startdate    = 2
            jobname_missing      = 3
            job_close_failed     = 4
            job_nosteps          = 5
            job_notex            = 6
            lock_failed          = 7
            invalid_target       = 8
            invalid_time_zone    = 9
            OTHERS               = 10.

      ENDIF.
    ENDIF.
