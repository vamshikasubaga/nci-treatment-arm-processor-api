require 'mongoid'

class BasicPatient
  include Mongoid::Document

  field :patientSequenceNumber
  field :currentStepNumber
  field :currentPatientStatus

  embeds_many :patientAssignments, class_name: "PatientAssignment", inverse_of: :patientassignment
end