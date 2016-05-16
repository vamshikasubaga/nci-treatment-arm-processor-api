
class TreatmentArm
  include Aws::Record
  include Aws::Record::Query::QueryClassMethods
  include ActiveModel::Serializers::JSON

  set_table_name "ta_treatment_arms_dev"

  string_attr :name, hash_key: true
  string_attr :version, range_key: true
  string_attr :description
  string_attr :target_id
  string_attr :target_name
  string_attr :gene
  string_attr :treatment_arm_status
  string_attr :date_created

  integer_attr :max_patients_allowed
  integer_attr :num_patients_assigned

  list_attr :treatment_arm_drugs
  list_attr :exclusion_criterias
  list_attr :exclusion_diseases
  list_attr :exclusion_drugs
  list_attr :pten_results
  map_attr :status_log
  map_attr :variant_report


  def attributes=(hash)
    hash.each do |key, value|
    send("#{key}=", value)
    end
  end

  def attributes
    instance_values
  end

end

