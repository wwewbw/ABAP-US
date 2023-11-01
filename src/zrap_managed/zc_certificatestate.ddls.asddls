@EndUserText.label: 'Zertifikatsverwaltung Status Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
//define root view entity ZC_CertificateState 
define view entity ZC_CertificateState 
as projection on ZI_CertificateState as CertificateState {
    key StateUUID,
    CertUUID,

    Material,
    Version,
    Status,
    StatusOld,
    LastChangedBy,
    @Semantics.dateTime: true
    LastChangedAt,
    LocalLastChangedAt
    ,
    
    /* Associations */
    _Certificate : redirected to parent ZC_Certificate
} 
