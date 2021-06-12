*&---------------------------------------------------------------------*
*& Report ZNCPRH_P037
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p037.

"https://blogs.sap.com/2012/04/02/shared-memory-enabled-classes-and-create-data-area-handle/
DATA v_area_get TYPE REF TO zncprh_cl010.

FIELD-SYMBOLS <fs_get> TYPE any.

TRY.
    v_area_get = zncprh_cl010=>attach_for_read( ).

    ASSIGN v_area_get->root->dref->* TO <fs_get>.

    WRITE:/  <fs_get>.

    v_area_get->detach( ).
    v_area_get->free_area(
        terminate_changer = abap_true
    ).
  CATCH cx_shm_attach_error.
ENDTRY.
