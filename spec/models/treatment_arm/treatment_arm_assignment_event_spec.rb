require 'spec_helper'

describe TreatmentArmAssignmentEvent do
  let(:api_requests) { [] }

  let(:stub_client) do
    requests = api_requests
    client = Aws::DynamoDB::Client.new(stub_responses: true)
    client.handle do |context|
      requests << context.params
      @handler.call(context)
    end
    client
  end

  treatment_arm_assignment = FactoryGirl.build(:treatment_arm_assignment_event)

  it 'has a valid factory' do
    expect(treatment_arm_assignment).to be_truthy
  end

  it 'should be the correct class type for the variables' do
    stub_client.stub_responses(:describe_table, table: { table_status: 'ACTIVE' })
    treatment_arm_assignment.configure_client(client: stub_client)
    expect(treatment_arm_assignment.treatment_arm_id).to be_kind_of(String)
    expect(treatment_arm_assignment.assignment_date).to be_kind_of(Date)
    expect(treatment_arm_assignment.date_off_arm).to be_kind_of(Date)
    expect(treatment_arm_assignment.date_on_arm).to be_kind_of(Date)
    expect(treatment_arm_assignment.patient_id).to be_kind_of(String)
    expect(treatment_arm_assignment.version).to be_kind_of(String)
    expect(treatment_arm_assignment.analysis_id).to be_kind_of(String)
    expect(treatment_arm_assignment.molecular_id).to be_kind_of(String)
    expect(treatment_arm_assignment.surgical_event_id).to be_kind_of(String)
    expect(treatment_arm_assignment.step_number).to be_kind_of(String)
    expect(treatment_arm_assignment.diseases).to be_kind_of(Array)
    expect(treatment_arm_assignment.assignment_reason).to be_kind_of(String)
    expect(treatment_arm_assignment.patient_status).to be_kind_of(String)
  end

  it 'should return the correct values' do
    stub_client.stub_responses(:describe_table, table: { table_status: 'ACTIVE' })
    treatment_arm_assignment.configure_client(client: stub_client)
    json = {
             patient_id: '200re',
             treatment_arm_name: 'Test',
             stratum_id: 'EAY131',
             version: '2012-02-20',
             patient_status: 'PENDING'
           }
    hash = TreatmentArmAssignmentEvent.new.convert_model(json)
    from_json_ta = TreatmentArmAssignmentEvent.new.from_json(hash.to_json)
    expect(treatment_arm_assignment.patient_id).to eq(from_json_ta.patient_id)
    expect(treatment_arm_assignment.stratum_id).to eq(from_json_ta.stratum_id)
    expect(treatment_arm_assignment.version).to eq(from_json_ta.version)
  end

  it 'should be of the correct instance' do
    treatment_arm_assignment = TreatmentArmAssignmentEvent.new
    expect(treatment_arm_assignment).to be_an_instance_of(TreatmentArmAssignmentEvent)
  end

  it 'automatically declares patient_id' do
    expect { treatment_arm_assignment.patient_id }.to_not raise_error
  end

  it 'should be valid when an instance is created' do
    expect(TreatmentArmAssignmentEvent.new).to be_truthy
  end

  it 'should be valid with valid attributes' do
    treatment_arm_assignment = TreatmentArmAssignmentEvent.new(patient_id: '200re', stratum_id: 'EAY131', version: '2012-02-20')
    expect(treatment_arm_assignment).to be_truthy
  end
end
