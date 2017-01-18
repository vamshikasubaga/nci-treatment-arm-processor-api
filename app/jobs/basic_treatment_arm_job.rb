class BasicTreatmentArmJob
  def perform(treatment_arm_id, stratum_id)
    begin
      treatment_arms = TreatmentArm.find_by(treatment_arm_id, stratum_id, nil, false)
      treatment_arms.each do | treatment_arm |
        update(treatment_arm)
      end
    rescue => error
      Shoryuken.logger.error("#{self.class.name} | BasicTreatmentArmJob failed with error #{error}::#{error.backtrace}")
    end
  end

  def update(treatment_arm)
    treatment_arm.version_former_patients = find_patient_count_by_event(treatment_arm, 'FORMER_PATIENT')
    treatment_arm.version_current_patients = find_patient_count_for_status(treatment_arm, ['ON_TREATMENT_ARM'])
    treatment_arm.version_not_enrolled_patients = find_patient_count_by_event(treatment_arm, 'NOT_ENROLLED')
    treatment_arm.version_pending_patients = find_patient_count_for_status(treatment_arm, ['PENDING_APPROVAL'])
    treatment_arm.former_patients = find_patient_count_by_event(treatment_arm, 'FORMER_PATIENT', true)
    treatment_arm.current_patients = find_patient_count_for_status(treatment_arm, ['ON_TREATMENT_ARM'], true)
    treatment_arm.not_enrolled_patients = find_patient_count_by_event(treatment_arm, 'NOT_ENROLLED', true)
    treatment_arm.pending_patients = find_patient_count_for_status(treatment_arm, ['PENDING_APPROVAL'], true)
    treatment_arm.save
    Shoryuken.logger.info("#{self.class.name} | BasicTreatmentArm info for TreatmentArm with treatment_arm_id '#{treatment_arm.treatment_arm_id}' & stratum_id '#{treatment_arm.stratum_id}' has been successfully updated")
  end

  def find_patient_count_for_status(treatment_arm=nil, status_list=[], ignore_version=false)
    query = {}
    query.merge!('treatment_arm_id' => { comparison_operator: 'CONTAINS', attribute_value_list: [treatment_arm.treatment_arm_id] })
    query.merge!('stratum_id' => { comparison_operator: 'EQ', attribute_value_list: [treatment_arm.stratum_id] })
    query.merge!('version' => { comparison_operator: 'EQ', attribute_value_list: [treatment_arm.version] }) unless ignore_version
    query.merge!('patient_status' => { comparison_operator: 'IN', attribute_value_list: status_list })
    TreatmentArmAssignmentEvent.scan(scan_filter: query, conditional_operator: 'AND').count
  end

  def find_patient_count_by_event(treatment_arm=nil, event=nil, ignore_version=false)
    query = {}
    query.merge!('treatment_arm_id' => { comparison_operator: 'CONTAINS', attribute_value_list: [treatment_arm.treatment_arm_id] })
    query.merge!('stratum_id' => { comparison_operator: 'EQ', attribute_value_list: [treatment_arm.stratum_id] })
    query.merge!('version' => { comparison_operator: 'EQ', attribute_value_list: [treatment_arm.version] }) unless ignore_version
    query.merge!('event' => { comparison_operator: 'EQ', attribute_value_list: [event] })
    TreatmentArmAssignmentEvent.scan(scan_filter: query, conditional_operator: 'AND').count
  end
end
