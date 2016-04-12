class TreatmentJob
    @queue = :treatment_arm

    def self.perform(treatment_arm)
      begin
        treatment_arm = treatment_arm.symbolize_keys
        if TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id]).exists?
          update(treatment_arm)
        else
          p "insert"
          insert(treatment_arm)
        end
      rescue => error
        p error
      end
    end

    def self.update(treatment_arm)
      p treatment_arm[:version]
      if TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id]).and(:version => treatment_arm[:version]).exists?
        p "dup"
      else
        p "update insert"
        insert(treatment_arm)
      end
    end

    def self.insert(treatment_arm)
      treatment_arm_model = TreatmentArm.new(treatment_arm)
      treatment_arm_model.save
    end
end