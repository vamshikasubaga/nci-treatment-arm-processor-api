module Variant
  extend ActiveSupport::Concern

  included do
    field :publicMedIds, type: Array
    field :geneName
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
    field :readDepth, type: Integer
    field :rare, type: Boolean
    field :alleleFrequency, type: Float
    field :flowAlternativeAlleleObservationCount
    field :flowReferenceAlleleObservations
    field :referenceAlleleObservations, type: Integer
    field :alternativeAlleleObservationCount, type: Integer
    field :variantClass
    field :levelOfEvidence, type: Integer
    field :inclusion, type: Boolean, default: true
    field :armSpecific, type: Boolean, default: false
  end

end
