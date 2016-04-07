require 'mongoid'
require 'confirmable_variant'


    class UnifiedGeneFusion < ConfirmableVariant
      include Mongoid::Document

      field :driverReadCount, type: Integer
      field :partnerReadCount, type: Integer
      field :driverGene
      field :partnerGene
      field :annotation

      embedded_in :variantReport, inverse_of: :unifiedGeneFusions
      
    end
