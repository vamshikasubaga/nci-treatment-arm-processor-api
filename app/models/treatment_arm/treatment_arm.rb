require 'mongoid'

  class TreatmentArm
    include Mongoid::Document

    field :treatment_arm_id, type: String
    field :name
    field :version
    field :description
    field :target_id
    field :target_name
    field :gene
    field :treatment_arm_status

    embeds_many :treatment_arm_drugs, class_name: "Drug", inverse_of: :treatmentarm
    embeds_many :exclusion_diseases, class_name: "Disease", inverse_of: :treatmentarm
    embeds_many :exclusion_drugs, class_name: "Drug", inverse_of: :treatmentarm
    embeds_many :exclusion_criterias, class_name: "ExclusionCriteria", inverse_of: :treatmentarm
    embeds_many :pten_results, class_name: "PtenResult", inverse_of: :treatmentarm

    embeds_one :patient, class_name: "Patient"

    field :num_patients_assigned, type: Integer, default: 0
    field :max_patients_allowed, type: Integer


    embeds_one :variant_report, class_name: "VariantReport", inverse_of: :treatmentarm

    field :status_log, type: Hash

    field :date_created, type: DateTime, default: Time.now


  end

