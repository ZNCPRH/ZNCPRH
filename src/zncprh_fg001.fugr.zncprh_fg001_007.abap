FUNCTION zncprh_fg001_007.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_ROTP) TYPE  CHAR10 OPTIONAL
*"     VALUE(I_OBJECT) TYPE  TEXT128 OPTIONAL
*"  EXPORTING
*"     REFERENCE(EX_SUBRC) TYPE  SY-SUBRC
*"----------------------------------------------------------------------
  TABLES :progdir   ,
          trdir     ,
          tstc      ,
          vcldirt   ,
          dd25t     ,
          o2applt   ,
          wdy_componentt.
  IF i_rotp EQ 'TSTC'. "tcode
    SELECT SINGLE *       FROM tstc
                          WHERE tcode EQ i_object .
  ELSEIF i_rotp EQ 'REPORT'."rapor
    SELECT SINGLE *       FROM trdir
                          WHERE  name = i_object.
  ELSEIF i_rotp EQ 'VCLDATA'."view cluster
    SELECT SINGLE *        FROM vcldirt
                           WHERE vclname EQ i_object.
  ELSEIF i_rotp EQ 'VIEWDATA'."view
    SELECT SINGLE *     FROM dd25t
                             WHERE  viewname EQ i_object.
  ELSEIF i_rotp EQ 'B'."bsp
    SELECT SINGLE *       FROM o2applt
                             WHERE applname EQ i_object .
  ELSEIF i_rotp EQ 'W'."web app
    SELECT SINGLE *       FROM wdy_componentt
                              WHERE component_name EQ i_object .
  ENDIF.
  ex_subrc = sy-subrc.

ENDFUNCTION.
