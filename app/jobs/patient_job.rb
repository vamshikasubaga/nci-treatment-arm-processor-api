class PatientJob

  @queue = :patient

  def self.perform(patient)
    begin
      patient = patient.symbolize_keys
      if BasicPatient.where(:patient_sequence_number => patient[:patient_sequence_number]).exists?
        update()
      else
        insert(mold_data(patient))
      end
    rescue => error
      p error
    end
  end


  def self.update(patient)

  end

  def self.insert(new_patient)
    ba = BasicPatient.new(new_patient)
    ba.save
  end

  def self.mold_data(patient)
    new_patient = {
        :patient_sequence_number => patient[:patient_sequence_number],
        :patient_triggers => patient[:patient_triggers],
        :current_step_number => patient[:current_step_number],
        :current_patient_status => patient[:current_patient_status],
        :patient_assignments => patient[:patient_assignments],
        :concordance => patient[:concordance],
        :registration_date => patient[:registration_date],
        :patient_rejoin_triggers => patient[:patient_rejoin_triggers]
    }
  end


end