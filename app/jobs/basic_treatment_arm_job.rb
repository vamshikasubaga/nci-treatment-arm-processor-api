require 'bundler/setup'
require 'active_job'
require 'sneakers'

Sneakers.configure(:heartbeat => 20,
                   :amqp => 'amqp://guest:guest@192.168.99.100:5672',
                   :vhost => '/')
ActiveJob::Base.queue_adapter = :sneakers

class BasicTreatmentArmJob < ActiveJob::Base
  queue_as :default

  def perform
    begin
      p TreatmentArm.where(:patient.nin => ["", nil]).count
      treatment_arm_list = TreatmentArm.distinct(:treatment_arm_id)
      all_treatment_arms_accounted(treatment_arm_list)
      treatment_arm_list.each do | treatment_arm_id |
        update(get_latest_treatment_arm(treatment_arm_id))
      end
    rescue => error
      p error
    end
  end

  def all_treatment_arms_accounted(treatment_arm_list)
    treatment_arm_list.each do | treatment_arm_id |
      if !BasicTreatmentArm.where(:_id => treatment_arm_id).exists?
        basic_insert(treatment_arm_id)
      end
    end
  end

  def get_latest_treatment_arm(treatment_arm_id)
    TreatmentArm.where(:treatment_arm_id => treatment_arm_id).sort({version:-1}).first
  end

  def basic_insert(treatment_arm_id)
    basic_treatment_arm = {:_id => treatment_arm_id}
    BasicTreatmentArm.new(basic_treatment_arm).save
    p "Saving treatment_arm_id #{treatment_arm_id} as a basic_treatment_arm object"
  end

  def update(treatment_arm)
    basic_treatment_arm = BasicTreatmentArm.where(:_id => treatment_arm[:treatment_arm_id]).first
    sorted_status_log = !treatment_arm[:status_log].blank? ? treatment_arm[:status_log].sort_hash_descending  : {}
    basic_treatment_arm.treatment_arm_name = treatment_arm[:name]
    basic_treatment_arm.current_patients = TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id], 'patient.current_patient_status' => "ON_TREATMENT_ARM").count
    basic_treatment_arm.former_patients = TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id], 'patient.current_patient_status' => "FORMERLY_ON_ARM_PROGRESSED").count
    basic_treatment_arm.not_enrolled_patients = TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id]).in('patient.current_patient_status' => ["NOT_ELIGIBLE", "OFF_TRIAL_DECEASED", "OFF_TRIAL_NOT_CONSENTED", "FORMERLY_ON_ARM_PROGRESSED"]).count
    basic_treatment_arm.pending_patients = TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id], 'patient.current_patient_status' => "PENDING_APPROVAL").count
    basic_treatment_arm.treatment_arm_status = treatment_arm[:treatment_arm_status]
    basic_treatment_arm.date_created = !treatment_arm[:date_created].blank? ? (treatment_arm[:date_created]).to_time.to_i : nil
    basic_treatment_arm.date_opened = sorted_status_log.key("OPEN")
    basic_treatment_arm.date_closed = sorted_status_log.key("CLOSED")
    basic_treatment_arm.date_suspended = sorted_status_log.key("SUSPENDED")
    basic_treatment_arm.save
    p "Updating basic_treatment_arm #{basic_treatment_arm._id}"
  end

end

BasicTreatmentArmJob.perform_later()