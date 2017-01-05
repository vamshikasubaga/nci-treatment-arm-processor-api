# Calls COG and Updates the Latest TreatmentArm Status
class CogTreatmentJob
  include HTTParty

  def perform
    begin
      Shoryuken.logger.info("#{self.class.name} | ***** Calling COG at #{Rails.configuration.environment.fetch('cog_url')} *****")
      auth = { username: Rails.configuration.environment.fetch('cog_user_name'), password: Rails.configuration.environment.fetch('cog_pwd') } if Rails.env.uat?
      results = HTTParty.get(Rails.configuration.environment.fetch('cog_url') + Rails.configuration.environment.fetch('cog_treatment_arms'), basic_auth: auth)
      cog_arms_status = JSON.parse(results.body).deep_transform_keys!(&:underscore).symbolize_keys!
      cog_arms_status[:treatment_arms].each do |treatment_arm|
        update_status(treatment_arm)
      end
      cog_arms_status[:treatment_arms]
    rescue => error
      Shoryuken.logger.error("#{self.class.name} | Failed to connect to COG with error #{error}")
      if Rails.env.uat?
        Shoryuken.logger.info("#{self.class.name} | Switching to use mock COG for UAT...")
        Shoryuken.logger.info("#{self.class.name} | Connecting to Mock cog : #{Rails.configuration.environment.fetch('mock_cog_url')}")
        MockCogService.perform
      end
    end
  end

  def update_status(cog_treatment_arm)
    begin
      cog_treatment_arm.deep_transform_keys!(&:underscore).symbolize_keys!
      match_treatment_arms = TreatmentArm.find_by(cog_treatment_arm[:treatment_arm_id], cog_treatment_arm[:stratum_id], nil, false)
      match_treatment_arms.each do |match_treatment_arm|
        unless match_treatment_arm.blank?
          if match_treatment_arm.treatment_arm_status != 'CLOSED' && match_treatment_arm.treatment_arm_status != cog_treatment_arm[:status]
            match_treatment_arm.treatment_arm_status = cog_treatment_arm[:status]
            match_treatment_arm.status_log = rewrite_status_log(match_treatment_arm.status_log, {cog_treatment_arm[:status_date] => cog_treatment_arm[:status]})
            match_treatment_arm.save
            Shoryuken.logger.info("#{self.class.name} | The status for the TreatmentArm with treatment_arm_id '#{cog_treatment_arm[:treatment_arm_id]}' & stratum_id '#{cog_treatment_arm[:stratum_id]}' has been successfully updated")
          else
            Shoryuken.logger.info("#{self.class.name} | TreatmentArm with treatment_arm_id '#{cog_treatment_arm[:treatment_arm_id]}' & stratum_id '#{cog_treatment_arm[:stratum_id]}' is currently CLOSED or already in the correct state")
          end
        end
      end
      Shoryuken.logger.info("#{self.class.name} | No TreatmentArms status to update")
    rescue => error
      Shoryuken.logger.error("#{self.class.name} | Failed to update TreatmentArm status from COG with error #{error}::#{error.backtrace}")
    end
  end

  def rewrite_status_log(status_log, append_hash={})
    new_log = {}
    new_log.merge!(status_log)
    new_log.merge!(append_hash)
    new_log
  end
end
