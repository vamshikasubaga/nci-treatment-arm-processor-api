# TreatmentArm Data Model
class TreatmentArm
  include Aws::Record
  include Aws::Record::RecordClassMethods
  include Aws::Record::Query::QueryClassMethods

  include ActiveModel::Serializers::JSON
  include ModelSerializer

  set_table_name "#{self.name.underscore}"

  boolean_attr :active, database_attribute_name: 'is_active_flag'
  string_attr :treatment_arm_id, hash_key: true
  string_attr :name
  string_attr :version
  string_attr :date_created, range_key: true
  string_attr :stratum_id
  string_attr :description
  string_attr :target_id
  string_attr :target_name
  string_attr :gene
  string_attr :treatment_arm_status
  string_attr :study_id
  list_attr :assay_rules
  integer_attr :num_patients_assigned
  string_attr :date_opened
  list_attr :treatment_arm_drugs
  list_attr :diseases
  list_attr :exclusion_drugs
  list_attr :snv_indels
  list_attr :non_hotspot_rules
  list_attr :copy_number_variants
  list_attr :gene_fusions
  map_attr :status_log
  integer_attr :current_patients
  integer_attr :former_patients
  integer_attr :not_enrolled_patients
  integer_attr :pending_patients
  integer_attr :version_current_patients
  integer_attr :version_former_patients
  integer_attr :version_not_enrolled_patients
  integer_attr :version_pending_patients

  def self.find_by(id = nil, stratum_id = nil, version = nil, to_hash = true)
    query = {}
    query.merge!(build_scan_filter(id, stratum_id, version))
    query[:conditional_operator] = 'AND'
    if to_hash
      scan(query).collect(&:to_h)
    else
      scan(query).entries
    end
  end

  def self.build_scan_filter(id = nil, stratum_id = nil, version = nil)
    query = { scan_filter: {} }
    unless id.nil?
      query[:scan_filter]['treatment_arm_id'] = { comparison_operator: 'EQ', attribute_value_list: [id] }
    end
    unless stratum_id.nil?
      query[:scan_filter]['stratum_id'] = { comparison_operator: 'EQ', attribute_value_list: [stratum_id] }
    end
    unless version.nil?
      query[:scan_filter]['version'] = { comparison_operator: 'EQ', attribute_value_list: [version] }
    end
    query
  end

  def self.build_cloned(treatment_arm)
    {
      active: true,
      treatment_arm_id: treatment_arm[:treatment_arm_id],
      name: treatment_arm[:name],
      version: treatment_arm[:version],
      study_id: treatment_arm[:study_id],
      stratum_id: treatment_arm[:stratum_id],
      description: treatment_arm[:description],
      target_id: treatment_arm[:target_id],
      target_name: treatment_arm[:target_name],
      gene: treatment_arm[:gene],
      assay_rules: treatment_arm[:assay_rules],
      treatment_arm_status: treatment_arm[:treatment_arm_status],
      date_created: treatment_arm[:date_created],
      date_opened: DateTime.current.to_formatted_s(:iso8601),
      num_patients_assigned: treatment_arm[:num_patients_assigned],
      treatment_arm_drugs: treatment_arm[:treatment_arm_drugs],
      diseases: treatment_arm[:diseases],
      exclusion_drugs: treatment_arm[:exclusion_drugs],
      snv_indels: treatment_arm[:snv_indels],
      non_hotspot_rules: treatment_arm[:non_hotspot_rules],
      copy_number_variants: treatment_arm[:copy_number_variants],
      gene_fusions: treatment_arm[:gene_fusions],
      status_log: treatment_arm[:status_log].blank? ? { Time.now.to_i.to_s => 'OPEN' } : treatment_arm[:status_log]
    }
  end

  def convert_models(treatment_arm)
    {
      active: true,
      treatment_arm_id: treatment_arm[:treatment_arm_id],
      name: treatment_arm[:name],
      version: treatment_arm[:version],
      study_id: treatment_arm[:study_id],
      stratum_id: treatment_arm[:stratum_id],
      description: treatment_arm[:description],
      target_id: treatment_arm[:target_id],
      target_name: treatment_arm[:target_name],
      gene: treatment_arm[:gene],
      assay_rules: treatment_arm[:assay_rules],
      treatment_arm_status: attributes_present(treatment_arm),
      date_created: treatment_arm[:date_created],
      date_opened: DateTime.current.to_formatted_s(:iso8601),
      num_patients_assigned: treatment_arm[:num_patients_assigned],
      treatment_arm_drugs: treatment_arm[:treatment_arm_drugs],
      diseases: treatment_arm[:diseases],
      exclusion_drugs: treatment_arm[:exclusion_drugs],
      snv_indels: treatment_arm[:snv_indels],
      non_hotspot_rules: treatment_arm[:non_hotspot_rules],
      copy_number_variants: treatment_arm[:copy_number_variants],
      gene_fusions: treatment_arm[:gene_fusions],
      status_log: treatment_arm[:status_log].blank? ? { Time.now.to_i.to_s => 'OPEN' } : treatment_arm[:status_log]
    }
  end

  def self.find_treatment_arms(treatment_arm_id, stratum_id)
    treatment_arms = self.query(
      key_condition_expression: "#T = :t",
      filter_expression: "contains(#S, :s)",
      expression_attribute_names: {
        "#T" => "treatment_arm_id",
        "#S" => "stratum_id"
      },
      expression_attribute_values: {
        ":t" => treatment_arm_id,
        ":s" => stratum_id
      }
    )
    treatment_arms
  end

  private

  def attributes_present(hash)
    'OPEN' if hash[:treatment_arm_id].present? && hash[:stratum_id].present? && hash[:version].present?
  end
end
