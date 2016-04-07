class Indel  < ConfirmableVariant
  include Mongoid::Document

  embedded_in :variant_report, inverse_of: :indels

end
