@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Zertifikatsverwaltung Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_Certificate
  as select from zbca_certificate as Certificate
  composition [0..*] of ZI_CertificateState as _CertificateState
  association [0..1] to I_MaterialText      as _MaterialText on  $projection.Material = _MaterialText.Material 
  association [0..1] to ZI_Status_VH      as _StatusText on $projection.CertificationStatus = _StatusText.Low

{
  key cert_uuid             as CertUUID,

      matnr                 as Material,
      version               as Version,
      cert_status           as CertificationStatus,
      _StatusText.Text      as StatusText,
      cert_ce               as CertificateCe,
      cert_gs               as CertificateGs,
      cert_fcc              as CertificateFcc,
      cert_iso              as CertificateIso,
      cert_tuev             as CertificateTuev,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      case 
        when ( cert_status = '01' or cert_status = '04' ) // neu oder teilaktiv
          then 2         //ICON_YELLOW_LIGHT
        when ( cert_status = '03'  or cert_status is initial ) // inaktiv oder leer
          then 1         //ICON_RED_LIGHT
        else 3           //ICON_GREEN_LIGHT
      end as Criticality,
            
      _CertificateState,
      _MaterialText,
      _StatusText
}
