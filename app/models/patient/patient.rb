require 'mongoid'

class Patient
  include Mongoid::Document

  field :patient_sequence_number
  field :variant_report
  field :diseases
  field :current_step_number
  field :current_patient_status
  embeds_many :patient_assignments, class_name: "PatientAssignment", inverse_of: :patient
  field :concordance
  field :registration_date

  embedded_in :treatmentarm, :inverse_of => :patient

end