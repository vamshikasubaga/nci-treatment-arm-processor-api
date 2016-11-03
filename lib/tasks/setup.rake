
namespace :setup do

  task :before => :environment do
    add_env_variables(Rails.root.join('config', 'environment.yml'))
    add_env_variables(Rails.root.join('config', 'secrets.yml'))
  end

  desc 'List all the table names in environment DB'
  task :list_tables => :before do
    puts list_tables
  end

  table_names = ["assignment", "event", "patient", "shipment", "variant", "variant_report", "specimen", "treatment_arm", "treatment_arm_assignment_event"]

  desc 'Deletes a table'
  task :delete_table => :before do
    args = list_tables;puts args
    STDOUT.puts 'Which table would you like to delete?'
    table_name = STDIN.gets.chomp
    if table_names.include?(table_name)
      puts "========================="
      puts "Deleting #{table_name}..."
      delete_table("NciMatchPatientModels::#{table_name.camelize}".constantize)
    elsif ["treatment_arm", "treatment_arm_assignment_event"].include?(table_name)
      puts "========================="
      puts "Deleting #{table_name}..."
      delete_table(table_name.camelize.constantize)
    else
      puts "The table #{table_name} was not from the list of tables."
    end
  end

  desc 'Clears the table data'
  task :clear_table => :before do
    args = list_tables;puts args
    STDOUT.puts "Which table would you like to clear the data?"
    table_name = STDIN.gets.chomp
    if ["treatment_arm", "treatment_arm_assignment_event"].include?(table_name)
      puts "========================="
      puts "Wiping off #{table_name} table..."
      clear_table(table_name.camelize.constantize)
    else
      puts "========================="
      puts "Wiping off #{table_name} table..."
      clear_table("NciMatchPatientModels::#{table_name.camelize}".constantize)
    end
  end

  desc "Creates all the tables if doesn't exists"
  task :create_table => :before do
    missing_tables = table_names - list_tables
    missing_tables.each do |table_name|
      puts "#{table_name} table is missing. Creating it..."
      if ["treatment_arm", "treatment_arm_assignment_event"].include?(table_name)
        create_table(table_name.camelize)
      else
        create_table("NciMatchPatientModels::#{table_name.camelize}".constantize)
      end
    end
  end

  desc 'Create queue for project'
  task :queue => :before do
    Aws::SQS::Client.new(access_key_id: ENV['aws_access_key_id'],
                         secret_access_key: ENV['aws_secret_access_key'],
                         region: Rails.configuration.environment.fetch('aws_region').create_queue({ queue_name: Rails.configuration.environment.fetch('queue_name') })
                        )
  end

  task :all => [:queue]

  def add_env_variables(env_file)
    if File.exists?(env_file)
      YAML.load_file(env_file)[Rails.env].each do |key, value|
        ENV[key.to_s] = value
      end
    end
  end

  def clear_table(model_class)
    if model_class.table_exists?
      model_class.scan({}).each do |record|
        record.delete!
        puts "Table #{model_class.table_name} has been Wiped off successfully"
      end
    end
  end

  def create_table(model_class)
    unless model_class.table_exists?
      migration = Aws::Record::TableMigration.new(model_class, { client: get_client(Aws::DynamoDB::Client) })
      migration.create!(
        provisioned_throughput:
        {
          read_capacity_units: Rails.configuration.environment.fetch("read_capacity_units").to_i,
          write_capacity_units: Rails.configuration.environment.fetch("write_capacity_units").to_i
        }
      )
      migration.wait_until_available
      puts "#{model_class} table has been created successfully"
    else
      puts "Table #{model_class.table_name} already exists....skipping"
    end
  end

  def delete_table(model_class)
    if model_class.table_exists?
      migration = Aws::Record::TableMigration.new(model_class, { client: get_client(Aws::DynamoDB::Client) })
      migration.delete!
      puts "*** Table #{model_class.table_name} has been deleted successfully ***"
    else
      puts "*** Table #{model_class.table_name} doesn't exist ***"
    end
  end

  def list_tables
    get_client(Aws::DynamoDB::Client).list_tables({}).table_names
  end

  def get_client(client_type)
    client_type.new(endpoint: Rails.configuration.environment.fetch('aws_dynamo_endpoint'),
                    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                    region: Rails.configuration.environment.fetch('aws_region'))
  end
end