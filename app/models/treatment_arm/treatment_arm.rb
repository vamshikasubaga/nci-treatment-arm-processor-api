
class TreatmentArm
  include Aws::Record
  include Aws::Record::Query::QueryClassMethods
  include ActiveModel::Serializers::JSON

  set_table_name "ta_#{self.name.underscore}_#{Rails.env}"

  boolean_attr :active, database_attribute_name: "is_active_flag"
  string_attr :name, hash_key: true
  string_attr :version, range_key: true
  string_attr :description
  string_attr :target_id
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


  def attributes=(hash)
    hash.each do |key, value|
    send("#{key}=", value)
    end
  end

  def attributes
    instance_values
  end

end

