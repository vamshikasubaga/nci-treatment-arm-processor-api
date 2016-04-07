require 'mongoid'
require 'confirmable_variant'

class SingleNucleotideVariant < ConfirmableVariant
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :variant_report, inverse_of: :single_nucleotide_variants


end
