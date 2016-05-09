class BasicTreatmentArmWorker
  include Shoryuken::Worker

  shoryuken_options queue: 'treatment_arm_dev', auto_delete: true

  def perform(sqs_message, patient)
    begin
      treatment_arm_list = TreatmentArm.scan({})
      treatment_arm_list.each do | treatment_arm_id |
        update(treatment_arm_id)
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
    # TreatmentArm.find(:name => treatment_arm_id[:name])
  end

  # def basic_insert(treatment_arm_id)
  #   basic_treatment_arm = {:_id => treatment_arm_id}
  #   BasicTreatmentArm.new(basic_treatment_arm).save
  #   p "Saving treatment_arm_id #{treatment_arm_id} as a basic_treatment_arm object"
  # end

  def update(treatment_arm)
    if(BasicTreatmentArm.find(:treatment_arm_id => treatment_arm.name).blank?)
      basic_treatment_arm = BasicTreatmentArm.new
      basic_treatment_arm.treatment_arm_id = treatment_arm.name
      basic_treatment_arm.description = treatment_arm.description
      basic_treatment_arm.treatment_arm_status = treatment_arm.treatment_arm_status
      basic_treatment_arm.date_created = treatment_arm.date_created
      basic_treatment_arm.former_patients = 0
      basic_treatment_arm.current_patients = 0
      basic_treatment_arm.not_enrolled_patients = 0
      basic_treatment_arm.pending_patients = 0
      basic_treatment_arm.save
    else
      basic_treatment_arm = BasicTreatmentArm.find(:treatment_arm_id => treatment_arm.name)
      basic_treatment_arm.treatment_arm_id = treatment_arm.name
      basic_treatment_arm.description = treatment_arm.description
      basic_treatment_arm.treatment_arm_status = treatment_arm.treatment_arm_status
      basic_treatment_arm.date_created = treatment_arm.date_created
      basic_treatment_arm.former_patients = 0
      basic_treatment_arm.current_patients = 0
      basic_treatment_arm.not_enrolled_patients = 0
      basic_treatment_arm.pending_patients = 0
      basic_treatment_arm.save
    end
    # sorted_status_log = !treatment_arm[:status_log].blank? ? treatment_arm[:status_log].sort_hash_descending  : {}
    # basic_treatment_arm.treatment_arm_name = treatment_arm[:name]
    # basic_treatment_arm.current_patients = TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id], 'patient.current_patient_status' => "ON_TREATMENT_ARM").count
    # basic_treatment_arm.former_patients = TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id], 'patient.current_patient_status' => "FORMERLY_ON_ARM_PROGRESSED").count
    # basic_treatment_arm.not_enrolled_patients = TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id]).in('patient.current_patient_status' => ["NOT_ELIGIBLE", "OFF_TRIAL_DECEASED", "OFF_TRIAL_NOT_CONSENTED", "FORMERLY_ON_ARM_PROGRESSED"]).count
    # basic_treatment_arm.pending_patients = TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id], 'patient.current_patient_status' => "PENDING_APPROVAL").count
    # basic_treatment_arm.treatment_arm_status = treatment_arm[:treatment_arm_status]
    # basic_treatment_arm.date_created = !treatment_arm[:date_created].blank? ? treatment_arm[:date_created].to_time : nil
    # basic_treatment_arm.date_opened = !sorted_status_log.key("OPEN").blank? ? Time.strptime(sorted_status_log.key("OPEN"), '%Q') : nil
    # basic_treatment_arm.date_closed = !sorted_status_log.key("CLOSED").blank? ? Time.strptime(sorted_status_log.key("CLOSED"), '%Q') : nil
    # basic_treatment_arm.date_suspended = !sorted_status_log.key("SUSPENDED").blank? ? Time.strptime(sorted_status_log.key("SUSPENDED"), '%Q') : nil

  end

end