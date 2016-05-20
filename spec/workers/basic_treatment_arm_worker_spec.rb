require 'rails_helper'


describe BasicTreatmentArmWorker do

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

  let(:basic_treatment_arm) do
    ba = BasicTreatmentArm.new
    ba.treatment_arm_id = "EAY131-A"
    ba.description = "TestDescription"
    ba.treatment_arm_status = "OPEN"
    ba.date_created = "2016-01-11"
    ba.date_opened = "2016-03-20"
    ba.current_patients = 0
    ba.former_patients = 3
    ba.not_enrolled_patients = 2
    ba.pending_patients = "1"
    ba
  end

  let(:sqs_message) do
    { id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: "message",
      delete: nil }
  end

  let(:body) do
    {
        "id" => "BasicTreatmentArm"
    }
  end


  describe '#perform' do

    subject { BasicTreatmentArmWorker.new }

    it 'should respond to a new message' do
      expect(subject.perform(sqs_message, body)).to be_truthy
    end

    it "should try to update a BasicTreatmentArm" do
      allow(BasicTreatmentArm).to receive(:find).and_return(basic_treatment_arm)
      allow(TreatmentArmPatient).to receive(:scan).and_return(["test"])
      allow(basic_treatment_arm).to receive(:save).and_return(true)
      expect(BasicTreatmentArmWorker.new.update(treatment_arm).to_h).to eq({:treatment_arm_id=>"TestData",
                                                                       :description=>"testDescription",
                                                                       :treatment_arm_status=>"CLOSED",
                                                                       :date_created=>"2014-02-30",
                                                                       :date_opened=>"2016-03-20",
                                                                       :current_patients=>1,
                                                                       :former_patients=>1,
                                                                       :not_enrolled_patients=>1,
                                                                       :pending_patients=>1})
    end

    it "should try to insert a new TreatmentArm" do
      allow(BasicTreatmentArm).to receive(:new).and_return(basic_treatment_arm)
      allow(basic_treatment_arm).to receive(:save).and_return(true)
      expect(BasicTreatmentArmWorker.new.insert(treatment_arm).to_h).to eq({:treatment_arm_id=>"TestData",
                                                                            :description=>"testDescription",
                                                                            :treatment_arm_status=>"CLOSED",
                                                                            :date_created=>"2014-02-30",
                                                                            :date_opened=>"2016-03-20",
                                                                            :current_patients=>0,
                                                                            :former_patients=>0,
                                                                            :not_enrolled_patients=>0,
                                                                            :pending_patients=>0})
    end

    it "should find distinct treatment_arms" do
      expect(BasicTreatmentArmWorker.new.find_distinct_treatment_arms([treatment_arm, treatment_arm, treatment_arm]).length).to eq(1)
    end

  end



end