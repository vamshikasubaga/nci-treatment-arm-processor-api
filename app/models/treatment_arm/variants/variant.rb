module Variant
  extend ActiveSupport::Concern

  included do
    field :public_med_ids, type: Array
    field :gene_name
    field :chromosome
    field :position
    field :identifier
    field :reference
    field :alternative
    field :filter
    field :description
    field :protein
    field :transcript
    field :hgvs
    field :location
    field :read_depth, type: Integer
    field :rare, type: Boolean
    field :allele_frequency, type: Float
    field :flow_alternative_allele_observation_count
    field :flow_reference_allele_observations
    field :reference_allele_observations, type: Integer
    field :alternative_allele_observation_count, type: Integer
    field :variant_class
    field :level_of_evidence, type: Integer
    field :inclusion, type: Boolean, default: true
    field :arm_specific, type: Boolean, default: false
  end

end
