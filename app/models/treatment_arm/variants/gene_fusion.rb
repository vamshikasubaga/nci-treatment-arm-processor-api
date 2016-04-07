require 'mongoid'
require 'confirmable_variant'

class GeneFusion < ConfirmableVariant
  include Mongoid::Document

  field :fusionIdentity

  embedded_in :variantReport, inverse_of: :geneFusions

end