require 'mongoid'

class NonHotspotRule
    include Mongoid::Document
    include Mongoid::Attributes::Dynamic

    field :description
    field :oncomine_Variant_Class
    field :gene_Name
    field :exon
    field :function
    field :level_Of_Evidence
    field :literature_Reference
    field :special_Rules
    field :protein_Match

end