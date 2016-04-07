require 'mongoid'

  class ExclusionCriteria
    include Mongoid::Document

    embedded_in :treatmentarm, inverse_of: :exclusion_criterias

    field :id
    field :description

  end
