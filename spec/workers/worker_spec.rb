require 'spec_helper'

RSpec.describe 'Shoryuken::Worker' do
  let(:sqs_queue) { double 'SQS Queue' }
  let(:queue)     { 'treatment_arm_queue' }
  let(:sqs)         { Aws::SQS::Client.new(stub_responses: true, credentials: credentials) }
  let(:credentials) { Aws::Credentials.new(Rails.application.secrets.aws_access_key_id, Rails.application.secrets.aws_secret_access_key) }

  before do
    allow(Shoryuken::Client).to receive(:queues).with(queue).and_return(sqs_queue)
  end

  describe 'perform_in' do
    it 'delays a message' do
      expect(sqs_queue).to receive(:send_message).with(
        message_attributes: {
          'shoryuken_class' => {
            string_value: QueueWorker.to_s,
            data_type: 'String'
          }
        },
        message_body: 'message',
        delay_seconds: 60)

      QueueWorker.perform_in(60, 'message')
    end
  end
end