require 'rails_helper'

describe PatientAssignmentJob do

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
    subject { PatientAssignmentJob.new }

    it 'should respond to a new message' do
      allow(TreatmentArmAssignmentEvent).to receive(:find).and_return([])
      expect(subject.perform(patient_assignment)).to be_truthy
    end

    it 'should try to store a Patient Assignment' do
      allow(TreatmentArmAssignmentEvent).to receive(:new).and_return([])
      allow(patient_assignment).to receive(:save).and_return(true)
      expect(subject.store_patient(patient_assignment.to_h)).to be_truthy
    end

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
      expect(subject.update(patient_assignment, new_patient_assignment.to_h)).to be_truthy
    end

    it 'should convert json to the given model' do
      expect(TreatmentArmAssignmentEvent.new.convert_model({})).to be_truthy
      expect(TreatmentArmAssignmentEvent.new.convert_model({ treatment_arm_id: 'EAY131-A',
                                                             version: 'testVersion',
                                                             stratum_id: '100',
                                                             patient_id: '3366'
                                                           })).to include({ treatment_arm_id: 'EAY131-A', version: 'testVersion', stratum_id: '100', patient_id: '3366' })
    end
  end

  describe 'testing event' do
    it 'should identify the event correctly' do
      treatment_arm_assignment = TreatmentArmAssignmentEvent.new
      event = 'EVENT_INIT'
      next_state = 'PENDING_APPROVAL'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('PENDING_PATIENT')

      event = 'EVENT_INIT'
      next_state = 'OFF_STUDY'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('NOT_ENROLLED')

      event = 'PENDING_PATIENT'
      next_state = 'OFF_STUDY'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('NOT_ENROLLED')

      event = 'PENDING_PATIENT'
      next_state = 'ON_TREATMENT_ARM'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('CURRENT_PATIENT')

      event = 'CURRENT_PATIENT'
      next_state = 'OFF_STUDY'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('FORMER_PATIENT')

      event = 'CURRENT_PATIENT'
      next_state = 'REQUEST_ASSIGNMENT'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('FORMER_PATIENT')

      event = 'CURRENT_PATIENT'
      next_state = 'REQUEST_NO_ASSIGNMENT'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('FORMER_PATIENT')

      event = 'CURRENT_PATIENT'
      next_state = 'OFF_STUDY_BIOPSY_EXPIRED'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('FORMER_PATIENT')

      event = 'PENDING_PATIENT'
      next_state = 'OFF_STUDY_BIOPSY_EXPIRED'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('NOT_ENROLLED')

      event = 'PENDING_PATIENT'
      next_state = 'OFF_STUDY'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('NOT_ENROLLED')

      event = 'PENDING_PATIENT'
      next_state = 'REQUEST_ASSIGNMENT'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('NOT_ENROLLED')

      event = 'PENDING_PATIENT'
      next_state = 'REQUEST_NO_ASSIGNMENT'
      expect(treatment_arm_assignment.next_event(event, next_state)).to eq('NOT_ENROLLED')
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
