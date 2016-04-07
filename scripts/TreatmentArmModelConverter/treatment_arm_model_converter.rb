
require 'mongo'
require 'resque'
require 'rails'
require "#{File.dirname(__FILE__)}/lib/basic_treatment_arm_job"
require "#{File.dirname(__FILE__)}/lib/basic_treatment_arm_patient_job"
require "#{File.dirname(__FILE__)}/lib/treatment_job"

class TreatmentArmModelConverter

  def initialize
    @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'match')
  end


  def runner
    treatment_arms = @client[:treatmentArm].find
    patients = @client[:patient].find
    treatment_arms.each do | treatment_arm |
      treatment_arm.deep_transform_keys!(&:underscore)
      treatment_arm.delete("_class")
      Resque.enqueue(TreatmentJob, treatment_arm)
      # Resque.enqueue(BasicTreatmentArmJob, treatment_arm)
    end
    # patients.each do | patient |
      # Resque.enqueue(BasicTreatmentArmPatientJob, patient)
    # end
  end


  def convert_hash_keys(treatment_arm)
    data = ActiveSupport::JSON.decode(treatment_arm)
    data = {:_json => data} unless data.is_a?(Hash)

    # Transform camelCase param keys to snake_case:
    data.deep_transform_keys!(&:underscore)
  end

  self.new.runner


end