require 'mongoid'

class BasicTreatmentArm
  include Mongoid::Document

  store_in collection: "basic_treatment_arm"

  field :_id, type: String, default: -> { _id }
  field :treatmentArmName
  field :currentPatients
  field :formerPatients
  field :notEnrolledPatients
  field :pendingPatients
  field :treatmentArmStatus
  field :dateCreated
  field :dateOpened
  field :dateClosed
  field :dateSuspended

end

