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
    ba.treatment_arm_name_version = "2012-02-20"
    ba.patient_sequence_number = "200re"
    ba.concordance = "Y"
    ba.current_patient_status = "ON_TREATMENT_ARM"
    ba.date_created = "2013-02-15"
    ba.description = "TestDescription"
    ba.diseases = [{"drug_id" => "1234"}]
    ba.exclusion_criterias = []
    ba.exclusion_diseases = []
    ba.exclusion_drugs = []
    ba.gene = "EADF"
    ba.max_patients_allowed = "32"
    ba.name = "Test"
    ba.num_patients_assigned = 0
    ba.patient_assignments = []
    ba.pten_results = []
    ba.target_id = "Cancer"
    ba.target_name = "TEST"
    ba.treatment_arm_drugs = []
    ba.treatment_arm_status = "CLOSED"
    ba.variant_report = []
    ba.version = "2012-02-20"
    ba.status_log = {}
    ba.current_step_number = 0
    ba
  end

  it "should the correct class type for the variables" do
    stub_client.stub_responses(:describe_table, {
        table: {table_status: "ACTIVE"}
    })
    patient_treatment_arm.configure_client(client: stub_client)
    expect(patient_treatment_arm.name).to be_kind_of(String)
    expect(patient_treatment_arm.concordance).to be_kind_of(String)
    expect(patient_treatment_arm.current_patient_status).to be_kind_of(String)
    expect(patient_treatment_arm.version).to be_kind_of(String)
    expect(patient_treatment_arm.description).to be_kind_of(String)
    expect(patient_treatment_arm.target_id).to be_kind_of(String)
    expect(patient_treatment_arm.target_name).to be_kind_of(String)
    expect(patient_treatment_arm.gene).to be_kind_of(String)
    expect(patient_treatment_arm.treatment_arm_status).to be_kind_of(String)
    expect(patient_treatment_arm.date_created).to be_kind_of(String)

    expect(patient_treatment_arm.max_patients_allowed).to be_kind_of(Integer)
    expect(patient_treatment_arm.num_patients_assigned).to be_kind_of(Integer)



  end

end