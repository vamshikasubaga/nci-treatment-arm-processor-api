class QueueTreatmentArmJob
  include HTTParty

  def perform
    begin
      CogTreatmentJob.new.perform
      treatment_arms = TreatmentArm.find_by()
      HTTParty.post(Rails.configuration.environment.fetch('patient_api_url') + Rails.configuration.environment.fetch('patient_assignment'),
                    :body => {:treatment_arms => treatment_arms}.to_json,
                    :headers => { 'Content-Type' => 'application/json' }
      )
    rescue => error
      Shoryuken.logger.error("Failed to connect to Patient API with error #{error.message}")
    end
  end

end