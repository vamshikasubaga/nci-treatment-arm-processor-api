# TreatmentArmAssignmentEvent Data Model
class TreatmentArmAssignmentEvent
  include Aws::Record
  include Aws::Record::RecordClassMethods
  include Aws::Record::ItemOperations::ItemOperationsClassMethods

  include ActiveModel::Serializers::JSON
  include ModelSerializer

  set_table_name "#{self.name.underscore}"

  string_attr :patient_id, hash_key: true
  date_attr :assignment_date, range_key: true
  date_attr :date_on_arm
  date_attr :date_off_arm
  string_attr :treatment_arm_id
  string_attr :stratum_id
  string_attr :version
  string_attr :patient_status
  string_attr :event
  string_attr :assignment_reason
  list_attr :diseases
  string_attr :step_number
  string_attr :surgical_event_id
  string_attr :molecular_id
  string_attr :analysis_id
  map_attr :variant_report
  map_attr :assignment_report

  EVENT_INIT = 'EVENT_INIT'
  PENDING_PATIENT = 'PENDING_PATIENT'
  CURRENT_PATIENT = 'CURRENT_PATIENT'
  NOT_ENROLLED = 'NOT_ENROLLED'
  FORMER_PATIENT = 'FORMER_PATIENT'

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
        assignment_date: patient_assignment[:assignment_date],
        treatment_arm_id: patient_assignment[:treatment_arm_id],
        version: patient_assignment[:version],
        stratum_id: patient_assignment[:stratum_id],
        patient_id: patient_assignment[:patient_id],
        date_on_arm: patient_assignment[:date_on_arm],
        date_off_arm: patient_assignment[:date_off_arm],
        patient_status: patient_assignment[:patient_status],
        assignment_reason: patient_assignment[:assignment_reason],
        diseases: patient_assignment[:diseases],
        step_number: patient_assignment[:step_number],
        surgical_event_id: patient_assignment[:surgical_event_id],
        molecular_id: patient_assignment[:molecular_id],
        analysis_id: patient_assignment[:analysis_id],
        variant_report: patient_assignment[:variant_report],
        assignment_report: patient_assignment[:assignment_report],
        event: EVENT_INIT
    }
  end

  # Captures the order of Patient Statuses and changes the Version & Stratum Statictics accordingly
  def next_event(event, next_state)
    if event == EVENT_INIT && next_state == 'PENDING_APPROVAL'
      event = PENDING_PATIENT
    elsif event == PENDING_PATIENT && next_state == 'OFF_STUDY'
      event = NOT_ENROLLED
    elsif event == PENDING_PATIENT && next_state == 'ON_TREATMENT_ARM'
      event = CURRENT_PATIENT
    elsif event == CURRENT_PATIENT && ['REQUEST_ASSIGNMENT', 'REQUEST_NO_ASSIGNMENT', 'OFF_STUDY', 'OFF_STUDY_BIOPSY_EXPIRED'].include?(next_state)
      event = FORMER_PATIENT
    elsif event == PENDING_PATIENT && ['REQUEST_ASSIGNMENT', 'REQUEST_NO_ASSIGNMENT', 'OFF_STUDY', 'OFF_STUDY_BIOPSY_EXPIRED'].include?(next_state)
      event = NOT_ENROLLED
    end
  event
  end
end
