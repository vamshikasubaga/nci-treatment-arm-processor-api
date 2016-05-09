
class BasicTreatmentArm
  include Aws::Record

  # table :name => :basic_treatment_arm_dev, :key => :treatment_arm_id, :read_capacity => 10, :write_capacity => 10
  # field :treatment_arm_id
  # field :treatment_arm_name
  # field :current_patients
  # field :former_patients
  # field :not_enrolled_patients
  # field :pending_patients
  # field :treatment_arm_status
  # field :date_created, :datetime
  # field :date_opened, :datetime
  # field :date_closed, :datetime
  # field :date_suspended, :datetime

  set_table_name "ta_basic_treatment_arm_dev"

  string_attr :treatment_arm_id, hash_key: true
  string_attr :description
  string_attr :treatment_arm_status
  string_attr :date_created
  string_attr :date_opened

  integer_attr :current_patients
  integer_attr :former_patients
  integer_attr :not_enrolled_patients
  integer_attr :pending_patients


end

