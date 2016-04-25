class StatusPieData
  include Mongoid::Document

  field :_id
  field :status_array, type: Array


end