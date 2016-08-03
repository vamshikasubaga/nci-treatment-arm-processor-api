
class PatientJob

  attr_accessor :patient_assignment_message

  def perform(patient_assignment)
    begin
      patient_assignment.symbolize_keys!
      fail_safe(patient_assignment)
      case patient_assignment[:patient_assignment_status]
        when "ON_TREATMENT_ARM"
          Shoryuken.logger.info("Recieved patient at state ON_TREATMENT_ARM : #{patient_assignment[:patient_id]}")
          store_patient(patient_assignment)
        when "NOT_ELIGIBLE"
          Shoryuken.logger.info("Recieved patient at state NOT_ELIGIBLE : #{patient_assignment[:patient_id]}")
          store_patient(patient_assignment)
        when "PENDING_APPROVAL"
          Shoryuken.logger.info("Recieved patient at state PENDING_APPROVAL : #{patient_assignment[:patient_id]}")
          store_patient(patient_assignment)
        when "OFF_TRIAL", "OFF_TRIAL_NOT_CONSENTED", "OFF_TRIAL_DECEASED"
          Shoryuken.logger.info("Recieved patient at state OFF_TRIAL_* : #{patient_assignment[:patient_id]} at state #{patient_assignment[:patient_assignment_status]}")
          store_patient(patient_assignment)
        when "FORMERLY_ON_ARM_PROGRESSED"
          Shoryuken.logger.info("Recieved patient at state FORMERLY_ON_ARM_PROGRESSED : #{patient_assignment[:patient_id]} at state #{patient_assignment[:patient_assignment_status]}")
          store_patient(patient_assignment)
        else
          Shoryuken.logger.info("Recieved patient with no current recognized state : #{patient_assignment[:patient_id]}")
      end
    rescue => error
      Shoryuken.logger.error("Failed to process patient assignment message with error #{error.message}")
    end
  end

  def store_patient(patient_assignment)
    if(TreatmentArmPatient.find_by(:patient_id => patient_assignment[:patient_id]).blank?)
      insert(patient_assignment)
    else
      update(patient_assignment)
    end
    BasicTreatmentArmJob.new.perform
  end

  def update(patient_assignment)
    begin
      patient_ta = TreatmentArmPatient.find_by(:patient_id => patient_assignment[:patient_id]).sort_by{| pa_ta | pa_ta.date_assigned}.reverse.first
      patient_ta.patient_assignment_status = "FORMERLY_ON_ARM_PROGRESSED"
      patient_ta.save
      insert(patient_assignment)
    rescue => error
      Shoryuken.logger.error("Failed to update TreatmentArmPatient with error: #{error.message}")
    end
  end

  def insert(patient_assignment)
    begin
      patient_model = TreatmentArmPatient.new
      json = patient_model.convert_model(patient_assignment).to_json
      patient_model.from_json(json)
      patient_model.save
      Shoryuken.logger.info("Patient #{patient_model.patient_id} was successfully saved for assignment to #{patient_model.treatment_arm_name}")
    rescue => error
      Shoryuken.logger.error("Failed to insert TreatmentArmPatient with error: #{error.message}")
    end
  end

  def fail_safe(patient_assignment)
    if(!TreatmentArmPatient.find(patient_id: patient_assignment[:patient_id], date_assigned: patient_assignment[:date_assigned]).blank?)
      raise ArgumentError, "Patient #{patient_assignment[:patient_id]} with assignment date #{patient_assignment[:date_assigned]}is already in database...ignoring"
    end
    patient_ta = TreatmentArmPatient.find_by(patient_id: patient_assignment[:patient_id]).sort_by{| patient_ta | patient_ta.date_assigned}.reverse.first
    if(!patient_ta.blank?)
      if(patient_ta.date_assigned > Date.parse(patient_assignment[:date_assigned]))
        raise ArgumentError, "Patient #{patient_assignment[:patient_id]} assignment is out of order.  Current: #{patient_ta.to_h} Received: #{patient_assignment}"
      end
    end
  end

end