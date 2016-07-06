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
    ba.treatment_arm_status = "CLOSED"
    ba.study_id = "EAY131"
    ba.num_patients_assigned = 4
    ba.date_created = "2014-02-30"
    ba.assay_results = []
    ba.treatment_arm_drugs = []
    ba.variant_report = {}
    ba.exclusion_diseases = []
    ba.inclusion_diseases = []
    ba.exclusion_drugs = []
    ba.pten_results = []
    ba.status_log = {}
    ba
  end

  it "should the correct class type for the variables" do
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
    expect(treatment_arm.study_id).to be_kind_of(String)
    expect(treatment_arm.stratum_id).to be_kind_of(String)

  end

  it "should return the correct values" do
    stub_client.stub_responses(:describe_table, {
        table: {table_status: "ACTIVE"}
    })
    treatment_arm.configure_client(client: stub_client)
    json = {
        :id => "TestData",
        :version => "EAY13102",
        :study_id => "EAY131",
        :stratum_id => "EAY131",
        :description => "testDescription",
        :target_id => "gene",
        :target_name => "otherGene",
        :gene => "FGHS",
        :treatment_arm_status => "CLOSED",
        :num_patients_assigned => 4,
        :date_created => "2014-02-30",
        :assay_results => [],
        :treatment_arm_drugs => [],
        :variant_report => {},
        :exclusion_diseases => [],
        :inclusion_diseases => [],
        :exclusion_drugs => [],
        :pten_results => [],
        :status_log => {},
    }
    hash = TreatmentArm.new.convert_models(json)
    from_json_ta = TreatmentArm.new.from_json(hash.to_json)
    expect(treatment_arm.name).to eq(from_json_ta.name)
    expect(treatment_arm.version).to eq(from_json_ta.version)
    expect(treatment_arm.study_id).to eq(from_json_ta.study_id)
    expect(treatment_arm.stratum_id).to eq(from_json_ta.stratum_id)
    expect(treatment_arm.description).to eq(from_json_ta.description)
    expect(treatment_arm.target_id).to eq(from_json_ta.target_id)
    expect(treatment_arm.target_name).to eq(from_json_ta.target_name)
    expect(treatment_arm.gene).to eq(from_json_ta.gene)
    expect(treatment_arm.treatment_arm_status).to eq(from_json_ta.treatment_arm_status)
    expect(treatment_arm.num_patients_assigned).to eq(from_json_ta.num_patients_assigned)
    expect(treatment_arm.assay_results).to eq(from_json_ta.assay_results)
    expect(treatment_arm.treatment_arm_drugs).to eq(from_json_ta.treatment_arm_drugs)
    expect(treatment_arm.variant_report).to eq(from_json_ta.variant_report)
    expect(treatment_arm.exclusion_diseases).to eq(from_json_ta.exclusion_diseases)
    expect(treatment_arm.inclusion_diseases).to eq(from_json_ta.inclusion_diseases)
    expect(treatment_arm.exclusion_drugs).to eq(from_json_ta.exclusion_drugs)
    expect(treatment_arm.pten_results).to eq(from_json_ta.pten_results)
    expect(treatment_arm.status_log).to eq(from_json_ta.status_log)

  end

end
