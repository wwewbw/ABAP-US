@AbapCatalog.sqlViewName: 'ZISTATUSVH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Wertehilfe für Status'
define view ZI_Status_VH 
  as select from zi_domain_value_vh
{
  key  Low,
       @Semantics.text: true
       @Search.defaultSearchElement: true
       @Search.fuzzinessThreshold: 0.8
       @Search.ranking: #HIGH
       Text
}
where
  zi_domain_value_vh.DomainName = 'ZBC_STATUS'
