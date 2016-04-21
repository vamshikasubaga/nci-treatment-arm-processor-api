
require 'mongo'
require 'bunny'
require 'rails'

class TreatmentArmModelConverter

  def initialize
    @client = Mongo::Client.new([ 'localhost:27017' ], :database => 'match')
    # @conn = Bunny.new
    @conn = Bunny.new(:host => "localhost", :vhost => "/", :user => "guest", :password => "guest")
    @conn.start
  end


  def runner
    @ch = @conn.create_channel
    @treatment_arm_queue = @ch.queue("treatment_arm", :durable => true)
    @patient_queue = @ch.queue("patient", :durable => true)
    patients = @client[:patient].find(:currentPatientStatus => {"$nin" => ['REGISTRATION']})
    treatment_arm_history_load()
    treatment_arm_load()
    count = 1
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
          @patient_queue.publish(patient_data.to_json, :routing_key => @patient_queue.name, :persistent => true)
          count += 1
        end
      end
    end
    p count
    @conn.close
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
      @treatment_arm_queue.publish(treatment_arm.to_json, :routing_key => @treatment_arm_queue.name, :persistent => true)
    end
  end

  def treatment_arm_load
    treatment_arms = @client[:treatmentArm].find
    treatment_arms.each do | treatment_arm |
      treatment_arm.deep_transform_keys!(&:underscore)
      treatment_arm.delete("_class")
      treatment_arm.store("treatment_arm_id", treatment_arm["_id"])
      treatment_arm.delete("_id")
      @treatment_arm_queue.publish(treatment_arm.to_json, :routing_key => @treatment_arm_queue.name, :persistent => true)
    end
  end

  self.new.runner


end