require 'rails_helper'

describe PatientJob do

  let(:sqs_message) do
    {
      id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: 'message',
      delete: nil
    }
  end

  patient_assignment = FactoryGirl.build(:treatment_arm_assignment_event)
  new_patient_assignment = FactoryGirl.build(:updated_treatment_arm_assignment_event)

  describe '#perform' do

    subject { PatientJob.new }

    it 'should try to insert a new Patient Assignment' do
      allow(TreatmentArmAssignmentEvent).to receive(:new).and_return(patient_assignment)
      allow(patient_assignment).to receive(:save).and_return(true)
      expect(subject.insert(patient_assignment.to_h)).to be_truthy
    end

    it 'should not raise an error while inserting a new Patient Assignment' do
      allow(TreatmentArmAssignmentEvent).to receive(:new).and_return(patient_assignment)
      allow(patient_assignment).to receive(:save).and_raise('Unable to save')
      expect(subject.insert(patient_assignment.to_h)).to be_truthy
    end

    it 'should try to update an existing Patient Assignment' do
      allow(TreatmentArmAssignmentEvent).to receive(:scan).and_return(patient_assignment)
      allow(new_patient_assignment).to receive(:save).and_return(true)
      expect(subject.insert(new_patient_assignment.to_h)).to be_truthy
    end
  end

  # describe 'Assess Patient Status' do
  #   it 'should identify the event and the status correctly' do
  #     event = TreatmentArmAssignmentEvent::FORMER_PATIENT
  #     status = 'REQUEST_ASSIGNMENT'
  #     expect(subject.send(assess_patient_status(event, status))).to eq('PREVIOUSLY_ON_ARM')
  #   end
  # end
end
