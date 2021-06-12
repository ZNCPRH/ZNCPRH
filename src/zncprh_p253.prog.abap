*&---------------------------------------------------------------------*
*& Report ZNCPRH_P253
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p253.
TABLES : bseg.
SELECT-OPTIONS : bukrs FOR bseg-bukrs,
                 belnr FOR bseg-belnr,
                 gjahr FOR bseg-gjahr.

DATA(lv_where) = cl_shdb_seltab=>combine_seltabs(
it_named_seltabs = VALUE #(
         ( name = 'BUKRS' dref = REF #( bukrs[] ) )
         ( name = 'BELNR' dref = REF #( belnr[] ) )
         ( name = 'GJAHR' dref = REF #( gjahr[] ) )                                                  )
         iv_client_field = 'MANDT' ).

DATA : gt_itab TYPE TABLE OF zncprh_ddl003.
DATA(lcl_class) = NEW zncprh_cl011(  ).

lcl_class->get_data_dynamic(
  EXPORTING
    iv_where = lv_where
  IMPORTING
    et_data  = gt_itab
).

BREAK p1362.
