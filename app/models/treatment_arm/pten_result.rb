require 'mongoid'

class PtenResult
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  # include Mongoid::Enum

  # enum :ptenIhcResult, [:POSITIVE, :NEGATIVE, :INDETERMINATE, :PRE_PRESENT, :PRE_NEGATIVE, :PRE_INDETERMINATE]
  # enum :ptenVariant, [:PRESENT, :NEGATIVE, :EMPTY]
  field :description

  embedded_in :treatmentarm, inverse_of: :ptenResults

  def get_pten_variant_status
    ptenVariant.status
  end

end
