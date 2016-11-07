class BasicTreatmentArmJob
  def perform
    begin
      treatment_arm_list = TreatmentArm.scan({})
      treatment_arm_list.each do |ta|
        update(ta)
      end
    rescue => error
      Shoryuken.logger.error("BasicTreatmentArmJob failed with error #{error}::#{error.backtrace}")
    end
  end

  # sorted_status_log = !treatment_arm[:status_log].blank? ? treatment_arm[:status_log].sort_hash_descending  : {}
  # basic_treatment_arm.date_created = !treatment_arm[:date_created].blank? ? treatment_arm[:date_created].to_time : nil
  # basic_treatment_arm.date_opened = !sorted_status_log.key('OPEN').blank? ? Time.strptime(sorted_status_log.key('OPEN'), '%Q') : nil
  # basic_treatment_arm.date_closed = !sorted_status_log.key('CLOSED').blank? ? Time.strptime(sorted_status_log.key('CLOSED'), '%Q') : nil
  # basic_treatment_arm.date_suspended = !sorted_status_log.key('SUSPENDED').blank? ? Time.strptime(sorted_status_log.key('SUSPENDED'), '%Q') : nil

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
    Shoryuken.logger.info("BasicTreatmentArm info for TreatmentArm with treatment_arm_id '#{treatment_arm.treatment_arm_id}' & stratum_id '#{treatment_arm.stratum_id}' has been successfully updated")
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
