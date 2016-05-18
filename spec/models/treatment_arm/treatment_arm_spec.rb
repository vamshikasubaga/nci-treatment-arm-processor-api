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
    ba.version = "EAY13102"
    ba.description = "testDescription"
    ba.target_id = "gene"
    ba.target_name = "otherGene"
    ba.gene = "FGHS"
    ba.treatment_arm_status = "CLOSED"
    ba.study_id = "EAY131"
    ba.max_patients_allowed = "32"
    ba.num_patients_assigned = 4
    ba.date_created = "2014-02-30"
    ba.treatment_arm_drugs = []
    ba.variant_report = {}
    ba.exclusion_criterias = []
    ba.exclusion_diseases = []
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
    expect(treatment_arm.date_created).to be_kind_of(String)

    expect(treatment_arm.max_patients_allowed).to be_kind_of(Integer)
    expect(treatment_arm.num_patients_assigned).to be_kind_of(Integer)



  end

end
