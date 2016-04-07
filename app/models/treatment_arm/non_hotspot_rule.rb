require 'mongoid'

class NonHotspotRule
    include Mongoid::Document
    include Mongoid::Attributes::Dynamic

    field :description
    field :oncomine_variant_class
    field :gene_name
    field :exon
    field :function
    field :level_of_evidence
    field :literature_reference
    field :special_rules
    field :protein_match

end