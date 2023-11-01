CLASS lhc_certificate DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setinitialvalues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR certificate~setinitialvalues.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR certificate RESULT result.

    METHODS checkmaterial FOR VALIDATE ON SAVE
      IMPORTING keys FOR certificate~checkmaterial.

    METHODS newversion FOR MODIFY
      IMPORTING keys FOR ACTION certificate~newVersion RESULT result.



    METHODS releaseversion FOR MODIFY
      IMPORTING keys FOR ACTION certificate~releaseversion RESULT result.

    METHODS archiveversion FOR MODIFY
      IMPORTING keys FOR ACTION certificate~archiveversion RESULT result.

ENDCLASS.

CLASS lhc_certificate IMPLEMENTATION.

  METHOD setinitialvalues.


    DATA lt_CertificateState TYPE TABLE FOR CREATE zi_certificate\_CertificateState.
    DATA ls_CertificateState LIKE LINE OF lt_CertificateState.
    DATA ls_CertificateStateValue LIKE LINE OF ls_certificatestate-%target.

    READ ENTITIES OF zi_certificate IN LOCAL MODE
    ENTITY certificate
    FIELDS ( Certificationstatus ) WITH CORRESPONDING #( keys )
    RESULT DATA(certificates).

    IF certificates IS NOT INITIAL.
      MODIFY ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY certificate
      UPDATE
      FIELDS ( version Certificationstatus )
      WITH VALUE #( FOR certificate IN certificates
                      ( %tky = certificate-%key
                        version = '00001'
                        Certificationstatus = '01' " neu
                       )
       ) REPORTED DATA(ls_return).
    ENDIF.

    LOOP AT certificates INTO DATA(ls_certificate).

      ls_CertificateState-%key = ls_certificate-%key.
      ls_CertificateState-CertUUID = ls_certificatestatevalue-CertUUID = ls_certificate-CertUUID.

      ls_certificatestatevalue-Status = '01'.
      CLEAR ls_certificatestatevalue-StatusOld.
      ls_certificatestatevalue-Version = '01'.

      ls_certificatestatevalue-%control-CertUUID = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-Status = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-StatusOld = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-Version =  if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-LastChangedAt =  if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-LastChangedBy =  if_abap_behv=>mk-on.
      APPEND ls_certificatestatevalue TO ls_certificatestate-%target.

      APPEND ls_certificatestate TO lt_certificatestate.

      MODIFY ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY certificate
        CREATE BY \_CertificateState
        FROM lt_CertificateState
            REPORTED DATA(ls_return_ass)
            MAPPED DATA(ls_mapped_ass)
            FAILED  DATA(ls_failed_ass).

    ENDLOOP.

  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF ZI_Certificate IN LOCAL MODE
      ENTITY Certificate
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(certificates).

    result = VALUE #( FOR Certificate IN certificates
                        ( %tky   = Certificate-%tky
                          ) ).

  ENDMETHOD.

  METHOD checkmaterial.

    READ ENTITIES OF zi_certificate IN LOCAL MODE
    ENTITY certificate
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(certificates).

    IF certificates IS NOT INITIAL.
      LOOP AT certificates INTO DATA(certificate).

        SELECT SINGLE FROM mara FIELDS matnr
          WHERE matnr = @certificate-material
          INTO @DATA(ls_mara).

        IF sy-subrc <> 0.

          APPEND VALUE #( %tky = certificate-%tky ) TO failed-certificate.

          APPEND VALUE #( %tky        = certificate-%tky
                          %msg        = NEW zcx_certificate(
                                            severity = if_abap_behv_message=>severity-information
                                            textid   = zcx_certificate=>material_unknown
                                            material = certificate-material )
                          )
            TO reported-certificate.

        ENDIF.

      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD newversion.

    DATA lt_CertificateState TYPE TABLE FOR CREATE zi_certificate\_CertificateState.
    DATA ls_CertificateState LIKE LINE OF lt_CertificateState.
    DATA ls_CertificateStateValue LIKE LINE OF ls_certificatestate-%target.
    DATA lv_status_old TYPE zbc_status.

    READ ENTITIES OF zi_certificate IN LOCAL MODE
    ENTITY certificate
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(certificates).

    LOOP AT certificates INTO DATA(ls_Certificate).
      ADD 1 TO ls_Certificate-Version.
      lv_status_old = ls_Certificate-CertificationStatus.
      ls_Certificate-CertificationStatus = '01'. " neu
    ENDLOOP.

    " Set the new overall status
    MODIFY ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY Certificate
         UPDATE
           FIELDS ( Version CertificationStatus )
           WITH VALUE #( FOR key IN keys
                           ( %tky    = key-%tky
                             Version = ls_Certificate-Version
                             CertificationStatus = ls_Certificate-CertificationStatus ) )
      FAILED failed
      REPORTED reported.

*    " Fill the response table
    READ ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY certificate
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT certificates.

    result = VALUE #( FOR certificate IN certificates
                        ( %tky   = certificate-%tky
                          %param = certificate
                          ) ).

