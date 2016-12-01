require 'rails_helper'

describe CogTreatmentJob do

  let(:sqs_message) do
    {
      id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: 'message',
      delete: nil
    }
  end

  let(:body) do
    {
      'treatment_arm_id' => 'EAY131-A',
      'stratumId' => '3',
      'version' => '2016-02-20'
    }
  end

  treatment_arm = FactoryGirl.build(:treatment_arm)
  cog_treatment_arm = FactoryGirl.build(:cog_treatment_arm)

  describe '#perform' do
    subject { CogTreatmentJob.new }
    it 'should respond to a new message' do
      expect(subject.perform()).to be_truthy
    end

    it 'should update the treatment_arm_status from COG' do
      allow(TreatmentArm).to receive(:scan).and_return(treatment_arm)
      expect(subject.update_status(cog_treatment_arm.to_h)).to be_truthy
    end
  end
end
