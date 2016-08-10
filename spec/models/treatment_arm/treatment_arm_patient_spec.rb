require 'spec_helper'

describe TreatmentArmPatient do

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

  let(:patient_treatment_arm) do
    ba = TreatmentArmPatient.new
    ba.date_assigned = "2012-02-20"
    ba.patient_id = "200re"
    ba.concordance = "Y"
    ba.stratum_id = "EAY131"
    ba.patient_assignment_status = "ON_TREATMENT_ARM"
    ba.date_created = "2013-02-15"
    ba.description = "TestDescription"
    ba.diseases = [{"drug_id" => "1234"}]
    ba.exclusion_criterias = []
    ba.exclusion_diseases = []
    ba.exclusion_drugs = []
    ba.gene = "EADF"
    # ba.max_patients_allowed = "32"
    ba.name = "Test"
    # ba.num_patients_assigned = 0
    ba.patient_assignments = []
    ba.pten_results = []
    ba.target_id = "Cancer"
    ba.target_name = "TEST"
    ba.treatment_arm_drugs = []
    ba.treatment_arm_status = "CLOSED"
    ba.variant_report = []
    ba.version = "2012-02-20"
    ba.status_log = {}
    ba.step_number = 0
    ba
  end

  it "should be the correct class type for the variables" do
    stub_client.stub_responses(:describe_table, {
        table: {table_status: "ACTIVE"}
    })
    patient_treatment_arm.configure_client(client: stub_client)
    expect(patient_treatment_arm.name).to be_kind_of(String)
    expect(patient_treatment_arm.concordance).to be_kind_of(String)
    expect(patient_treatment_arm.patient_id).to be_kind_of(String)
    expect(patient_treatment_arm.patient_assignment_status).to be_kind_of(String)
    expect(patient_treatment_arm.version).to be_kind_of(String)
    expect(patient_treatment_arm.description).to be_kind_of(String)
    expect(patient_treatment_arm.target_id).to be_kind_of(String)
    expect(patient_treatment_arm.target_name).to be_kind_of(String)
    expect(patient_treatment_arm.gene).to be_kind_of(String)
    expect(patient_treatment_arm.treatment_arm_status).to be_kind_of(String)
    expect(patient_treatment_arm.date_created).to be_kind_of(String)
    expect(patient_treatment_arm.diseases).to be_kind_of(Array)
    expect(patient_treatment_arm.exclusion_criterias).to be_kind_of(Array)
    expect(patient_treatment_arm.exclusion_diseases).to be_kind_of(Array)
    expect(patient_treatment_arm.exclusion_drugs).to be_kind_of(Array)
    expect(patient_treatment_arm.patient_assignments).to be_kind_of(Array)
    expect(patient_treatment_arm.pten_results).to be_kind_of(Array)
    expect(patient_treatment_arm.treatment_arm_drugs).to be_kind_of(Array)
    expect(patient_treatment_arm.variant_report).to be_kind_of(Array)
    expect(patient_treatment_arm.status_log).to be_kind_of(Hash)
    expect(patient_treatment_arm.step_number).to be_kind_of(Integer)
  end

  it "should return the correct values" do
    stub_client.stub_responses(:describe_table, {
        table: {table_status: "ACTIVE"}
    })
    patient_treatment_arm.configure_client(client: stub_client)
    json = {
        :patient_id => "200re",
        :date_assigned => "2012-02-20",
        :treatment_arm_name => "Test",
        :stratum_id => "EAY131",
        :version => "2012-02-20",
        :patient_assignment_status => "ON_TREATMENT_ARM"
    }
    hash = TreatmentArmPatient.new.convert_model(json)
    from_json_ta = TreatmentArmPatient.new.from_json(hash.to_json)
    expect(patient_treatment_arm.patient_id).to eq(from_json_ta.patient_id)
    expect(patient_treatment_arm.date_assigned).to eq(from_json_ta.date_assigned)
    expect(patient_treatment_arm.treatment_arm_name).to eq(from_json_ta.treatment_arm_name)
    expect(patient_treatment_arm.stratum_id).to eq(from_json_ta.stratum_id)
    expect(patient_treatment_arm.version).to eq(from_json_ta.version)
    expect(patient_treatment_arm.patient_assignment_status).to eq(from_json_ta.patient_assignment_status)
  end

end