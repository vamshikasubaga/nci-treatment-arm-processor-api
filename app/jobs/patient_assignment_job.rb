# PatientAssignment Insert/Update Job
class PatientAssignmentJob
  attr_accessor :patient_assignment_message

  def perform(patient_assignment)
    begin
      Shoryuken.logger.info("#{self.class.name} | ===== Received a Patient Assignment(#{patient_assignment['patient_id']}) at state '#{patient_assignment['patient_status']}' for TreatmentArm('#{patient_assignment['treatment_arm_id']}'/'#{patient_assignment['stratum_id']}'/'#{patient_assignment['version']}') =====")
      patient_assignment.symbolize_keys!
      treatment_arm_id_stratum_id = patient_assignment[:treatment_arm_id] + '_' + patient_assignment[:stratum_id]
      patient_ta = TreatmentArmAssignmentEvent.get_patient_assignments(treatment_arm_id_stratum_id, patient_assignment[:patient_id])
      Shoryuken.logger.info("#{self.class.name} | ===== Processing Patient Assignment(#{patient_assignment[:patient_id]}) for TreatmentArm('#{patient_assignment[:treatment_arm_id]}'/'#{patient_assignment[:stratum_id]}'/'#{patient_assignment[:version]}') =====")
      if patient_ta.blank?
        insert(patient_assignment)
      else
        update(patient_ta, patient_assignment)
      end
    rescue => error
      Shoryuken.logger.error("#{self.class.name} | Failed to process Patient Assignment with error #{error}::#{error.backtrace}")
    end
  end

  def insert(patient_assignment)
    begin
      Shoryuken.logger.info("#{self.class.name} | ===== Inserting Patient Assignment(#{patient_assignment[:patient_id]}) for TreatmentArm('#{patient_assignment[:treatment_arm_id]}'/'#{patient_assignment[:stratum_id]}'/'#{patient_assignment[:version]}') =====")
      patient_model = TreatmentArmAssignmentEvent.new
      json = patient_model.convert_model(patient_assignment).to_json
      patient_model.from_json(json)
      patient_model.save
      Shoryuken.logger.info("#{self.class.name} | ===== Patient '#{patient_model.patient_id}' was successfully saved for Assignment to the TreatmentArm('#{patient_model.treatment_arm_id}'/'#{patient_model.stratum_id}'/'#{patient_model.version}') =====")
    rescue => error
      Shoryuken.logger.error("#{self.class.name} | Failed to insert Patient Assignment('#{patient_assignment[:patient_id]}') for TreatmentArm('#{patient_assignment[:treatment_arm_id]}'/'#{patient_assignment[:stratum_id]}'/'#{patient_assignment[:version]}') with error: #{error}::#{error.backtrace}")
    end
  end

  def update(patient_ta, patient_assignment)
    begin
      Shoryuken.logger.info("#{self.class.name} | ===== Updating Patient Assignment(#{patient_assignment[:patient_id]}) for TreatmentArm('#{patient_assignment[:treatment_arm_id]}'/'#{patient_assignment[:stratum_id]}'/'#{patient_assignment[:version]}') =====")
      next_event = patient_ta.next_event(patient_ta.event, patient_assignment[:patient_status])
      patient_ta.event = next_event
      patient_ta.patient_status = assess_patient_status(next_event, patient_assignment[:patient_status])
      patient_ta.step_number = patient_assignment[:step_number] unless patient_assignment[:step_number].nil?
      patient_ta.date_on_arm = patient_assignment[:date_on_arm] unless patient_assignment[:date_on_arm].nil?
      patient_ta.date_off_arm = patient_assignment[:date_off_arm] unless patient_assignment[:date_off_arm].nil?
      patient_ta.assignment_reason = patient_assignment[:assignment_reason] unless patient_assignment[:assignment_reason].nil?
      patient_ta.patient_status_reason = patient_assignment[:patient_status_reason] unless patient_assignment[:patient_status_reason].nil?
      patient_ta.save
      Shoryuken.logger.info("#{self.class.name} | ===== Patient '#{patient_assignment[:patient_id]}' was updated to '#{patient_assignment[:patient_status]}' for TreatmentArm('#{patient_assignment[:treatment_arm_id]}'/'#{patient_assignment[:stratum_id]}'/'#{patient_assignment[:version]}') =====")
      BasicTreatmentArmJob.new.perform(patient_assignment[:treatment_arm_id], patient_assignment[:stratum_id])
    rescue => error
      Shoryuken.logger.error("#{self.class.name} | Failed to update Patient Assignment('#{patient_assignment[:patient_id]}') for TreatmentArm('#{patient_assignment[:treatment_arm_id]}'/'#{patient_assignment[:stratum_id]}'/'#{patient_assignment[:version]}') with error: #{error}::#{error.backtrace}")
    end
  end

  private

  def assess_patient_status(event, status)
    if event == TreatmentArmAssignmentEvent::FORMER_PATIENT && %w(REQUEST_ASSIGNMENT REQUEST_NO_ASSIGNMENT).include?(status.upcase)
      status = 'PREVIOUSLY_ON_ARM'
    elsif event == TreatmentArmAssignmentEvent::FORMER_PATIENT && %w(OFF_STUDY OFF_STUDY_BIOPSY_EXPIRED).include?(status.upcase)
      status = 'PREVIOUSLY_ON_ARM_OFF_STUDY'
    elsif event == TreatmentArmAssignmentEvent::NOT_ENROLLED && %w(REQUEST_ASSIGNMENT REQUEST_NO_ASSIGNMENT).include?(status.upcase)
      status = 'NOT_ENROLLED_ON_ARM'
    elsif event == TreatmentArmAssignmentEvent::NOT_ENROLLED && %w(OFF_STUDY OFF_STUDY_BIOPSY_EXPIRED).include?(status.upcase)
      status = 'NOT_ENROLLED_ON_ARM_OFF_STUDY'
    end
    status
  end
end
