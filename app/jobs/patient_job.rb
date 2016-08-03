
class PatientJob

  def perform(patient_assignment)
    begin
      patient_assignment = JSON.parse(patient_assignment).symbolize_keys
      if(!TreatmentArmPatient.find(patient_id: patient_assignment[:patient_id], assignment_date: patient_assignment[:date_assigned]).blank?)
        raise ArgumentError, "Patient is already in database...ignoring #{patient[:patient_id]} at state #{patient_assignment[:date_assigned]}"
      end
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
        else
          Shoryuken.logger.info("Recieved patient with no current recognized state : #{patient_assignment[:patient_id]}")
      end
    rescue => error
      Shoryuken.logger.error("Failed to process patient assignment message with error #{error.message}")
    end
  end

  def store_patient(patient_assignment)
    begin
      patient_model = TreatmentArmPatient.new
    rescue => error
      Shoryuken.logger.error("Failed to insert TreatmentArmPatient with error: #{error.message}")
    end
  end

  # def store_patient_on_arm(patient)
  #   if TreatmentArm.where(:treatment_arm_id => patient[:treatment_arm_id], :version => patient[:treatment_arm_version], :patient.in => ["", nil]).exists?
  #     ta = TreatmentArm.where(:treatment_arm_id => patient[:treatment_arm_id], :version => patient[:treatment_arm_version]).first
  #     insert(ta, patient)
  #   elsif TreatmentArm.where(:treatment_arm_id => patient[:treatment_arm_id], :version => patient[:treatment_arm_version], :patient.nin => ["", nil]).exists?
  #     ta = TreatmentArm.where(:treatment_arm_id => patient[:treatment_arm_id], :version => patient[:treatment_arm_version]).first
  #     update(ta, patient)
  #   else
  #     raise ArgumentError, "Patient was found for treatment arm #{patient[:treatment_arm_id]} but treatment arm does not exists...requeue patient"
  #   end
  # end


  # def update(treatment_arm, patient)
  #   patient_on_arm = treatment_arm.clone
  #   patient_on_arm.patient = mold_patient_data(patient)
  #   patient_on_arm.save
  #   ack!
  # end

  # def insert(treatment_arm, patient)
  #   treatment_arm.patient = mold_patient_data(patient)
  #   treatment_arm.save
  #   ack!
  # end

  def mold_patient_data(patient)
    new_patient = Patient.new
    new_patient.patient_sequence_number = patient[:patient_sequence_number]
    new_patient.variant_report = patient[:biopsy]
    new_patient.diseases = patient[:diseases]
    new_patient.current_step_number = patient[:current_step_number]
    new_patient.current_patient_status = patient[:current_patient_status]
    patient[:patient_assignments].each do | patient_assignment |
      new_patient.patient_assignments << mold_patient_assignment_data(patient_assignment)
    end
    new_patient.concordance = patient[:concordance]
    new_patient.registration_date = patient[:registration_date]
    return new_patient
  end

  def mold_patient_assignment_data(patient_assignment)
    patient_assignment = patient_assignment.symbolize_keys
    new_patient_assignment = PatientAssignment.new
    new_patient_assignment.date_assigned = patient_assignment[:date_assigned]
    new_patient_assignment.biopsy_sequence_number = patient_assignment[:biopsy_sequence_number]
    new_patient_assignment.patient_assignment_status = patient_assignment[:patient_assignment_status]
    new_patient_assignment.patient_assignment_logic = patient_assignment[:patient_assignment_logic]
    new_patient_assignment.patient_assignment_status_message = patient_assignment[:patient_assignment_status_message]
    new_patient_assignment.step_number = patient_assignment[:step_number]
    new_patient_assignment.patient_assignment_messages = patient_assignment[:patient_assignment_messages]
    new_patient_assignment.date_confirmed = patient_assignment[:date_confirmed]
    return new_patient_assignment
  end


end