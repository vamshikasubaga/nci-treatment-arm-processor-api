class PatientJob

  @queue = :patient

  def self.perform(patient)
    begin
      patient = patient.symbolize_keys
      case patient[:current_patient_status]
        when "ON_TREATMENT_ARM"
          p "patient on arm"
          on_treatment_arm_patient(patient)
        else
          p "No case statment"
      end
    rescue => error
      p error
    end
  end


  def self.on_treatment_arm_patient(patient)
    if TreatmentArm.where(:treatment_arm_id => patient[:current_treatment_arm]["_id"], :version => patient[:current_treatment_arm]["version"], :patient.in => ["", nil]).exists?
      ta = TreatmentArm.where(:treatment_arm_id => patient[:current_treatment_arm]["_id"], :version => patient[:current_treatment_arm]["version"]).first
      ta.patient = mold_patient_data(patient)
      ta.save
    elsif TreatmentArm.where(:treatment_arm_id => patient[:current_treatment_arm]["_id"], :version => patient[:current_treatment_arm]["version"], :patient.nin => ["", nil]).exists?
      ta = TreatmentArm.where(:treatment_arm_id => patient[:current_treatment_arm]["_id"], :version => patient[:current_treatment_arm]["version"]).first
      patient_on_arm = ta.clone
      patient_on_arm.patient = mold_patient_data(patient)
      patient_on_arm.save 
    else
      p "requeue patient"
      Resque.enqueue(PatientJob, patient)
    end
  end


  def self.update(patient)

  end

  def self.insert(new_patient)
    ba = Patient.new(new_patient)
    ba.save
  end

  def self.mold_patient_data(patient)
    new_patient = Patient.new
    new_patient.patient_sequence_number = patient[:patient_sequence_number]
    new_patient.patient_triggers = patient[:patient_triggers]
    new_patient.current_step_number = patient[:current_step_number]
    new_patient.current_patient_status = patient[:current_patient_status]
    patient[:patient_assignments].each do | patient_assignment |
      new_patient.patient_assignments << mold_patient_assignment_data(patient_assignment)
    end
    new_patient.concordance = patient[:concordance]
    new_patient.registration_date = patient[:registration_date]
    return new_patient
  end

  def self.mold_patient_assignment_data(patient_assignment)
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