*&---------------------------------------------------------------------*
*& Report ZNCPRH_P250
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p250.

PARAMETERS mat_bas(40).
PARAMETERS mat_son(40).
SELECT * FROM zncprh_cds011( im_matnrfirst = @mat_bas ,
                             im_matnrlast  = @mat_son ) INTO TABLE @DATA(itab).
SORT itab BY matnr.

BREAK p1362.
