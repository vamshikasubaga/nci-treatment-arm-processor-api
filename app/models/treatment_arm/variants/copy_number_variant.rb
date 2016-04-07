

class CopyNumberVariant < ConfirmableVariant
  include Mongoid::Document


  field :ref_copy_number, type: Float
  field :raw_copy_number, type: Float
  field :copy_number, type: Float
  field :confidence_interval_95_percent, type: Float
  field :confidence_interval_5_percent, type: Float

  embedded_in :variant_report, inverse_of: :copy_number_variants

end
