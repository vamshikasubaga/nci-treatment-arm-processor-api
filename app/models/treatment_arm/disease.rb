require 'mongoid'

  class Disease
    include Mongoid::Document

    field :_id
    field :medra_code
    field :ctep_category
    field :ctep_sub_category
    field :ctep_term
    field :short_name

    embedded_in :treatmentarm, :inverse_of => :exclusion_diseases

  end
