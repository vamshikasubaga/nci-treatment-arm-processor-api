class BasicTreatmentArmWorker
  include Shoryuken::Worker

  shoryuken_options queue: ->{"#{ENV['queue_name']}"}, auto_delete: true

  def perform(_sqs_message, patient)
    begin
      treatment_arm_list = TreatmentArm.scan({})
      ta_distinct_list ||= []
      treatment_arm_list.each do | treatment_arm_id |
        ta_distinct_list.push(treatment_arm_id)
      end
      ta_distinct_list.uniq!{ |x| x.name }
      ta_distinct_list.each do | ta |
        update(ta)
      end
    rescue => error
      Shoryuken.logger.error("BasicTreatmentArm failed with error #{error}")
    end
  end

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
      Shoryuken.logger.info("BasicTreatmentArm for #{basic_treatment_arm.treatment_arm_id} has been updated")
    else
      basic_treatment_arm = BasicTreatmentArm.find(:treatment_arm_id => treatment_arm.name)
      basic_treatment_arm.treatment_arm_id = treatment_arm.name
      basic_treatment_arm.description = treatment_arm.description
      basic_treatment_arm.treatment_arm_status = treatment_arm.treatment_arm_status
      basic_treatment_arm.date_created = treatment_arm.date_created
      basic_treatment_arm.former_patients = find_patient_count_for_status(treatment_arm.name, ["FORMERLY_ON_ARM_PROGRESSED"])
      basic_treatment_arm.current_patients = find_patient_count_for_status(treatment_arm.name, ["ON_TREATMENT_ARM"])
      # basic_treatment_arm.not_enrolled_patients = find_patient_count_for_status(treatment_arm.name, ["NOT_ELIGIBLE", "OFF_TRIAL_DECEASED", "OFF_TRIAL_NOT_CONSENTED", "FORMERLY_ON_ARM_PROGRESSED"])
      basic_treatment_arm.pending_patients = find_patient_count_for_status(treatment_arm.name, ["PENDING_APPROVAL"])
      basic_treatment_arm.save
      Shoryuken.logger.info("BasicTreatmentArm for #{basic_treatment_arm.treatment_arm_id} has been updated")
    end
    # sorted_status_log = !treatment_arm[:status_log].blank? ? treatment_arm[:status_log].sort_hash_descending  : {}
    # basic_treatment_arm.date_created = !treatment_arm[:date_created].blank? ? treatment_arm[:date_created].to_time : nil
    # basic_treatment_arm.date_opened = !sorted_status_log.key("OPEN").blank? ? Time.strptime(sorted_status_log.key("OPEN"), '%Q') : nil
    # basic_treatment_arm.date_closed = !sorted_status_log.key("CLOSED").blank? ? Time.strptime(sorted_status_log.key("CLOSED"), '%Q') : nil
    # basic_treatment_arm.date_suspended = !sorted_status_log.key("SUSPENDED").blank? ? Time.strptime(sorted_status_log.key("SUSPENDED"), '%Q') : nil

  end


  def find_patient_count_for_status(treatment_arm_name, status_list=[])
    TreatmentArmPatient.scan(:scan_filter => {"treatment_arm_name_version" => {:comparison_operator => "CONTAINS", :attribute_value_list => [treatment_arm_name]},
                                              "current_patient_status" => {:comparison_operator => "EQ", :attribute_value_list => status_list}},
                             :conditional_operator => "AND").count
  end

end