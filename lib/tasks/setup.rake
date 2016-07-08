
namespace :setup do

  task :before => :environment do
    add_env_variables(Rails.root.join('config', 'environment.yml'))
    add_env_variables(Rails.root.join('config', 'secrets.yml'))
  end

  task :treatment_arm => :before do
     create_table(TreatmentArm)
  end

  task :treatment_arm_patient => :before do
    create_table(TreatmentArmPatient)
  end

  desc "Create tables for DB"
  task :db => [:treatment_arm, :treatment_arm_patient]


  def add_env_variables(env_file)
    if File.exists?(env_file)
      YAML.load_file(env_file)[Rails.env].each do |key, value|
        ENV[key.to_s] = value
      end
    end
  end

  def create_table(model_class)
    migration = Aws::Record::TableMigration.new(model_class,
                                                {:client => Aws::DynamoDB::Client.new(endpoint: ENV["aws_dynamo_endpoint"],
                                                                                                   access_key_id: ENV["aws_access_key_id"],
                                                                                                   secret_access_key: ENV["aws_secret_access_key"],
                                                                                                   region: ENV["aws_region"])})
    migration.create!(
        provisioned_throughput: {
            read_capacity_units: 10,
            write_capacity_units: 10
        }
    )
    migration.wait_until_available
  end

end