* Fill Certificate State
    LOOP AT certificates INTO ls_certificate.

      ls_CertificateState-%key = ls_certificate-%key.
      ls_CertificateState-CertUUID = ls_certificatestatevalue-CertUUID = ls_certificate-CertUUID.

      ls_certificatestatevalue-Status = ls_certificate-CertificationStatus.
      ls_certificatestatevalue-StatusOld = lv_status_old.
      ls_certificatestatevalue-Version = ls_certificate-Version.
      ls_certificatestatevalue-%control-CertUUID = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-Status = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-StatusOld = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-Version =  if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-LastChangedAt =  if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-LastChangedBy =  if_abap_behv=>mk-on.
      APPEND ls_certificatestatevalue TO ls_certificatestate-%target.

      APPEND ls_certificatestate TO lt_certificatestate.

      MODIFY ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY certificate
        CREATE BY \_CertificateState
        FROM lt_CertificateState
            REPORTED DATA(ls_return_ass)
            MAPPED DATA(ls_mapped_ass)
            FAILED  DATA(ls_failed_ass).




    ENDLOOP.

  ENDMETHOD.

  METHOD releaseversion.

    DATA lt_CertificateState TYPE TABLE FOR CREATE zi_certificate\_CertificateState.
    DATA ls_CertificateState LIKE LINE OF lt_CertificateState.
    DATA ls_CertificateStateValue LIKE LINE OF ls_certificatestate-%target.
    DATA lv_status_old TYPE zbc_status.

    READ ENTITIES OF zi_certificate IN LOCAL MODE
    ENTITY certificate
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(certificates).

    READ TABLE certificates INTO DATA(ls_Certificate) INDEX 1.
    IF sy-subrc = 0.
      lv_status_old = ls_Certificate-CertificationStatus.
      ls_Certificate-CertificationStatus = '02'. " aktiv
    ENDIF.

    " Set the new overall status
    MODIFY ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY Certificate
         UPDATE
           FIELDS ( CertificationStatus )
           WITH VALUE #( FOR key IN keys
                           ( %tky    = key-%tky
                             CertificationStatus = ls_Certificate-CertificationStatus ) )
      FAILED failed
      REPORTED reported.


*    " Fill the response table
    READ ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY certificate
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT certificates.

    result = VALUE #( FOR certificate IN certificates
                        ( %tky   = certificate-%tky
                          %param = certificate
                          ) ).

* Fill Certificate State
    LOOP AT certificates INTO ls_certificate.

      ls_CertificateState-%key = ls_certificate-%key.
      ls_CertificateState-CertUUID = ls_certificatestatevalue-CertUUID = ls_certificate-CertUUID.

      ls_certificatestatevalue-Status = ls_certificate-CertificationStatus.
      ls_certificatestatevalue-StatusOld = lv_status_old.
      ls_certificatestatevalue-Version = ls_certificate-Version.
      ls_certificatestatevalue-%control-CertUUID = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-Status = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-StatusOld = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-Version =  if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-LastChangedAt =  if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-LastChangedBy =  if_abap_behv=>mk-on.
      APPEND ls_certificatestatevalue TO ls_certificatestate-%target.

      APPEND ls_certificatestate TO lt_certificatestate.

      MODIFY ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY certificate
        CREATE BY \_CertificateState
        FROM lt_CertificateState
            REPORTED DATA(ls_return_ass)
            MAPPED DATA(ls_mapped_ass)
            FAILED  DATA(ls_failed_ass).

    ENDLOOP.


  ENDMETHOD.

  METHOD archiveversion.

    DATA lt_CertificateState TYPE TABLE FOR CREATE zi_certificate\_CertificateState.
    DATA ls_CertificateState LIKE LINE OF lt_CertificateState.
    DATA ls_CertificateStateValue LIKE LINE OF ls_certificatestate-%target.
    DATA lv_status_old TYPE zbc_status.

    READ ENTITIES OF zi_certificate IN LOCAL MODE
    ENTITY certificate
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(certificates).

    READ TABLE certificates INTO DATA(ls_Certificate) INDEX 1.
    IF sy-subrc = 0.
      lv_status_old = ls_Certificate-CertificationStatus.
      ls_Certificate-CertificationStatus = '03'. " inaktiv
    ENDIF.

    " Set the new overall status
    MODIFY ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY Certificate
         UPDATE
           FIELDS ( CertificationStatus )
           WITH VALUE #( FOR key IN keys
                           ( %tky    = key-%tky
                             CertificationStatus = ls_Certificate-CertificationStatus ) )
      FAILED failed
      REPORTED reported.


*    " Fill the response table
    READ ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY certificate
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT certificates.

    result = VALUE #( FOR certificate IN certificates
                        ( %tky   = certificate-%tky
                          %param = certificate
                          ) ).


* Fill Certificate State
    LOOP AT certificates INTO ls_certificate.

      ls_CertificateState-%key = ls_certificate-%key.
      ls_CertificateState-CertUUID = ls_certificatestatevalue-CertUUID = ls_certificate-CertUUID.

      ls_certificatestatevalue-Status = ls_certificate-CertificationStatus.
      ls_certificatestatevalue-StatusOld = lv_status_old.
      ls_certificatestatevalue-Version = ls_certificate-Version.
      ls_certificatestatevalue-%control-CertUUID = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-Status = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-StatusOld = if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-Version =  if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-LastChangedAt =  if_abap_behv=>mk-on.
      ls_certificatestatevalue-%control-LastChangedBy =  if_abap_behv=>mk-on.
      APPEND ls_certificatestatevalue TO ls_certificatestate-%target.

      APPEND ls_certificatestate TO lt_certificatestate.

      MODIFY ENTITIES OF zi_certificate IN LOCAL MODE
      ENTITY certificate
        CREATE BY \_CertificateState
        FROM lt_CertificateState
            REPORTED DATA(ls_return_ass)
            MAPPED DATA(ls_mapped_ass)
            FAILED  DATA(ls_failed_ass).

    ENDLOOP.

  ENDMETHOD.


ENDCLASS.
