
class BasicTreatmentArmPatientJob

  # ECOGPatientAssignment
  # {:patientSequenceNumber => "", :treatmentArmId => "", :patientAssignment => {}}
  def self.perform(ecog_patient_assignment)
    begin
      patient = ecog_patient_assignment.symbolize_keys
      patient[:patientAssignment].each do | patient_assignment |

      end
    rescue => error
      p error
    end
  end


  def self.update()

  end
end