@EndUserText.label: 'Zertifikatsverwaltung Projection View'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_Certificate
  as projection on ZI_Certificate as Certificate
{
      key CertUUID,
      
      @ObjectModel.text.element: ['MaterialName']
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_MaterialText', element: 'Material'} }]
      @Search.defaultSearchElement: true
      @Consumption.semanticObject: 'Material'      
      Material,
      @ObjectModel.readOnly: true
      Version,
      @Search.defaultSearchElement: true
      _MaterialText[Language = $session.system_language ].MaterialName as MaterialName,
      CertificationStatus,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_Status_VH', element: 'Text'} }]
      StatusText, 
      CertificateCe,
      CertificateGs,
      CertificateFcc,
      CertificateIso,      
      CertificateTuev,
      LocalLastChangedAt,
      Criticality,
  @ObjectModel.readOnly: true  
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CERTI_SERVICE' 
    virtual MaterialText: text150,      

      /* Associations */
      _CertificateState : redirected to composition child ZC_CertificateState,
      
      _MaterialText
}
