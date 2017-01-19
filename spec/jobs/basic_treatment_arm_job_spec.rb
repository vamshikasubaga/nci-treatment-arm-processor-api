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
  treatment_arm_assignment = FactoryGirl.build(:treatment_arm_assignment_event)

  describe '#perform' do
    subject { BasicTreatmentArmJob.new }

    it 'should respond to a new message' do
      treatment_arm_id = treatment_arm.treatment_arm_id
      stratum_id = treatment_arm.stratum_id
      status = treatment_arm_assignment.patient_status
      expect(subject.perform(treatment_arm_id, stratum_id, status )).to be_truthy
    end

    it 'should update the Version & Stratum statistics' do
      status = treatment_arm_assignment.patient_status
      allow(TreatmentArm).to receive(:scan).and_return([treatment_arm])
      expect(subject.update(treatment_arm, status)).to be_truthy
    end
  end
end