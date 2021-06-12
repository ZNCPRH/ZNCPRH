@AbapCatalog.sqlViewName: 'ZNCPRH_DDL019'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Consuming Table Function'
define view zncprh_cds019
  as select from zncprh_t012   as _main
    inner join   zncprh_cds018 as _amdp on _main.id = _amdp.id
{

  key _main.id,
      _main.id_desc,
      _amdp.required_value
}
