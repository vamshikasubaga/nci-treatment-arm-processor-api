require 'mongoid'

  class Drug
    include Mongoid::Document
    include Mongoid::Attributes::Dynamic

    embedded_in :treatmentarm, :inverse_of => :treatmentArmDrugs
    embedded_in :treatmentarm, :inverse_of => :exclusionDrugs

    field :drugId
    field :name
    field :description
    field :drugClass
    field :pathway
    field :target

  end

