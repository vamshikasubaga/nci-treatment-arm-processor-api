require 'rails_helper'

describe TreatmentJob do

  let(:sqs_message) do
    { id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e',
      body: 'message',
      delete: nil }
  end

  let(:body) do
    {
      'treatment_arm_id' => 'EAY131-A',
      'stratumId' => '3',
      'version' => '2016-02-20'
    }
  end

  treatment_arm = FactoryGirl.build(:treatment_arm)
  old_treatment_arm = FactoryGirl.build(:treatment_arm)
  new_treatment_arm_hash = TreatmentArm.build_cloned(treatment_arm.to_h)

  describe '#perform' do
    subject { TreatmentJob.new }
    it 'should respond to a new message' do
      allow(TreatmentArm).to receive(:find).and_return([])
      allow(TreatmentArm.new).to receive(:save).and_return(true)
      expect(subject.perform(body)).to be_truthy
    end

    it 'should try to insert a new TreatmentArm' do
      allow(TreatmentArm).to receive(:new).and_return(treatment_arm)
      allow(treatment_arm).to receive(:save).and_return(true)
      expect(subject.insert(treatment_arm.to_h)).to be_truthy
    end

    it 'should insert a new version of the TreatmentArm' do
      allow(TreatmentArm).to receive(:scan).and_return(treatment_arm)
      allow(treatment_arm).to receive(:save).and_return(true)
      expect{ (subject.insert_new_version(new_treatment_arm_hash, treatment_arm)) }.to_not raise_error
    end

    it 'should try to insert a new TreatmentArm' do
      allow(TreatmentArm).to receive(:new).and_return(treatment_arm)
      allow(treatment_arm).to receive(:save).and_raise('Unable to save')
      expect(subject.insert(treatment_arm.to_h)).to be_truthy
    end

    it 'should convert json to the given model' do
      expect(TreatmentArm.new.convert_models({})).to be_truthy
      expect(TreatmentArm.new.convert_models({ treatment_arm_id: 'EAY131-A',
                                               version: 'testVersion',
                                               description: 'testDiscription',
                                               target_id: '',
                                               target_name: 'GENE'
                                             })).to include({ treatment_arm_id: 'EAY131-A', version: 'testVersion', description: 'testDiscription', target_name: 'GENE' })
    end

    it 'should remove empty strings from json' do
      expected_results = [
        {
          'drug_id' => '763093',
          'name' => 'Trametinib',
          'pathway' => 'B-RAF inhibitor',
          'target' => 'B-RAF'
        },
        {
          'drug_id' => '763760'
        },
        {
          'name' => 'Trametinib'
        },
        {
          'drug_id' => '763093',
          'name' => 'Trametinib',
          'target' => 'B-RAF'
        }
      ]
      expect(subject.remove_blank_document(treatment_arm.to_h)[:exclusion_drugs]).to eq(expected_results)
    end

    it 'should set active to false' do
      allow(TreatmentArm).to receive(:new).and_return(old_treatment_arm)
      allow(old_treatment_arm).to receive(:save).and_return(true)
      subject.deactivate(old_treatment_arm)
      expect(old_treatment_arm.active).to eq(false)
    end

    it 'should clone treatment arm hash' do
      matching_keys = [:active, :treatment_arm_id, :name, :version]
      missingkeys = [:former_patients, :not_enrolled_patients, :pending_patients, :version_current_patients,
                     :version_former_patients, :version_not_enrolled_patients, :version_pending_patients]
      expect(new_treatment_arm_hash.slice(matching_keys)).to eq(treatment_arm.to_h.slice(matching_keys))
      expect(new_treatment_arm_hash.slice(missingkeys)).to be_empty
    end
  end
end
