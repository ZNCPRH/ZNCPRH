*&---------------------------------------------------------------------*
*& Report ZNCPRH_P036
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p036.

DATA: v_area_handle TYPE REF TO zncprh_cl010,
      v_root        TYPE REF TO zncprh_cl009.
"https://blogs.sap.com/2012/04/02/shared-memory-enabled-classes-and-create-data-area-handle/
FIELD-SYMBOLS <fs_data> TYPE any.


TRY.
    v_area_handle = zncprh_cl010=>attach_for_write( ).

    CREATE OBJECT v_root AREA HANDLE v_area_handle.

    v_area_handle->set_root( v_root ).

*dref is the attribute created in root class.

    CREATE DATA v_root->dref AREA HANDLE v_area_handle TYPE string.

    ASSIGN v_root->dref->* TO <fs_data>.

    <fs_data> = 'İtirazim Var'.

    v_area_handle->detach_commit( ).

  CATCH cx_shm_external_type.

  CATCH cx_shm_attach_error.

ENDTRY.
