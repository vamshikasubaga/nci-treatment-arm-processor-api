require 'mongoid'

  class Disease
    include Mongoid::Document

    field :_id
    field :medraCode
    field :ctepCategory
    field :ctepSubCategory
    field :ctepTerm
    field :shortName

    embedded_in :treatmentarm, :inverse_of => :exclusionDiseases

  end
