require 'mongoid'

  class InclusionVariant
    include Mongoid::Document

    field :gene
    field :id
    field :type
    field :description
    field :level_Of_Evidence, type: Integer
    field :amoi
    field :chromosome
    field :position
    field :alt
    field :ref
    field :literature_Reference
    field :special_Rules

  end

