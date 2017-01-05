# TreatmentArm insert/update Job
class TreatmentJob
  include HTTParty

  def perform(treatment_arm, _clone=false)
    begin
      Shoryuken.logger.info("#{self.class.name} | ***** Received TreatmentArm with treatment_arm_id '#{treatment_arm['treatment_arm_id']}', stratum_id '#{treatment_arm['stratum_id']}' & version '#{treatment_arm['version']}' *****")
      treatment_arm_hash = treatment_arm.symbolize_keys!
      current_active_ta = find_treatment_arm(treatment_arm_hash[:treatment_arm_id], treatment_arm_hash[:stratum_id], true).first
      if current_active_ta.nil?
        insert(treatment_arm_hash)
      else
        insert_new_version(treatment_arm_hash, current_active_ta)
      end
    rescue => error
      Shoryuken.logger.error("#{self.class.name} | TreatmentArm Worker when uploading TreatmentArm with treatment_arm_id '#{treatment_arm[:treatment_arm_id]}' & stratum_id '#{treatment_arm[:stratum_id]}' failed with the error #{error}::#{error.backtrace}")
    end
  end

  def insert_new_version(treatment_arm_hash, current_active_ta)
    new_treatment_arm = create_new_version(treatment_arm_hash)
    deactivate(current_active_ta) if new_treatment_arm.save
  end

  def create_new_version(treatment_arm_hash)
    new_treatment_arm_hash = TreatmentArm.build_cloned(treatment_arm_hash)
    new_treatment_arm = TreatmentArm.new(new_treatment_arm_hash)
    Shoryuken.logger.info("#{self.class.name} | TreatmentArm with treatment_arm_id '#{new_treatment_arm.treatment_arm_id}', stratum_id '#{new_treatment_arm.stratum_id}' & with new version '#{new_treatment_arm.version}' has been saved successfully")
    new_treatment_arm
  end

  # Turns the old TA active flag to false if the TA gets updated with a new version
  def deactivate(treatment_arm)
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
      Shoryuken.logger.info("#{self.class.name} | TreatmentArm with treatment_arm_id '#{treatment_arm[:treatment_arm_id]}', stratum_id '#{treatment_arm[:stratum_id]}' & version '#{treatment_arm[:version]}' has been saved successfully")
    rescue => error
      Shoryuken.logger.error("#{self.class.name} | Failed to save TreatmentArm with treatment_arm_id '#{treatment_arm[:treatment_arm_id]}', stratum_id '#{treatment_arm[:stratum_id]}' & version '#{treatment_arm[:version]}' with the error #{error}::#{error.backtrace}")
    end
  end

  def remove_blank_document(treatment_arm)
    hash_proc = Proc.new { |_k, v| v.kind_of?(Hash) ? (v.delete_if(&hash_proc); nil) : v.to_s.blank? }
    treatment_arm.delete_if(&hash_proc)
    unless treatment_arm[:exclusion_drugs].blank?
      treatment_arm[:exclusion_drugs].each do |drugs|
        drugs.delete_if(&hash_proc)
      end
    end
    treatment_arm
  end

  def find_treatment_arm(treatment_arm_id, stradum_id, active=false)
    query = {}
    query.merge!('treatment_arm_id' => { comparison_operator: 'CONTAINS', attribute_value_list: [treatment_arm_id] })
    query.merge!('stratum_id' => { comparison_operator: 'EQ', attribute_value_list: [stradum_id] })
    query.merge!('is_active_flag' => { comparison_operator: 'EQ', attribute_value_list: [active] })
    TreatmentArm.scan(scan_filter: query, conditional_operator: 'AND')
  end
end
