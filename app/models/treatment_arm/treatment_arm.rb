
class TreatmentArm
  include Aws::Record
  include Aws::Record::RecordClassMethods
  include Aws::Record::Query::QueryClassMethods

  include ActiveModel::Serializers::JSON
  include ModelSerializer

  set_table_name "#{ENV['table_prefix']}_#{self.name.underscore}_#{Rails.env}"

  boolean_attr :active, database_attribute_name: "is_active_flag"
  string_attr :name, hash_key: true
  string_attr :version, range_key: true
  string_attr :description
  integer_attr :target_id
  string_attr :target_name
  string_attr :gene
  string_attr :treatment_arm_status
  string_attr :study_id
  integer_attr :max_patients_allowed
  integer_attr :num_patients_assigned
  string_attr :date_created

  list_attr :treatment_arm_drugs
  map_attr :variant_report
  list_attr :exclusion_criterias
  list_attr :exclusion_diseases
  list_attr :exclusion_drugs
  list_attr :pten_results
  map_attr :status_log

  integer_attr :current_patients
  integer_attr :former_patients
  integer_attr :not_enrolled_patients
  integer_attr :pending_patients

end

