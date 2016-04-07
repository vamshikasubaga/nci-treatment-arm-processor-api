class NonHotspotRule
  include Variant
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :gene
  field :oncominevariantclass
  field :exon
  field :function
  field :protein_match

  embedded_in :variant_report, inverse_of: :non_hotspot_rules
      
end
