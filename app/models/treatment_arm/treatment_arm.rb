require 'mongoid'

  class TreatmentArm
    include Mongoid::Document

    store_in collection: "treatmentArm"

    field :_id, type: String
    field :name
    field :version
    field :description
    field :targetId
    field :targetName
    field :gene
    field :treatmentArmStatus

    embeds_many :treatmentArmDrugs, class_name: "Drug", inverse_of: :treatmentarm
    embeds_many :exclusionDiseases, class_name: "Disease", inverse_of: :treatmentarm
    embeds_many :exclusionDrugs, class_name: "Drug", inverse_of: :treatmentarm
    embeds_many :exclusionCriterias, class_name: "ExclusionCriteria", inverse_of: :treatmentarm
    embeds_many :ptenResults, class_name: "PtenResult", inverse_of: :treatmentarm

    field :numPatientsAssigned, type: Integer, default: 0
    field :maxPatientsAllowed, type: Integer


    embeds_one :variantReport, class_name: "VariantReport", inverse_of: :treatmentarm

    field :statusLog, type: Hash

    field :dateCreated, type: DateTime, default: Time.now

    def validate_eligible_for_approval(id)
      treatment_arm = TreatmentArm.where(:_id => id, :treatmentArmStatus.ne => "PENDING").first
      is_valid = treatment_arm.variantReport.has_a_inclusion
      if treatment_arm.ptenResults.empty? && is_valid
        return true
      end
      if treatment_arm.ptenResults.collect { | pten | pten.get_pten_variant_status}.include? PtenResult.empty?
        return true
      end
      return is_valid
    end

    def get_number_screened_patients_with_amoi(patientData)
      TreatmentArm.where(:variantReport.ne => "", :variantReport.exists => true).each do | treatmentArm |

      end

    end

  end

