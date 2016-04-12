require 'date'
require 'basic_treatment_arm'

class BasicTreatmentArmJob

  def self.perform(treatment_arm)
    begin
      treatment_arm = treatment_arm.symbolize_keys
      if BasicTreatmentArm.where(:_id => treatment_arm[:treatment_arm_id]).exists?
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
    sorted_status_log = !treatment_arm[:status_log].blank? ? treatment_arm[:status_log].sort_hash_descending  : {}
    basic_treatment_arm = { :_id => treatment_arm[:treatment_arm_id],
                            :treatment_arm_name => treatment_arm[:name],
                            :current_patients => treatment_arm[:num_patients_assigned],
                            :former_patients => 0,
                            :not_enrolled_patients => 0,
                            :pending_patients => 0,
                            :treatment_arm_status => treatment_arm[:treatment_arm_status],
                            :date_created => !treatment_arm[:date_created].blank? ? (treatment_arm[:date_created]).to_time.to_i : nil,
                            :date_opened => sorted_status_log.key("OPEN"),
                            :date_closed => sorted_status_log.key("CLOSED"),
                            :date_suspended => sorted_status_log.key("SUSPENDED")
    }
    ba = BasicTreatmentArm.new(basic_treatment_arm)
    p ba.save
  end

end
