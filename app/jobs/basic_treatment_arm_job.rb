require 'date'
require 'basic_treatment_arm'

class BasicTreatmentArmJob

  def self.perform(treatment_arm)
    begin
      treatment_arm = treatment_arm.symbolize_keys
      if BasicTreatmentArm.where(:_id => treatment_arm[:id]).exists?
        update(treatment_arm)
      else
        insert(treatment_arm)
      end
    rescue => error
      p error
    end
  end

  def self.update(treatment_arm)

  end

  def self.insert(treatment_arm)
    sorted_status_log = !treatment_arm[:statusLog].blank? ? treatment_arm[:statusLog].sort_hash_descending  : {}
    basic_treatment_arm = { :_id => treatment_arm[:_id],
                            :treatmentArmName => treatment_arm[:name],
                            :currentPatients => treatment_arm[:numPatientsAssigned],
                            :formerPatients => 0,
                            :notEnrolledPatients => 0,
                            :pendingPatients => 0,
                            :treatmentArmStatus => treatment_arm[:treatmentArmStatus],
                            :dateCreated => !treatment_arm[:dateCreated].blank? ? (treatment_arm[:dateCreated]).to_time.to_i : nil,
                            :dateOpened => sorted_status_log.key("OPEN"),
                            :dateClosed => sorted_status_log.key("CLOSED"),
                            :dateSuspended => sorted_status_log.key("SUSPENDED")
    }
    ba = BasicTreatmentArm.new(basic_treatment_arm)
    p ba.save
  end

end
