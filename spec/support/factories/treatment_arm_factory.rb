# TreatmentArm and TreatmentArmAssignmentEvent Factories

FactoryGirl.define do
  factory :treatment_arm, class: TreatmentArm do
    name 'EAY131-test'
    treatment_arm_id 'APEC1621-A'
    version '2016-20-02'
    stratum_id '12'
    active true
    date_created '2020-10-05'
    description 'This is the sample Description'
    target_id 'HDFD'
    treatment_arm_status 'OPEN'
    num_patients_assigned 2
    date_opened '2015-10-07'
    study_id 'APEC1621'
    target_name 'Crizotinib'
    gene 'GENE'
    treatment_arm_drugs []
    snv_indels []
    diseases []
    exclusion_drugs [
      {
        'drug_id' => '763093',
        'name' => 'Trametinib',
        'pathway' => 'B-RAF inhibitor',
        'target' => 'B-RAF'
      },
      {
        'drug_id' => '763760',
        'name' => ''
      },
      {
        'drug_id' => '',
        'name' => 'Trametinib'
      },
      {
        'drug_id' => '763093',
        'name' => 'Trametinib',
        'pathway' => '',
        'target' => 'B-RAF'
      }
    ]
    assay_rules []
    gene_fusions []
    non_hotspot_rules []
    copy_number_variants []
    not_enrolled_patients 1
    former_patients 1
    pending_patients 1
    current_patients 1
    version_pending_patients 1
    version_former_patients 2
    version_not_enrolled_patients 1
    version_current_patients 1
  end

  factory :treatment_arm_assignment_event, class: TreatmentArmAssignmentEvent do
    assignment_date '2012-02-20'
    date_on_arm '2016-05-27'
    date_off_arm '2013-01-19'
    patient_id '200re'
    treatment_arm_id 'EAC123'
    stratum_id 'EAY131'
    patient_status 'PENDING_CONFIRMATION'
    assignment_reason ''
    diseases [
      { 'drug_id': '1234' }
    ]
    version '2012-02-20'
    step_number '0'
    analysis_id '1'
    molecular_id '2'
    surgical_event_id '3'
    variant_report {}
    assignment_report {}
    event 'EVENT_INIT'
  end

  factory :updated_treatment_arm_assignment_event, class: TreatmentArmAssignmentEvent do
    assignment_date '2012-02-20'
    date_on_arm '2016-05-27'
    date_off_arm '2013-01-19'
    patient_id '200re'
    treatment_arm_id 'EAC123'
    stratum_id 'EAY131'
    patient_status 'PENDING_APPROVAL'
    assignment_reason ''
    diseases [
      { 'drug_id': '1234' }
    ]
    version '2012-02-20'
    step_number '0'
    analysis_id '1'
    molecular_id '2'
    surgical_event_id '3'
    variant_report {}
    assignment_report {}
    event 'EVENT_INIT'
  end

  factory :cog_treatment_arm, class: TreatmentArm do
    treatment_arm_id 'EAC123'
    stratum_id 'EAY131'
    treatment_arm_status 'SUSPENDED'
    treatment_arm_drugs []
    status_log '1480454602': 'OPEN'
  end

  factory :message, class: TreatmentArm do
    '{\'treatment_arm\':{\'treatment_arm_id\':\'A\'
    \'name\':\'APEC1621-A\'
    \'version\':\'v1\'
    \'stratum_id\':\'B\'
    \'description\':\'TEST Treatment Arm used by Cucumber Tests\'
    \'target_id\':\'113\'
    \'target_name\':\'Crizotinib\'
    \'gene\':\'ALK\'
    \'study_id\':\'APEC1621\'
    \'assay_rules\':[]
    \'treatment_arm_drugs\':[]
    \'snv_indels\':[]
    \'non_hotspot_rules\':[]
    \'copy_number_variants\':[]
    \'gene_fusions\':[]
    \'diseases\':[]
    \'exclusion_drugs\':[]'
  end
end