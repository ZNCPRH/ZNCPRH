*&---------------------------------------------------------------------*
*& Report ZNCPRH_P009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p009.

DATA : ls_bpa TYPE snwd_bpa.

SELECT-OPTIONS : bp_id FOR ls_bpa-bp_id,
                 cur_code FOR ls_bpa-currency_code.

DATA(lv_where) = cl_shdb_seltab=>combine_seltabs(
it_named_seltabs = VALUE #(
         ( name = 'BP_ID'         dref = REF #( bp_id[] ) )
         ( name = 'CURRENCY_CODE' dref = REF #( cur_code[] ) ) )
         iv_client_field = 'CLIENT' ).

BREAK p1362.
