
class TreatmentArm
    include Aws::Record
    include Aws::Record::Query::QueryClassMethods

    # table :name => :treatment_arms_dev, :key => :name, :read_capacity => 5, :write_capacity => 5
    #
    # field :version
    # field :description
    # field :target_id
    # field :target_name
    # field :gene
    # field :treatment_arm_status
    # field :max_patients_allowed, :integer
    # field :num_patients_assigned, :integer
    # field :date_created
    # field :treatment_arm_drugs, :serialized
    # field :variant_report, :serialized
    # field :exclusion_criterias, :serialized
    # field :exclusion_diseases, :serialized
    # field :exclusion_drugs, :serialized
    # field :pten_results, :serialized
    # field :status_log, :serialized

    set_table_name "ta_treatment_arms_dev"

    string_attr :name, hash_key: true
    string_attr :version, range_key: true
    string_attr :description
    string_attr :target_id
    string_attr :target_name
    string_attr :gene
    string_attr :treatment_arm_status
    string_attr :date_created

    integer_attr :max_patients_allowed
    integer_attr :num_patients_assigned

    list_attr :treatment_arm_drugs
    list_attr :variant_report
    list_attr :exclusion_criterias
    list_attr :exclusion_diseases
    list_attr :exclusion_drugs
    list_attr :pten_results
    list_attr :status_log


end

