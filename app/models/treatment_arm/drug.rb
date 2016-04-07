require 'mongoid'

  class Drug
    include Mongoid::Document
    include Mongoid::Attributes::Dynamic

    embedded_in :treatmentarm, :inverse_of => :treatment_arm_drugs
    embedded_in :treatmentarm, :inverse_of => :exclusion_drugs

    field :drug_id
    field :name
    field :description
    field :drug_class
    field :pathway
    field :target

  end

