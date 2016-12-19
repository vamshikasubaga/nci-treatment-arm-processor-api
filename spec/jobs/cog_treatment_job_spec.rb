require 'rails_helper'

describe CogTreatmentJob do

  let(:sqs_message) do
    {
      id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: 'message',
      delete: nil
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

    it 'should rewrite the status log' do
      expected_result = {
        :'1480454602' => 'OPEN'
      }
      actual_result = subject.rewrite_status_log(cog_treatment_arm.to_h[:status_log])
      expect(expected_result).to eq(actual_result)
    end
  end
end
