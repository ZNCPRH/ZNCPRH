*&---------------------------------------------------------------------*
*& Report ZNCPRH_P507
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p507.

DATA(lv_type_tmp) = SWITCH char31( sy-langu
                                      WHEN 'T' THEN 'Türkçe' "case gibi çalıştığını belirt.
                                      WHEN 'E' THEN 'İngilizce'
                                      ELSE 'Dil yok' ).
BREAK-POINT.
