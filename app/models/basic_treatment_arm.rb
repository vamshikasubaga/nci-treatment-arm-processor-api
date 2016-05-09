
class BasicTreatmentArm
  include Aws::Record

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

