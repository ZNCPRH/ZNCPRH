@AbapCatalog.sqlViewName: 'ZNCPRH_DDL011'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Parametre işlemleri'
define view zncprh_cds011  with parameters im_matnrfirst: abap.char(40),
                                           im_matnrlast:  abap.char(40)
    as select from mara
        {
        *
        } where matnr between $parameters.im_matnrfirst and $parameters.im_matnrlast
