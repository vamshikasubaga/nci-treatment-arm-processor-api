class TreatmentArmPatient
  include Aws::Record
  include Aws::Record::RecordClassMethods
  include Aws::Record::ItemOperations::ItemOperationsClassMethods

  set_table_name "#{ENV['table_prefix']}_#{self.name.underscore}_#{Rails.env}"

  string_attr :treatment_arm_name_version, hash_key: true
  string_attr :patient_sequence_number, range_key: true
  string_attr :concordance
  string_attr :current_patient_status
  string_attr :date_created
  string_attr :description

  list_attr :diseases
  list_attr :exclusion_criterias
  list_attr :exclusion_diseases
  list_attr :exclusion_drugs

  string_attr :gene

  integer_attr :max_patients_allowed
  string_attr :name
  integer_attr :num_patients_assigned

  list_attr :patient_assignments
  list_attr :pten_results

  string_attr :target_id
  string_attr :target_name

  list_attr :treatment_arm_drugs
  string_attr :treatment_arm_status
  list_attr :variant_report
  string_attr :version

  map_attr :status_log

  integer_attr :current_step_number

end