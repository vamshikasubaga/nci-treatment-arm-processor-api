# PatientAssignment Insert/Update Job
class PatientJob
  attr_accessor :patient_assignment_message

  def perform(patient_assignment)
    begin
      patient_assignment.symbolize_keys!
      # fail_safe(patient_assignment)
      case patient_assignment[:patient_status]
      when 'PENDING_CONFIRMATION'
        Shoryuken.logger.info("Recieved patient with patient_id '#{patient_assignment[:patient_id]}' at state PENDING_CONFIRMATION")
        store_patient(patient_assignment)
      when 'PENDING_APPROVAL'
        Shoryuken.logger.info("Recieved patient with patient_id '#{patient_assignment[:patient_id]}' at state PENDING_APPROVAL")
        store_patient(patient_assignment)
      when 'ON_TREATMENT_ARM'
        Shoryuken.logger.info("Recieved patient with patient_id '#{patient_assignment[:patient_id]}' at state ON_TREATMENT_ARM")
        store_patient(patient_assignment)
      when 'REQUEST_ASSIGNMENT', 'REQUEST_NO_ASSIGNMENT', 'OFF_STUDY', 'OFF_STUDY_BIOPSY_EXPIRED'
        Shoryuken.logger.info("Recieved patient '#{patient_assignment[:patient_id]}' at state #{patient_assignment[:patient_status]}")
        store_patient(patient_assignment)
      when 'COMPASSIONATE_CARE'
        Shoryuken.logger.info("Recieved patient with patient_id '#{patient_assignment[:patient_id]}' at state COMPASSIONATE_CARE")
        store_patient(patient_assignment)
      else
        Shoryuken.logger.info("Recieved patient with patient_id '#{patient_assignment[:patient_id]}' with no current recognized state")
      end
    rescue => error
      Shoryuken.logger.error("Failed to process Patient Assignment with error #{error}::#{error.backtrace}")
    end
  end

  def store_patient(patient_assignment)
    if TreatmentArmAssignmentEvent.find_by(patient_id: patient_assignment[:patient_id]).blank?
      insert(patient_assignment)
    else
      update(patient_assignment)
    end
    BasicTreatmentArmJob.new.perform
  end

  def update(patient_assignment)
    begin
      patient_ta = TreatmentArmAssignmentEvent.find_by(patient_id: patient_assignment[:patient_id]).sort_by{ |pa_ta| pa_ta.assignment_date }.reverse.first
      next_event = patient_ta.next_event(patient_ta.event, patient_assignment[:patient_status])
      patient_ta.event = next_event
      patient_ta.patient_status = assess_patient_status(next_event, patient_assignment[:patient_status])
      patient_ta.step_number = patient_assignment[:step_number]
      patient_ta.date_on_arm = patient_assignment[:date_on_arm]
      patient_ta.date_off_arm = patient_assignment[:date_off_arm]
      patient_ta.save(force: true)
      Shoryuken.logger.info("Patient '#{patient_model.patient_id}' was successfully updated for assignment to the TreatmentArm with treatment_arm_id '#{patient_model.treatment_arm_id}' & stratum_id '#{patient_model.stratum_id}'")
    rescue => error
      Shoryuken.logger.error("Failed to update Patient Assignment with error: #{error}::#{error.backtrace}")
    end
  end

  def insert(patient_assignment)
    begin
      patient_model = TreatmentArmAssignmentEvent.new
      json = patient_model.convert_model(patient_assignment).to_json
      patient_model.from_json(json)
      patient_model.save
      Shoryuken.logger.info("Patient '#{patient_model.patient_id}' was successfully saved for assignment to the TreatmentArm with treatment_arm_id '#{patient_model.treatment_arm_id}' & stratum_id '#{patient_model.stratum_id}'")
    rescue => error
      Shoryuken.logger.error("Failed to insert Patient Assignment with error: #{error}::#{error.backtrace}")
    end
  end

  def fail_safe(patient_assignment)
    unless TreatmentArmAssignmentEvent.find_by(patient_id: patient_assignment[:patient_id],
                                               assignment_date: patient_assignment[:assignment_date]).blank?
      raise ArgumentError, "Patient #{patient_assignment[:patient_id]} with assignment date #{patient_assignment[:assignment_date]}is already in database...ignoring"
    end
    patient_ta = TreatmentArmAssignmentEvent.find_by(patient_id: patient_assignment[:patient_id]).sort_by{ |patient_ta| patient_ta.assignment_date }.reverse.first
    unless patient_ta.blank?
      if patient_ta.assignment_date > Date.parse(patient_assignment[:assignment_date])
        raise ArgumentError, "Patient #{patient_assignment[:patient_id]} assignment is out of order. Current: #{patient_ta.to_h} Received: #{patient_assignment}"
      end
    end
  end

  private

  def assess_patient_status(event, status)
    if event == TreatmentArmAssignmentEvent::FORMER_PATIENT && ['REQUEST_ASSIGNMENT', 'REQUEST_NO_ASSIGNMENT'].include?(status.upcase)
      status = 'PREVIOUSLY_ON_ARM'
    elsif event == TreatmentArmAssignmentEvent::FORMER_PATIENT && ['OFF_STUDY', 'OFF_STUDY_BIOPSY_EXPIRED'].include?(status.upcase)
      status = 'PREVIOUSLY_ON_ARM_OFF_STUDY'
    elsif event == TreatmentArmAssignmentEvent::NOT_ENROLLED && ['REQUEST_ASSIGNMENT', 'REQUEST_NO_ASSIGNMENT'].include?(status.upcase)
      status = 'NOT_ENROLLED_ON_ARM'
    elsif event == TreatmentArmAssignmentEvent::NOT_ENROLLED && ['OFF_STUDY', 'OFF_STUDY_BIOPSY_EXPIRED'].include?(status.upcase)
      status = 'NOT_ENROLLED_ON_ARM_OFF_STUDY'
    else
      # Confirm the PENDING_CONFIRMATION TO OFF_STUDY STATUS TRANSFER
    end
    status
  end
end
