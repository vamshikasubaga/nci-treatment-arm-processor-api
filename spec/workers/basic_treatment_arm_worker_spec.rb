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
    ba.num_patients_assigned = 4
    ba.date_created = "2014-02-30"
    ba.treatment_arm_drugs = []
    ba.variant_report = {}
    ba.exclusion_diseases = []
    ba.exclusion_drugs = []
    ba.pten_results = []
    ba.status_log = {}
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

    it 'should accept new queue message and perform update' do
      allow(TreatmentArm).to receive(:scan).and_return([treatment_arm])
      # allow(BasicTreatmentArm).to receive(:find).and_return(basic_treatment_arm)
      expect(subject.perform(sqs_message, body)).to be_truthy
    end

    it 'should accept new queue message and perform insert' do
      allow(TreatmentArm).to receive(:scan).and_return([treatment_arm])
      # allow(BasicTreatmentArm).to receive(:find).and_return("")
      expect(subject.perform(sqs_message, body)).to be_truthy
    end

    it "should try to update a BasicTreatmentArm" do
      allow(TreatmentArm).to receive(:scan).and_return([treatment_arm])
      allow(TreatmentArmPatient).to receive(:scan).and_return(["test"])
      allow(treatment_arm).to receive(:save).and_return(true)
      expect(BasicTreatmentArmWorker.new.update(treatment_arm).to_h).to include({:current_patients=>1,
                                                                       :former_patients=>1,
                                                                       :not_enrolled_patients=>1,
                                                                       :pending_patients=>1})
    end

  end



end