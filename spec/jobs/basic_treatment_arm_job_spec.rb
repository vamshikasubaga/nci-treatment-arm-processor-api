require 'rails_helper'

describe BasicTreatmentArmJob do

  let(:sqs_message) do
    {
      id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: "message",
      delete: nil
    }
  end

  treatment_arm = FactoryGirl.build(:treatment_arm)

  describe '#perform' do
    subject { BasicTreatmentArmJob.new }

    it 'should respond to a new message' do
      treatment_arm_id = treatment_arm.treatment_arm_id
      stratum_id = treatment_arm.stratum_id
      expect(subject.perform(treatment_arm_id, stratum_id)).to be_truthy
    end

    it 'should update the Version & Stratum statistics' do
      allow(TreatmentArm).to receive(:scan).and_return([treatment_arm])
      expect(subject.update(treatment_arm)).to be_truthy
    end
  end
end