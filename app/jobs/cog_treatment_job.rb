# Calls COG and Updates the Latest TA Status
class CogTreatmentJob
  include HTTParty

  def perform
    begin
      results = HTTParty.get(Rails.configuration.environment.fetch('cog_url') + Rails.configuration.environment.fetch('cog_treatment_arms'))
      cog_arms_status = JSON.parse(results.body).deep_transform_keys!(&:underscore).symbolize_keys!
      cog_arms_status[:treatment_arms].each do |treatment_arm|
        update_status(treatment_arm)
      end
      cog_arms_status[:treatment_arms]
    rescue => error
      Shoryuken.logger.error('Failed to connect to COG #{error}')
    end
  end

  def update_status(cog_treatment_arm)
    begin
      cog_treatment_arm.deep_transform_keys!(&:underscore).symbolize_keys!
      match_treatment_arm = TreatmentArm.find_by(cog_treatment_arm[:treatment_arm_id], cog_treatment_arm[:stratum_id], nil, false).first
      unless match_treatment_arm.blank?
        if match_treatment_arm.treatment_arm_status != 'CLOSED' && match_treatment_arm.treatment_arm_status != cog_treatment_arm[:status]
          match_treatment_arm.treatment_arm_status = cog_treatment_arm[:status]
          match_treatment_arm.status_log = rewrite_status_log(match_treatment_arm.status_log, {cog_treatment_arm[:status_date] => cog_treatment_arm[:status]})
          match_treatment_arm.save
          Shoryuken.logger.info("Treatment arm #{cog_treatment_arm[:treatment_arm_id]} (#{cog_treatment_arm[:stratum_id]}) has been updated")
        else
          Shoryuken.logger.info("Treatment arm #{cog_treatment_arm[:treatment_arm_id]} (#{cog_treatment_arm[:stratum_id]}) is currently CLOSED or Already in the correct state")
        end
      end
      Shoryuken.logger.info('No Treatment Arms status to update')
    rescue => error
      Shoryuken.logger.error('Failed to update TA status from COG with error #{error}')
    end
  end

  def rewrite_status_log(status_log, append_hash={})
    new_log = {}
    new_log.merge!(status_log)
    new_log.merge!(append_hash)
    new_log
  end
end
