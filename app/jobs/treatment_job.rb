# TreatmentArm insert/update Job
class TreatmentJob
  include HTTParty

  def perform(treatment_arm, clone=false)
    begin
      treatment_arm = treatment_arm.symbolize_keys!
      if TreatmentArm.find_by(treatment_arm[:treatment_arm_id], treatment_arm[:stratum_id], treatment_arm[:version]).blank?
        insert(treatment_arm)
      elsif treatment_arm[:treatment_arm_id].present? && treatment_arm[:stratum_id].present? && treatment_arm[:version].present?
        clone(treatment_arm)
      end
      CogTreatmentJob.new.perform
      BasicTreatmentArmJob.new.perform
    rescue => error
      Shoryuken.logger.error("TreatmentArm Worker when uploading TreatmentArm with treatment_arm_id '#{treatment_arm[:treatment_arm_id]}' & stratum_id '#{treatment_arm[:stratum_id]}' failed with the error #{error}::#{error.backtrace}")
    end
  end

  def clone(treatment_arm)
    begin
      new_treatment_arm_json = TreatmentArm.build_cloned(treatment_arm)
      new_treatment_arm = TreatmentArm.new(new_treatment_arm_json)
      deactivate(treatment_arm) if new_treatment_arm.save
      Shoryuken.logger.info("TreatmentArm with treatment_arm_id '#{new_treatment_arm.treatment_arm_id}', stratum_id '#{new_treatment_arm.stratum_id}' & with new version '#{new_treatment_arm.version}' has been saved successfully")
    rescue => error
      Shoryuken.logger.error("Failed to save the new version of the TreatmentArm(treatment_arm_id: #{new_treatment_arm.treatment_arm_id}, stratum_id: #{new_treatment_arm.stratum_id}) with the error #{error}::#{error.backtrace}")
    end
  end

  # Turns the old TA active flag to false if the TA gets updated with a new version
  def deactivate(treatment_arm)
    treatment_arm = TreatmentArm.find_by(treatment_arm[:treatment_arm_id], treatment_arm[:stratum_id], treatment_arm[:version], false).first
    treatment_arm.active = false
    treatment_arm.save
  end

  # Saves the TreatmentArm into the DataBase
  def insert(treatment_arm)
    begin
      treatment_arm_model = TreatmentArm.new
      json = remove_blank_document(treatment_arm)
      json = treatment_arm_model.convert_models(json).to_json
      treatment_arm_model.from_json(json)
      treatment_arm_model.save
      Shoryuken.logger.info("TreatmentArm with treatment_arm_id '#{treatment_arm[:treatment_arm_id]}', stratum_id '#{treatment_arm[:stratum_id]}' & version '#{treatment_arm[:version]}' has been saved successfully")
    rescue => error
      Shoryuken.logger.error("Failed to save TreatmentArm with treatment_arm_id '#{treatment_arm[:treatment_arm_id]}', stratum_id '#{treatment_arm[:stratum_id]}' & version '#{treatment_arm[:version]}' with the error #{error}::#{error.backtrace}")
    end
  end

  def remove_blank_document(treatment_arm)
    hash_proc = Proc.new { |k, v| v.kind_of?(Hash) ? (v.delete_if(&hash_proc); nil) : v.to_s.blank? }
    treatment_arm.delete_if(&hash_proc)
    unless treatment_arm[:exclusion_drugs].blank?
      treatment_arm[:exclusion_drugs].each do |drugs|
        drugs.delete_if(&hash_proc)
      end
    end
    treatment_arm
  end
end
