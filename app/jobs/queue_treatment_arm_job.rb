class QueueTreatmentArmJob
  include HTTParty

  def perform
    begin
      CogTreatmentJob.new.perform
      treatment_arms = TreatmentArm.find_by()
      HTTParty.post(ENV["patient_api_url"] + ENV["patient_assignment"],
                    :body => {:treatment_arms => treatment_arms}.to_json,
                    :headers => { 'Content-Type' => 'application/json' }
      )
    rescue => error
      Shoryuken.logger.error("Failed to connect to Patient API with error #{error.message}")
    end
  end

end