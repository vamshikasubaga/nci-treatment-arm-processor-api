require 'mongoid'

class BasicTreatmentArm
  include Mongoid::Document

  store_in collection: "basic_treatment_arm"

  field :_id, type: String, default: -> { treatment_arm_id }
  field :treatment_arm_name
  field :current_patients
  field :former_patients
  field :not_enrolled_patients
  field :pending_patients
  field :treatment_arm_status
  field :date_created
  field :date_opened
  field :date_closed
  field :date_suspended

end

