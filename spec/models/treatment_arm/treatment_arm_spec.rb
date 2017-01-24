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

  let(:record) do
    Class.new do
      include(Aws::Record)
      set_table_name('treatment_arm')
      string_attr(:treatment_arm_id, hash_key: true)
      string_attr(:date_created, range_key: true)
      string_attr(:description)
      string_attr(:stratum_id)
      string_attr(:version)
      string_attr(:name)
      list_attr(:treatment_arm_drugs, default_value: [])
      list_attr(:snv_indels, persist_nil: true)
      list_attr(:copy_number_variants)
      map_attr(:status_log, default_value: {})
      boolean_attr(:active, database_attribute_name: 'is_active_flag')
    end
  end

  treatment_arm = FactoryGirl.build(:treatment_arm)

  it 'has a valid factory' do
    expect(treatment_arm).to be_truthy
  end

  it 'should be the correct class type for the variables' do
    stub_client.stub_responses(:describe_table, table: { table_status: 'ACTIVE' })
    treatment_arm.configure_client(client: stub_client)
    expect(treatment_arm.name).to be_kind_of(String)
    expect(treatment_arm.treatment_arm_id).to be_kind_of(String)
    expect(treatment_arm.version).to be_kind_of(String)
    expect(treatment_arm.description).to be_kind_of(String)
    expect(treatment_arm.target_id).to be_kind_of(String)
    expect(treatment_arm.target_name).to be_kind_of(String)
    expect(treatment_arm.gene).to be_kind_of(String)
    expect(treatment_arm.treatment_arm_status).to be_kind_of(String)
    expect(treatment_arm.num_patients_assigned).to be_kind_of(Integer)
    expect(treatment_arm.treatment_arm_id).to be_kind_of(String)
    expect(treatment_arm.study_id).to be_kind_of(String)
    expect(treatment_arm.stratum_id).to be_kind_of(String)
    expect(treatment_arm.assay_rules).to be_kind_of(Array)
    expect(treatment_arm.treatment_arm_drugs).to be_kind_of(Array)
    expect(treatment_arm.diseases).to be_kind_of(Array)
    expect(treatment_arm.exclusion_drugs).to be_kind_of(Array)
    expect(treatment_arm.gene_fusions).to be_kind_of(Array)
    expect(treatment_arm.snv_indels).to be_kind_of(Array)
    expect(treatment_arm.non_hotspot_rules).to be_kind_of(Array)
    expect(treatment_arm.copy_number_variants).to be_kind_of(Array)
    expect(treatment_arm.date_created).to be_kind_of(String)
    expect(treatment_arm.date_opened).to be_kind_of(String)
  end

  it 'should be the correct class type for the version and stratum statistics' do
    expect(treatment_arm.not_enrolled_patients).to be_kind_of(Integer)
    expect(treatment_arm.former_patients).to be_kind_of(Integer)
    expect(treatment_arm.pending_patients).to be_kind_of(Integer)
    expect(treatment_arm.current_patients).to be_kind_of(Integer)
    expect(treatment_arm.version_pending_patients).to be_kind_of(Integer)
    expect(treatment_arm.version_former_patients).to be_kind_of(Integer)
    expect(treatment_arm.version_current_patients).to be_kind_of(Integer)
    expect(treatment_arm.version_not_enrolled_patients).to be_kind_of(Integer)
  end

  it 'should return the correct class type for the Boolean attribute' do
    expect(treatment_arm.active).to be_kind_of(TrueClass)
    treatment_arm.active = false
    expect(treatment_arm.active).to be_kind_of(FalseClass)
  end

  it 'should return the correct values' do
    stub_client.stub_responses(:describe_table, table: { table_status: 'ACTIVE' })
    treatment_arm.configure_client(client: stub_client)
    json = {
             treatment_arm_id: 'APEC1621-A',
             version: '2016-20-02',
             study_id: 'APEC1621',
             stratum_id: '12',
             description: 'This is the sample Description',
             target_id: 'HDFD',
             target_name: 'Crizotinib',
             gene: 'GENE',
             treatment_arm_status: 'OPEN',
             num_patients_assigned: 2,
             date_created: '2014-02-30',
             assay_rules: [],
             treatment_arm_drugs: [],
             diseases: [],
             exclusion_drugs: [
               {
                 'drug_id' => '763093',
                 'name' => 'Trametinib',
                 'pathway' => 'B-RAF inhibitor',
                 'target' => 'B-RAF'
               },
               {
                 'drug_id' => '763760',
                 'name' => ''
               },
               {
                 'drug_id' => '',
                 'name' => 'Trametinib'
               },
               {
                 'drug_id' => '763093',
                 'name' => 'Trametinib',
                 'pathway' => '',
                 'target' => 'B-RAF'
               }
             ],
             gene_fusions: [],
             snv_indels: [],
             copy_number_variants: [],
             non_hotspot_rules: [],
             status_log: { Time.now.to_i.to_s => 'OPEN' }
          }

    hash = TreatmentArm.new.convert_models(json)
    from_json_ta = TreatmentArm.new.from_json(hash.to_json)
    expect(treatment_arm.treatment_arm_id).to eq(from_json_ta.treatment_arm_id)
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
    expect(from_json_ta.status_log).to be_truthy
    expect(treatment_arm.snv_indels).to eq(from_json_ta.snv_indels)
    expect(treatment_arm.non_hotspot_rules).to eq(from_json_ta.non_hotspot_rules)
    expect(treatment_arm.copy_number_variants).to eq(from_json_ta.copy_number_variants)
    expect(treatment_arm.gene_fusions).to eq(from_json_ta.gene_fusions)
  end

  it 'automatically declares treatment_arm_id' do
    expect { treatment_arm.treatment_arm_id }.to_not raise_error
  end

  it 'should be valid when an instance is created' do
    expect(TreatmentArm.new).to be_truthy
  end

  it 'should be valid with valid attributes' do
    treatment_arm = TreatmentArm.new(treatment_arm_id: 'APEC1621', stratum_id: 'EAY131', version: 'EAY13102')
    expect(treatment_arm).to be_truthy
  end

  it 'should be of the correct instance' do
    treatment_arm = TreatmentArm.new
    expect(treatment_arm).to be_an_instance_of(TreatmentArm)
  end

  it 'raises an error when you try to save! without setting keys' do
    record.configure_client(client: stub_client)
    no_keys = record.new
    expect { no_keys.save! }.to raise_error(Aws::Record::Errors::KeyMissing, 'Missing required keys: treatment_arm_id, date_created')
    no_hash = record.new
    no_hash.date_created = '2015-12-15'
    expect { no_hash.save! }.to raise_error(Aws::Record::Errors::KeyMissing, 'Missing required keys: treatment_arm_id')
    no_range = record.new
    no_range.treatment_arm_id = 5
    expect { no_range.save! }.to raise_error(Aws::Record::Errors::KeyMissing, 'Missing required keys: date_created')
    expect(api_requests).to eq([])
  end

  it 'enforces that the required keys are present' do
    record.configure_client(client: stub_client)
    find_opts = { treatment_arm_id: 'APEC1621-A' }
    expect { record.find(find_opts) }.to raise_error(Aws::Record::Errors::KeyMissing)
  end

  it 'raises if any key attributes are missing' do
    record.configure_client(client: stub_client)
    update_opts = { treatment_arm_id: 'APEC1621-A', description: 'This is sample description' }
    expect { record.update(update_opts) }.to raise_error(Aws::Record::Errors::KeyMissing)
  end

  describe 'Attributes' do
    let(:record) do
      Class.new do
        include(Aws::Record)
      end
    end

    describe '#initialize' do
      let(:model) do
        Class.new do
          include(Aws::Record)
          string_attr(:treatment_arm_id, hash_key: true)
          string_attr(:stratum_id)
          string_attr(:version)
        end
      end

      it 'should allow attribute assignment at item creation time' do
        item = model.new(treatment_arm_id: 'APEC1621-A')
        expect(item.treatment_arm_id).to eq('APEC1621-A')
        expect(item.stratum_id).to be_nil
      end

      it 'should allow assignment of multiple attributes at item creation' do
        item = model.new(treatment_arm_id: 'APEC1621-A', stratum_id: '100', version: '2015-08-06')
        expect(item.treatment_arm_id).to eq('APEC1621-A')
        expect(item.stratum_id).to eq('100')
        expect(item.version).to eq('2015-08-06')
      end
    end

    describe 'Keys' do
      it 'should be able to assign a hash key' do
        record.string_attr(:treatment_arm_id, hash_key: true)
        expect(record.hash_key).to eq(:treatment_arm_id)
      end

      it 'should be able to assign a hash and range key' do
        record.string_attr(:treatment_arm_id, hash_key: true)
        record.string_attr(:date_created, range_key: true)
        expect(record.hash_key).to eq(:treatment_arm_id)
        expect(record.range_key).to eq(:date_created)
      end

      it 'should reject assigning the same attribute as hash and range key' do
        expect { record.string_attr(:treatment_arm_id, hash_key: true, range_key: true) }.to raise_error(ArgumentError)
      end
    end

    describe 'Attributes' do
      it 'should create dynamic methods around attributes' do
        record.string_attr(:description)
        x = record.new
        x.description = 'This is the sample Description'
        expect(x.description).to eq('This is the sample Description')
      end

      it 'should reject non-symbolized attribute names' do
        expect { record.integer_attr('integer') }.to raise_error(ArgumentError)
      end

      it 'rejects collisions of db storage names with existing attr names' do
        record.boolean_attr(:active, database_attribute_name: 'is_active_flag')
        expect { record.boolean_attr(:fail, database_attribute_name: 'active') }.to raise_error(Aws::Record::Errors::NameCollision)
      end

      it 'rejects collisions of attr names with existing db storage names' do
        record.boolean_attr(:active, database_attribute_name: 'is_active_flag')
        expect { record.boolean_attr(:is_active_flag, database_attribute_name: 'fail') }.to raise_error(Aws::Record::Errors::NameCollision)
      end

      it 'should not allow duplicate assignment of the same attr name' do
        record.string_attr(:target_name)
        expect { record.datetime_attr(:target_name) }.to raise_error(Aws::Record::Errors::NameCollision)
      end

      it 'should typecast an integer attribute' do
        record.integer_attr(:num_patients_assigned)
        x = record.new
        x.num_patients_assigned = '5'
        expect(x.num_patients_assigned).to eq(5)
      end

      it 'should display a hash representation of attribute raw values' do
        record.string_attr(:status_log)
        x = record.new
        x.status_log = '{"1479236708": "OPEN"}'
        expect(x.to_h).to eq(status_log: '{"1479236708": "OPEN"}')
      end

      it 'should allow specification of a separate storage attribute name' do
        record.string_attr(:active, database_attribute_name: 'is_active_flag')
        record.string_attr(:name)
        expect(record.attributes.storage_name_for(:active)).to eq('is_active_flag')
        expect(record.attributes.storage_name_for(:name)).to eq('name')
      end

      it 'should reject storage name collisions' do
        record.string_attr(:active, database_attribute_name: 'is_active_flag')
        expect { record.string_attr(:is_active_flag) }.to raise_error(Aws::Record::Errors::NameCollision)
        expect(record.attributes.present?(:is_active_flag)).to be_falsy
      end

      it 'should enforce uniqueness of storage names' do
        record.string_attr(:active, database_attribute_name: 'is_active_flag')
        expect { record.string_attr(:treatment_arm_id, database_attribute_name: 'is_active_flag') }.to raise_error(Aws::Record::Errors::NameCollision)
      end

      it 'should not allow collisions with reserved names' do
        expect { record.string_attr(:to_h) }.to raise_error(Aws::Record::Errors::ReservedName)
      end

      it 'should allow reserved names to be used as custom storage names' do
        record.string_attr(:active, database_attribute_name: 'is_active_flag')
        item = record.new
        item.active = true
        expect(item.to_h).to eq(active: true)
      end
    end
  end
end
