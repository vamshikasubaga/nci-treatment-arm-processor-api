require 'mongoid'

  class ExclusionCriteria
    include Mongoid::Document

    embedded_in :treatmentarm, inverse_of: :exclusionCriterias

    field :id
    field :description

  end
