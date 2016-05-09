
class TreatmentArm
    include Dynamoid::Document

    table :name => :treatment_arms_dev, :key => :name, :read_capacity => 5, :write_capacity => 5

    field :version
    field :description
    field :target_id
    field :target_name
    field :gene
    field :treatment_arm_status
    field :max_patients_allowed, :integer
    field :num_patients_assigned, :integer
    field :date_created
    field :treatment_arm_drugs, :serialized
    field :variant_report, :serialized
    field :exclusion_criterias, :serialized
    field :exclusion_diseases, :serialized
    field :exclusion_drugs, :serialized
    field :pten_results, :serialized
    field :status_log, :serialized


  end

