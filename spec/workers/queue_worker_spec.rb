require 'spec_helper'

RSpec.describe 'Shoryuken::Worker' do
  let(:sqs_queue) { double 'SQS Queue' }
  let(:queue)     { 'treatment_arm_queue' }
  let(:sqs)         { Aws::SQS::Client.new(stub_responses: true, credentials: credentials) }
  let(:credentials) { Aws::Credentials.new(Rails.application.secrets.aws_access_key_id, Rails.application.secrets.aws_secret_access_key) }
  let(:_sqs_message) do
    {
      id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: "message",
      delete: nil
    }
  end
  message = FactoryGirl.build(:message)

  before do
    allow(Shoryuken::Client).to receive(:queues).with(queue).and_return(sqs_queue)
  end

  describe 'perform_in' do
    subject { QueueWorker.new }
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

    it 'should respond to a new message' do
      expect(subject.perform(_sqs_message, message)).to be_truthy
    end
  end
end