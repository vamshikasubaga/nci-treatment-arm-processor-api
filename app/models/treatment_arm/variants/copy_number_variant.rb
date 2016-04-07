

class CopyNumberVariant < ConfirmableVariant
  include Mongoid::Document


  field :refCopyNumber, type: Float
  field :rawCopyNumber, type: Float
  field :copyNumber, type: Float
  field :confidenceInterval95percent, type: Float
  field :confidenceInterval5percent, type: Float

  embedded_in :variantReport, inverse_of: :copyNumberVariants

end
