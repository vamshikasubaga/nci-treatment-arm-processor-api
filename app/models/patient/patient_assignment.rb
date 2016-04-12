class PatientAssignment
  include Mongoid::Document

  embedded_in :patient, :inverse_of => :patient_assignments

  field :date_assigned
  field :biopsy_sequence_number
  field :patient_assignment_status
  field :patient_assignment_logic
  field :patient_assignment_status_message
  field :step_number
  field :patient_assignment_messages
  field :date_confirmed

end