# Gets Triggered when COG is down or when Failed to connect to COG
class MockCogService
  include HTTParty

  def self.perform
    Shoryuken.logger.info("Mock COG service is Triggered to get the Latest TreatmentArm status")
    results = HTTParty.get(Rails.configuration.environment.fetch('mock_cog_url') + Rails.configuration.environment.fetch('cog_treatment_arms'))
    cog_arms_status = JSON.parse(results.body).deep_transform_keys!(&:underscore).symbolize_keys!
      cog_arms_status[:treatment_arms].each do |treatment_arm|
        status_update(treatment_arm)
      end
    cog_arms_status[:treatment_arms]
  end

  def self.status_update(cog_treatment_arm)
    begin
      cog_treatment_arm.deep_transform_keys!(&:underscore).symbolize_keys!
      match_treatment_arms = TreatmentArm.find_by(cog_treatment_arm[:treatment_arm_id], cog_treatment_arm[:stratum_id], nil, false)
      match_treatment_arms.each do |match_treatment_arm|
        unless match_treatment_arm.blank?
          if match_treatment_arm.treatment_arm_status != 'CLOSED' && match_treatment_arm.treatment_arm_status != cog_treatment_arm[:status]
            match_treatment_arm.treatment_arm_status = cog_treatment_arm[:status]
            match_treatment_arm.status_log = rewrite_status_log(match_treatment_arm.status_log, {cog_treatment_arm[:status_date] => cog_treatment_arm[:status]})
            match_treatment_arm.save
            Shoryuken.logger.info("The status for the TreatmentArm with treatment_arm_id '#{cog_treatment_arm[:treatment_arm_id]}' & stratum_id '#{cog_treatment_arm[:stratum_id]}' has been successfully updated")
          else
            Shoryuken.logger.info("TreatmentArm with treatment_arm_id '#{cog_treatment_arm[:treatment_arm_id]}' & stratum_id '#{cog_treatment_arm[:stratum_id]}' is currently CLOSED or already in the correct state")
          end
        end
      end
      Shoryuken.logger.info("No TreatmentArms status to update")
    rescue => error
      Shoryuken.logger.error("Failed to update TreatmentArm status from Mock COG with error #{error}::#{error.backtrace}")
    end
  end

  def self.rewrite_status_log(status_log, append_hash={})
    new_log = {}
    new_log.merge!(status_log)
    new_log.merge!(append_hash)
    new_log
  end
end