require 'spec_helper'

describe TreatmentArm do

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

  let(:treatment_arm) do
    ba = TreatmentArm.new
    ba.active = true
    ba.name = "TestData"
    ba.stratum_id = "EAY131"
    ba.version = "EAY13102"
    ba.description = "testDescription"
    ba.target_id = "gene"
    ba.target_name = "otherGene"
    ba.gene = "FGHS"
    ba.treatment_arm_status = "OPEN"
    ba.study_id = "EAY131"
    ba.num_patients_assigned = 4
    ba.date_created = "2014-02-30"
    ba.assay_rules = []
    ba.treatment_arm_drugs = []
    ba.diseases = []
    ba.exclusion_drugs = []
    ba.status_log = {}
    ba
  end

  it "should be the correct class type for the variables" do
    stub_client.stub_responses(:describe_table, {
        table: {table_status: "ACTIVE"}
    })
    treatment_arm.configure_client(client: stub_client)
    expect(treatment_arm.name).to be_kind_of(String)
    expect(treatment_arm.version).to be_kind_of(String)
    expect(treatment_arm.description).to be_kind_of(String)
    expect(treatment_arm.target_id).to be_kind_of(String)
    expect(treatment_arm.target_name).to be_kind_of(String)
    expect(treatment_arm.gene).to be_kind_of(String)
    expect(treatment_arm.treatment_arm_status).to be_kind_of(String)
    expect(treatment_arm.num_patients_assigned).to be_kind_of(Integer)
    expect(treatment_arm.study_id).to be_kind_of(String)
    expect(treatment_arm.stratum_id).to be_kind_of(String)
    expect(treatment_arm.assay_rules).to be_kind_of(Array)
    expect(treatment_arm.treatment_arm_drugs).to be_kind_of(Array)
    expect(treatment_arm.diseases).to be_kind_of(Array)
    expect(treatment_arm.exclusion_drugs).to be_kind_of(Array)
    expect(treatment_arm.status_log).to be_kind_of(Hash)
  end

  it "should return the correct values" do
    stub_client.stub_responses(:describe_table, {
        table: {table_status: "ACTIVE"}
    })
    treatment_arm.configure_client(client: stub_client)
    json = {
        :treatment_arm_id => "TestData",
        :version => "EAY13102",
        :study_id => "EAY131",
        :stratum_id => "EAY131",
        :description => "testDescription",
        :target_id => "gene",
        :target_name => "otherGene",
        :gene => "FGHS",
        :treatment_arm_status => "OPEN",
        :num_patients_assigned => 4,
        :date_created => "2014-02-30",
        :assay_rules => [],
        :treatment_arm_drugs => [],
        :diseases => [],
        :exclusion_drugs => [],
        :status_log => {Time.now.to_i.to_s => "OPEN"},
    }
    hash = TreatmentArm.new.convert_models(json)
    from_json_ta = TreatmentArm.new.from_json(hash.to_json)
    expect(treatment_arm.version).to eq(from_json_ta.version)
    expect(treatment_arm.study_id).to eq(from_json_ta.study_id)
    expect(treatment_arm.stratum_id).to eq(from_json_ta.stratum_id)
    expect(treatment_arm.description).to eq(from_json_ta.description)
    expect(treatment_arm.target_id).to eq(from_json_ta.target_id)
    expect(treatment_arm.target_name).to eq(from_json_ta.target_name)
    expect(treatment_arm.gene).to eq(from_json_ta.gene)
    expect(treatment_arm.treatment_arm_status).to eq(from_json_ta.treatment_arm_status)
    expect(treatment_arm.num_patients_assigned).to eq(from_json_ta.num_patients_assigned)
    expect(treatment_arm.assay_rules).to eq(from_json_ta.assay_rules)
    expect(treatment_arm.treatment_arm_drugs).to eq(from_json_ta.treatment_arm_drugs)
    expect(treatment_arm.diseases).to eq(from_json_ta.diseases)
    expect(treatment_arm.exclusion_drugs).to eq(from_json_ta.exclusion_drugs)
    expect(from_json_ta.status_log).to be_truthy
  end

end
