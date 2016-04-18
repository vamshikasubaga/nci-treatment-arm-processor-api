
require 'mongo'
require 'resque'
require 'rails'
require "#{File.dirname(__FILE__)}/lib/basic_treatment_arm_job"
require "#{File.dirname(__FILE__)}/lib/basic_treatment_arm_patient_job"
require "#{File.dirname(__FILE__)}/lib/patient_job"
require "#{File.dirname(__FILE__)}/lib/treatment_job"

class TreatmentArmModelConverter

  def initialize
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'match')
  end


  def runner
    patients = @client[:patient].find(:currentPatientStatus => {"$nin" => ['REGISTRATION']})
    # patients = @client[:patient].find(:patientSequenceNumber => '10065') #.each do | patient |
    #   patient.deep_transform_keys!(&:underscore)
    #   patient["patient_triggers"].each do | trigger |
    #     modified_patient = patient
    #     modified_patient[:current_patient_status] = trigger["patient_status"]
    #     Resque.enqueue(PatientTriggerJob, modified_patient)
    #   end
    # end
    treatment_arm_history_load()
    treatment_arm_load()
    patients.each do | patient |
      patient.deep_transform_keys!(&:underscore).symbolize_keys
      patient[:patient_assignments].each do | patient_assignment |
        patient_data = {
            :treatment_arm_id => "",
            :treatment_arm_version => "",
            :patient_sequence_number => "",
            :variant_report => [],
            :diseases => [],
            :current_step_number => "",
            :current_patient_status => "",
            :patient_assignments => [],
            :concordance => ""
        }
        if !patient_assignment[:treatment_arm].blank?
          if !patient_assignment[:patient_assignment_messages].blank?
            patient_assignment_message = patient_assignment[:patient_assignment_messages].first
            patient_data[:patient_sequence_number] = patient_assignment_message[:patient_sequence_number]
            patient_data[:treatment_arm_id] = patient_assignment_message[:treatment_arm_id]
            patient_data[:treatment_arm_version] = patient_assignment[:treatment_arm][:version]
            patient_data[:current_patient_status] = patient_assignment_message[:status]
            patient_data[:current_step_number] = patient_assignment_message[:step_number]
            patient_data[:concordance] = patient[:concordance]
            patient_data[:diseases] = patient[:diseases]
          else
            patient_assignment_message = patient_assignment[:patient_assignment_messages].first
            patient_data[:patient_sequence_number] = patient[:patient_sequence_number]
            patient_data[:treatment_arm_id] = patient_assignment[:treatment_arm][:_id]
            patient_data[:treatment_arm_version] = patient_assignment[:treatment_arm][:version]
            patient_data[:current_patient_status] = patient[:current_patient_status]
            patient_data[:current_step_number] = patient_assignment[:step_number]
            patient_data[:concordance] = patient[:concordance]
            patient_data[:diseases] = patient[:diseases]
          end
          Resque.enqueue(PatientJob, patient_data)
        end
      end
    end
  end

  def transform_patient_data(patient)
    patient_date = {
        :treatment_arm_id => "",
        :patient_sequence_number => "",
        :variant_report => [],
        :diseases => [],
        :current_step_number => "",
        :current_patient_status => "",
        :patient_assignments => [],
        :concordance => "",
        :registration_date => ""
    }
  end

  def treatment_arm_history_load
    treatment_arms_archived = @client[:treatmentArmHistory].find
    treatment_arms_archived.each do |treatment_arm_old |
      treatment_arm_old.deep_transform_keys!(&:underscore)
      treatment_arm = treatment_arm_old["treatment_arm"]
      treatment_arm.store("treatment_arm_id", treatment_arm["_id"])
      treatment_arm.delete("_id")
      Resque.enqueue(TreatmentJob, treatment_arm)
    end
  end

  def treatment_arm_load
    treatment_arms = @client[:treatmentArm].find
    treatment_arms.each do | treatment_arm |
      treatment_arm.deep_transform_keys!(&:underscore)
      treatment_arm.delete("_class")
      treatment_arm.store("treatment_arm_id", treatment_arm["_id"])
      treatment_arm.delete("_id")
      Resque.enqueue(TreatmentJob, treatment_arm)
      Resque.enqueue(BasicTreatmentArmJob, treatment_arm)
    end
  end

  self.new.runner


end