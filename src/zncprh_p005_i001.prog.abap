*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P005_I001
*&---------------------------------------------------------------------*

CONSTANTS : gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab, "excellde kolon geÁ
            gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf. "excell de satir atla

DATA : gt_itab TYPE TABLE OF "zpm_s_talep_rapor .
DATA : gs_itab TYPE "zpm_s_talep_rapor .


DATA : gt_atama TYPE TABLE OF "zerp_isemir_stru .
DATA : gs_atama TYPE "zerp_isemir_stru .


DATA : gt_main_text TYPE bcsy_text .
DATA : gt_binary_content TYPE solix_tab .
DATA : gt_binary_content2 TYPE solix_tab .
DATA : gv_size TYPE so_obj_len .
DATA : gv_size2 TYPE so_obj_len .
DATA : gt_fcat TYPE lvc_t_fcat .
DATA : gs_fcat LIKE LINE OF gt_fcat .

DATA : obj TYPE REF TO lcl_main.

DATA : gr_pay_data TYPE REF TO data .
FIELD-SYMBOLS : <gt_pay_data> TYPE INDEX TABLE .
