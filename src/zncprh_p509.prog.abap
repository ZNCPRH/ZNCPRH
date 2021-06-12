*&---------------------------------------------------------------------*
*& Report ZNCPRH_P509
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p509.

TYPES:
  BEGIN OF struc,
    col1 TYPE i,
    col2 TYPE i,
  END OF struc.

DATA(rnd) = cl_abap_random_int=>create(
  seed = CONV i( sy-uzeit ) min = 1 max = 10 ).

DO 5 TIMES.
  DATA(struc) = VALUE struc(
    LET x = rnd->get_next( )
        y = x * x
        z = sy-index * 1000 IN col1 = x + z
                               col2 = y + z ).
  cl_demo_output=>write( struc ).
ENDDO.
cl_demo_output=>display( ).

*--------------------------------------------------------------------*
TYPES:
   BEGIN OF date,
     year  TYPE c LENGTH 4,
     month TYPE c LENGTH 2,
     day   TYPE c LENGTH 2,
   END OF date,
   dates TYPE TABLE OF date WITH EMPTY KEY.

DATA(dates) = VALUE dates(
  ( year = '2013' month = '07' day = '16' )
  ( year = '2014' month = '08' day = '31' )
  ( year = '2015' month = '09' day = '07' ) ).

DO lines( dates ) TIMES.
  DATA(isodate) = CONV string(
    LET <date>  = dates[ sy-index ]
        sep   =   '-'
     IN  <date>-year && sep && <date>-month && sep && <date>-day  ).
  cl_demo_output=>write( isodate ).
ENDDO.
cl_demo_output=>display( ).
