class TreatmentJob
    @queue = :treatment_arm

    def self.perform(treatment_arm)
      begin
        treatment_arm = treatment_arm.symbolize_keys
        if TreatmentArm.where(:_id => treatment_arm[:id]).exists?
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
      treatment_arm_model = TreatmentArm.new(treatment_arm)
      treatment_arm_model.save
    end
end