require 'rails_helper'

describe TreatmentJob do

  let(:sqs_message) do
    { id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: "message",
      delete: nil }
  end

  let(:body) do
    {
      "id" => "EAY131-A",
      "stratumId" => "3",
      "version" => "2016-02-20"
    }.to_json
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
    ba.num_patients_assigned = 4
    ba.date_created = "2014-02-30"
    ba.treatment_arm_drugs = []
    ba.variant_report = {}
    ba.exclusion_diseases = []
    ba.exclusion_drugs = [
            {"drug_id"=> "763093",
             "name" => "Trametinib",
             "pathway" => "B-RAF inhibitor",
             "target" => "B-RAF"
            },
            {"drug_id" => "763760",
             "name" => ""
            },
            {"drug_id" => "",
             "name" => "Trametinib"
            },
            {"drug_id"=> "763093",
             "name" => "Trametinib",
             "pathway" => "",
             "target" => "B-RAF"
            }
    ]
    ba.pten_results = []
    ba.status_log = {}
    ba
  end

  describe '#perform' do

    subject { TreatmentJob.new }

    it 'should respond to a new message' do
      allow(TreatmentArm).to receive(:find).and_return([])
      allow(TreatmentArm.new).to receive(:save).and_return(true)
      expect(subject.perform(body)).to be_truthy
    end

    it "should try to insert a new TreatmentArm" do
      allow(TreatmentArm).to receive(:new).and_return(treatment_arm)
      allow(treatment_arm).to receive(:save).and_return(true)
      expect(subject.insert(treatment_arm.to_h)).to be_truthy
    end

    it "should try to insert a new TreatmentArm" do
      allow(TreatmentArm).to receive(:new).and_return(treatment_arm)
      allow(treatment_arm).to receive(:save).and_raise("Unable to save")
      expect(subject.insert(treatment_arm.to_h)).to be_truthy
    end

    it "should convert json to the given model" do
      expect(TreatmentArm.new.convert_models({})).to be_truthy
      expect(TreatmentArm.new.convert_models({ :id => "EAY131-A",
                              :version => "testVersion",
                              :description => "testDiscription",
                              :target_id => "",
                              :target_name => "GENE"
                            })).to include({:name=>"EAY131-A", :version=>"testVersion", :description=>"testDiscription", :target_name=>"GENE"})
    end

    it "should remove empty strings from json" do
      expected_results = [
              {"drug_id"=>"763093",
               "name"=>"Trametinib",
               "pathway"=>"B-RAF inhibitor",
               "target"=>"B-RAF"
              },
              {"drug_id"=>"763760",
              },
              {"name"=>"Trametinib"
              },
              {"drug_id"=>"763093",
               "name" =>"Trametinib",
               "target" =>"B-RAF"
              }
      ]
      expect(subject.remove_blank_document(treatment_arm.to_h)[:exclusion_drugs]).to eq(expected_results)
    end
  end

end