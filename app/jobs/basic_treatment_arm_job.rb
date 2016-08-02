class BasicTreatmentArmJob

  def perform(patient)
    begin
      treatment_arm_list = TreatmentArm.scan({})
      treatment_arm_list.each do | ta |
        update(ta)
      end
    rescue => error
      Shoryuken.logger.error("BasicTreatmentArm failed with error #{error}")
    end
  end

  # sorted_status_log = !treatment_arm[:status_log].blank? ? treatment_arm[:status_log].sort_hash_descending  : {}
  # basic_treatment_arm.date_created = !treatment_arm[:date_created].blank? ? treatment_arm[:date_created].to_time : nil
  # basic_treatment_arm.date_opened = !sorted_status_log.key("OPEN").blank? ? Time.strptime(sorted_status_log.key("OPEN"), '%Q') : nil
  # basic_treatment_arm.date_closed = !sorted_status_log.key("CLOSED").blank? ? Time.strptime(sorted_status_log.key("CLOSED"), '%Q') : nil
  # basic_treatment_arm.date_suspended = !sorted_status_log.key("SUSPENDED").blank? ? Time.strptime(sorted_status_log.key("SUSPENDED"), '%Q') : nil

  def update(treatment_arm)
    treatment_arm.former_patients = find_patient_count_for_status(treatment_arm.name, ["FORMERLY_ON_ARM_PROGRESSED"])
    treatment_arm.current_patients = find_patient_count_for_status(treatment_arm.name, ["ON_TREATMENT_ARM"])
    treatment_arm.not_enrolled_patients = find_patient_count_for_status(treatment_arm.name, ["NOT_ELIGIBLE", "OFF_TRIAL_DECEASED", "OFF_TRIAL_NOT_CONSENTED", "FORMERLY_ON_ARM_PROGRESSED"])
    treatment_arm.pending_patients = find_patient_count_for_status(treatment_arm.name, ["PENDING_APPROVAL"])
    treatment_arm.save
    Shoryuken.logger.info("BasicTreatmentArm info for #{treatment_arm.name} has been updated")
    treatment_arm
  end


  def find_patient_count_for_status(treatment_arm_name, status_list=[])
    TreatmentArmPatient.scan(:scan_filter => {"treatment_arm_name_version" => {:comparison_operator => "CONTAINS", :attribute_value_list => [treatment_arm_name]},
                                              "current_patient_status" => {:comparison_operator => "IN", :attribute_value_list => status_list}},
                             :conditional_operator => "AND").count
  end

end