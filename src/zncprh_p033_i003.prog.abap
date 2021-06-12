*&---------------------------------------------------------------------*
*& Include          ZNCPRH_P033_I003
*&---------------------------------------------------------------------*
MODULE status_1362 OUTPUT.

  SET PF-STATUS 'GUI'.
  SET TITLEBAR 'TITLE' WITH gr_report->gc_title1.

  gr_report->set_variant_options( ).
  gr_report->create_layo_and_fcat( EXPORTING sname  = gr_report->gc_tab_s82
                                   CHANGING  layout = gr_report->gs_layout_up
                                             fcat   = gr_report->gt_fcat_up ).

  gr_report->exculude_tb( CHANGING functions = gr_report->gt_functions_up ).

  gr_report->display_alv( EXPORTING   layout    = gr_report->gs_layout_up
                                      variant   = gr_report->gs_variant_up
                                      functions = gr_report->gt_functions_up
                          CHANGING    gref      = gr_report->gref_alv_up
                                      table     = gt_header
                                      fcat      = gr_report->gt_fcat_up ).

*  IF gr_report->gt_fcat_down  IS INITIAL.<
  gr_report->create_layo_and_fcat( EXPORTING sname   = gr_report->gc_tab_s83
                                             celltab_key = abap_true
                                   CHANGING  layout  = gr_report->gs_layout_down
                                             fcat    = gr_report->gt_fcat_down ).


  gr_report->exculude_tb( CHANGING functions = gr_report->gt_functions_down ).

  gr_report->display_alv( EXPORTING   layout    = gr_report->gs_layout_down
                                      variant   = gr_report->gs_variant_down
                                      functions = gr_report->gt_functions_down
                          CHANGING    gref      = gr_report->gref_alv_down
                                      table     = gt_item
                                      fcat      = gr_report->gt_fcat_down ).
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1362  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1362 INPUT.
  CASE sy-ucomm.
    WHEN '&F03' OR '&F15' OR '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
