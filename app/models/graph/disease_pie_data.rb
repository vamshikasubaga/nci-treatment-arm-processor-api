class DiseasePieData
  include Mongoid::Document

  field :_id
  field :disease_array, type: Array


end