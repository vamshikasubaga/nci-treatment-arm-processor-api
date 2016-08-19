# Module Definition
module ModelConfig
  def self.configure
    configure_table(TreatmentArm)
    ensure_table(TreatmentArm)

    configure_table(TreatmentArmPatient)
    ensure_table(TreatmentArmPatient)
  end

  def self.configure_table(table)
    name = table.new.class.name.underscore
    name = name.to_s.split('/').last || ''
    table.set_table_name name
  end

  def self.ensure_table(table)
    read_capacity_units =  ENV['read_capacity_units'].to_i
    write_capacity_units = ENV['write_capacity_units'].to_i

    unless table.table_exists?
      puts "====== Table [#{table.table_name}] does not exist. Creating the table ======"
      migration = Aws::Record::TableMigration.new(table)
      migration.create!(provisioned_throughput: { read_capacity_units: read_capacity_units,
                                                  write_capacity_units: write_capacity_units })
      migration.wait_until_available
    end
  end
end

ModelConfig.configure
