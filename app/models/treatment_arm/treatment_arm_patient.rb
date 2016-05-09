class TreatmentArmPatient
  include Dynamoid::Document

  table :name => :treatment_arm_patient, :key => :name, :read_capacity => 5, :write_capacity => 5

  field :patient_sequence_number
  field :version
  field :description
  field :target_id
  field :target_name
  field :gene
  field :treatment_arm_status

end