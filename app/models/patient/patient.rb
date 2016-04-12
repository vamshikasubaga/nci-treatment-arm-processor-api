require 'mongoid'

class Patient
  include Mongoid::Document

  field :patient_sequence_number
  field :patient_triggers
  field :current_step_number
  field :current_patient_status
  field :patient_assignments
  field :concordance
  field :registration_date
  field :patient_rejoin_triggers

  embedded_in :treatmentarm, :inverse_of => :patients

end