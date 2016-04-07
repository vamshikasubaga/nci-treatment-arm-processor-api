require 'mongoid'

  class ExclusionVariant
    include Mongoid::Document

    field :gene
    field :id
    field :type
    field :description
    field :level_of_evidence, type: Integer
    field :amoi
    field :chromosome
    field :position
    field :alt
    field :ref
    field :literature_reference
    field :special_rules

  end
