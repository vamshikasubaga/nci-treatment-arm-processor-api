require 'rails_helper'

describe TreatmentWorker do

  let(:sqs_message) do
    { id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: "message",
      delete: nil }
  end

  let(:body) do
    {
        "id" => "EAY131-A",
        "version" => "2016-02-20"
    }.to_json
  end


  describe '#perform' do

    subject { TreatmentWorker.new }

    it 'should respond to a new message' do
      expect(subject.perform(sqs_message, body)).to be_truthy
    end

    it "should try to insert a new TreatmentArm" do
      allow(TreatmentArm).to receive(:find).and_return([])
      allow(TreatmentArm.new).to receive(:save).and_return(true)
      subject.perform(sqs_message, body)
    end

  end



end