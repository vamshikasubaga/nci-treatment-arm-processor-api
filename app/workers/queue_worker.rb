class QueueWorker
  include Shoryuken::Worker

  shoryuken_options queue: ->{"#{ENV['queue_name']}"}, auto_delete: true


  def perform(_sqs_message, message)
    begin
      message = JSON.parse(message).symbolize_keys!
      processor_key = message.keys.first
      case processor_key
        when :queue_treatment_arm
          p "queue_treatment_arm"
        when :treatment_arm
          TreatmentJob.new.perform(message[processor_key])
        when :patient_assignment
          PatientJob.new.perform(message[processor_key])
        else
          Shoryuken.logger.warn("Message was not recognized.  Please verify it is valid and resend. Message: #{message}")
      end
    rescue => error
      Shoryuken.logger.error("Unable to process #{message} because of #{error}")
    end
  end
end
