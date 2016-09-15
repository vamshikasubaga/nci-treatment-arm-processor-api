class TreatmentArmAssignmentEvent
  include Aws::Record
  include Aws::Record::RecordClassMethods
  include Aws::Record::ItemOperations::ItemOperationsClassMethods

  include ActiveModel::Serializers::JSON
  include ModelSerializer

  set_table_name "#{self.name.underscore}"

  string_attr :patient_id, hash_key: true
  date_attr :date_generated, range_key: true
  date_attr :date_on_arm
  date_attr :date_off_arm
  string_attr :treatment_arm_id
  string_attr :stratum_id
  string_attr :version
  string_attr :patient_status
  string_attr :assignment_reason
  list_attr :diseases
  string_attr :step_number
  string_attr :surgical_event_id
  string_attr :molecular_id
  string_attr :analysis_id

  def self.find_by(opts = {})
    query = {}
    query.merge!(build_scan_filter(opts))
    query.merge!(conditional_operator: 'AND') if query[:scan_filter].length >= 2
    self.scan(query).collect { |data| data }
  end

  def self.build_scan_filter(opts = {})
    query = { scan_filter: {} }
    opts.each do |key, value|
      unless value.nil?
        query[:scan_filter].merge!(key.to_s => { comparison_operator: 'EQ', attribute_value_list: [value] })
      end
    end
    query
  end

  def convert_model(patient_assignment)
    return {
        patient_id: patient_assignment[:patient_id],
        date_generated: patient_assignment[:date_generated],
        treatment_arm_id: patient_assignment[:treatment_arm_id],
        stratum_id: patient_assignment[:stratum_id],
        version: patient_assignment[:version],
        step_number: patient_assignment[:step_number],
        patient_status: patient_assignment[:patient_current_status]
    }
  end
end
