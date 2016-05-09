class BasicTreatmentArmWorker
  include Shoryuken::Worker

  shoryuken_options queue: 'treatment_arm_dev', auto_delete: true

  def perform(message)
    begin
      treatment_arm_list = TreatmentArm.distinct(:treatment_arm_id)
      all_treatment_arms_accounted(treatment_arm_list)
      treatment_arm_list.each do | treatment_arm_id |
        update(get_latest_treatment_arm(treatment_arm_id))
      end
      p "BasicTreatmentArmJob has updated basic_treatment_arm model"
      ack!
    rescue => error
      p error
      reject!
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
    basic_treatment_arm.date_created = !treatment_arm[:date_created].blank? ? treatment_arm[:date_created].to_time : nil
    basic_treatment_arm.date_opened = !sorted_status_log.key("OPEN").blank? ? Time.strptime(sorted_status_log.key("OPEN"), '%Q') : nil
    basic_treatment_arm.date_closed = !sorted_status_log.key("CLOSED").blank? ? Time.strptime(sorted_status_log.key("CLOSED"), '%Q') : nil
    basic_treatment_arm.date_suspended = !sorted_status_log.key("SUSPENDED").blank? ? Time.strptime(sorted_status_log.key("SUSPENDED"), '%Q') : nil
    basic_treatment_arm.save
  end

end