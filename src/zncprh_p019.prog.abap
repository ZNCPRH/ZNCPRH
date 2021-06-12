*&---------------------------------------------------------------------*
*& Report ZNCPRH_P019
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p019.

DATA : gt_receiver    TYPE zncprh_tt003,
       gs_receiver    LIKE LINE OF gt_receiver,
       gv_content     TYPE rssce-tdname VALUE 'ZNCPRH_ST001',
       gv_sender      TYPE ad_smtpadr VALUE 'sap@sap.com',
       gv_html_string TYPE string,
       gt_mail_ret    TYPE fmfg_t_bapireturn.

DATA : gt_fcat    TYPE lvc_t_fcat,
       gv_tabname TYPE tabname VALUE 'ZNCPRH_S018',
       gv_message TYPE string.

DATA : gt_table TYPE TABLE OF zncprh_s018.


APPEND VALUE #( mtext = 'necip.ertug@detaysoft.com' ) TO gt_receiver.
APPEND VALUE #( bukrstx = '1000-Şirket Kodu'
                persatx = '1000-Personel Alanı'
                btrtltx = '1100-Personel Alt Alanı'
                pernr   = 1362
                fnam    = 'NECİP REHA ERTUĞ'
               ) TO gt_table.

"Mail tablo İçeriği fcat
REFRESH : gt_fcat.
zncprh_cl002=>get_fcat_mail(
  EXPORTING
    iv_tabname =  gv_tabname
  CHANGING
    ch_fcat    =  gt_fcat
).

gv_message = 'Tablonun üstündeki mesaj..'.

zncprh_cl002=>itab_fcat_mail_content(
    EXPORTING
      itab    = gt_table
      fcat    = gt_fcat
      message = gv_message
    IMPORTING
      ev_html = gv_html_string
  ).

zncprh_cl002=>send_mail_001(
            EXPORTING
               it_receiver    = gt_receiver
               ip_content     = gv_content"burada sadece başlık için
                                          "başka bir işlevi yok
               i_sender       = gv_sender
               html_string    = gv_html_string
               i_langu        = 'T'
               commit         = 'X'
            IMPORTING
               t_return       = gt_mail_ret ) .
