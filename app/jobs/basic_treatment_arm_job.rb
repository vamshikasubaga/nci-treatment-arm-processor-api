class BasicTreatmentArmJob

  def perform
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
    treatment_arm.former_patients = find_patient_count_by_event(treatment_arm, "FORMER_PATIENT")
    treatment_arm.current_patients = find_patient_count_for_status(treatment_arm, ["ON_TREATMENT_ARM"])
    treatment_arm.not_enrolled_patients = find_patient_count_by_event(treatment_arm, "NOT_ENROLLED")
    treatment_arm.pending_patients = find_patient_count_for_status(treatment_arm, ["PENDING_APPROVAL", "PENDING_CONFIRMATION"])
    treatment_arm.save
    Shoryuken.logger.info("BasicTreatmentArm info for #{treatment_arm.id} has been updated")
  end

  def find_patient_count_for_status(treatment_arm=nil, status_list=[])
    TreatmentArmAssignmentEvent.scan(:scan_filter => {
                            "treatment_arm_id" => {
                                                    comparison_operator: "CONTAINS",
                                                    attribute_value_list: [treatment_arm.id]
                                                  },
                            "stratum_id" => {
                                              comparison_operator: "EQ",
                                              attribute_value_list: [treatment_arm.stratum_id]
                                            },
                            "version" => {
                                           comparison_operator: "EQ",
                                           attribute_value_list: [treatment_arm.version]
                                         },
                            "patient_status" => {
                                                  comparison_operator: "IN",
                                                  attribute_value_list: status_list}},
                            conditional_operator: "AND").count
  end

  def find_patient_count_by_event(treatment_arm=nil, event=nil)
    TreatmentArmAssignmentEvent.scan(:scan_filter => {
                            "treatment_arm_id" => {
                                                    comparison_operator: "CONTAINS",
                                                    attribute_value_list: [treatment_arm.id]
                                                  },
                            "stratum_id" => {
                                              comparison_operator: "EQ",
                                              attribute_value_list: [treatment_arm.stratum_id]
                                            },
                            "version" => {
                                           comparison_operator: "EQ",
                                           attribute_value_list: [treatment_arm.version]
                                         },
                            "event" => {
                                         comparison_operator: "EQ",
                                         attribute_value_list: [event]}
                                       },
                            conditional_operator: "AND").count
  end
end
