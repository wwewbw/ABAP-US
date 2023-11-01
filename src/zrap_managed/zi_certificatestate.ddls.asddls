@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Zertifikatsverwaltung Status Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_CertificateState
  as select from zbca_certi_state as CertificateState
  association to parent ZI_Certificate as _Certificate on $projection.CertUUID = _Certificate.CertUUID

{
  key state_uuid            as StateUUID,
      cert_uuid             as CertUUID,

      matnr                 as Material,
      version               as Version,
      status                as Status,
      status_old            as StatusOld,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Certificate

}
