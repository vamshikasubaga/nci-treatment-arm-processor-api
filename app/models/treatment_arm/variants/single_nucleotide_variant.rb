require 'mongoid'
require 'confirmable_variant'

class SingleNucleotideVariant < ConfirmableVariant
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :variantReport, inverse_of: :singleNucleotideVariants


end
