require 'mongoid'
require 'confirmable_variant'

class GeneFusion < ConfirmableVariant
  include Mongoid::Document

  field :fusion_identity

  embedded_in :variant_report, inverse_of: :gene_fusions

end