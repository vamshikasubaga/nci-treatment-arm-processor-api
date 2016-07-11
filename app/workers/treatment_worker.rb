class TreatmentWorker
  include Shoryuken::Worker
  include HTTParty

  shoryuken_options queue: ->{"#{ENV['queue_name']}"}, auto_delete: true

  def perform(_sqs_message, treatment_arm)
    begin
      treatment_arm = JSON.parse(treatment_arm).symbolize_keys!
      if(TreatmentArm.find_by(treatment_arm[:id], treatment_arm[:stratum_id], treatment_arm[:version]).blank?)
        insert(treatment_arm)
      else
        Shoryuken.logger.info("TreatmentArm #{treatment_arm[:id]} stratum_id #{treatment_arm[:stratum_id]} version #{treatment_arm[:version]} exists already.  Skipping")
      end
      get_cog_treatment_arm_status
    rescue => error
      Shoryuken.logger.error("Treatment Arm Worker failed with error #{error}")
    end
  end

  def insert(treatment_arm)
    begin
      treatment_arm_model = TreatmentArm.new
      json = remove_blank_document(treatment_arm)
      json = treatment_arm_model.convert_models(json).to_json
      treatment_arm_model.from_json(json)
      treatment_arm_model.save
      Shoryuken.logger.info("TreatmentArm #{treatment_arm[:id]} version #{treatment_arm[:version]} has been saved successfully")
    rescue => error
      Shoryuken.logger.error("Failed to save treatment arm with error #{error}")
    end
  end

  def get_cog_treatment_arm_status
    begin
      results = HTTParty.get('http://localhost:3000/treatmentArms')
      cog_arms_status = JSON.parse(results.body).deep_transform_keys!(&:underscore).symbolize_keys!
      cog_arms_status[:treatment_arms].each do | treatment_arm |
        update_status(treatment_arm)
      end
    rescue => error
      Shoryuken.logger.error("Failed to connect to COG #{error}")
    end
  end

  def update_status(cog_treatment_arm)
    begin
      cog_treatment_arm.deep_transform_keys!(&:underscore).symbolize_keys!
      match_treatment_arm = TreatmentArm.find_by(cog_treatment_arm[:treatment_arm_id], cog_treatment_arm[:stratum_id]).first
      if(!match_treatment_arm.blank?)
        if(match_treatment_arm.treatment_arm_status != "CLOSED")
          match_treatment_arm.treatment_arm_status = cog_treatment_arm[:status]
          match_treatment_arm.status_log = match_treatment_arm.status_log.merge!({cog_treatment_arm[:status_date] => cog_treatment_arm[:status]}).to_h
          match_treatment_arm.save
          Shoryuken.logger.info("Treatment arm #{cog_treatment_arm[:treatment_arm_id]} (#{cog_treatment_arm[:stratum_id]}) has been updated")
        end
        Shoryuken.logger.info("Treatment arm #{cog_treatment_arm[:treatment_arm_id]} (#{cog_treatment_arm[:stratum_id]}) is currently CLOSED")
      end
      Shoryuken.logger.info("No Treatment Arms status to update")
    rescue => error
      Shoryuken.logger.error("Failed to update TA status from COG with error #{error}")
    end
  end

  #Refacto!
  def remove_blank_document(treatment_arm)
    hash_proc = Proc.new { |k, v| v.kind_of?(Hash) ? (v.delete_if(&hash_proc); nil) : v.to_s.blank? }
    treatment_arm.delete_if(&hash_proc)
    if !treatment_arm[:exclusion_drugs].blank?
      treatment_arm[:exclusion_drugs].each do | drugs |
        drugs.delete_if(&hash_proc)
      end
    end
    treatment_arm
  end
end