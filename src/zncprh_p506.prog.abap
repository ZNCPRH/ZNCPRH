*&---------------------------------------------------------------------*
*& Report ZNCPRH_P506
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p506.

SELECT * FROM mara INTO TABLE @DATA(lt_mara).


DATA(lv_sum_brgew) = REDUCE brgew( INIT x = CONV brgew( 0 )
            FOR ls_mara IN lt_mara WHERE ( ersda = '20181108' )
             NEXT x = x + ls_mara-brgew ).

*--------------------------------------------------------------------*
DATA(lv_sum_record) = REDUCE i( INIT y = CONV i( 0 )
         FOR ls_mara IN lt_mara WHERE ( ernam = 'P1434' )
              NEXT y = y + 1 ).

BREAK-POINT.
