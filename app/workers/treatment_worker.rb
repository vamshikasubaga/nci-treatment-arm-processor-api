class TreatmentWorker
  include Sneakers::Worker
    from_queue :treatment_arm,
               :durable => true,
               :block => true

    def work(treatment_arm)
      begin
        treatment_arm = JSON.parse(treatment_arm).symbolize_keys
        if TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id]).exists?
          update(treatment_arm)
        else
          insert(treatment_arm)
        end
        ack!
      rescue => error
        reject!
        p error
      end
    end

    def update(treatment_arm)
      if TreatmentArm.where(:treatment_arm_id => treatment_arm[:treatment_arm_id]).and(:version => treatment_arm[:version]).exists?
        p "Treatment_arm (#{treatment_arm[:treatment_arm_id]}) version (#{treatment_arm[:version]}) already exists"
      else
        insert(treatment_arm)
      end
    end

    def insert(treatment_arm)
      begin
        treatment_arm_model = TreatmentArm.new(treatment_arm)
        treatment_arm_model.save
      rescue => error
        p "Failed to said treatment arm with error #{error}"
        reject!
      end
    end
end