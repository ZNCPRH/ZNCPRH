@ClientDependent:false
@EndUserText.label: 'Table Function 1'
define table function zncprh_cds018
returns
{
  id             : string10;
  id_desc        : string40;
  required_value : string40;
}
implemented by method
  zncprh_cl015=>stringdata_string_operation;