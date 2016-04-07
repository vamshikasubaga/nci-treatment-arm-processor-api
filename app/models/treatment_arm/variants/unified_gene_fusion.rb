require 'mongoid'
require 'confirmable_variant'


    class UnifiedGeneFusion < ConfirmableVariant
      include Mongoid::Document

      field :driver_read_count, type: Integer
      field :partner_read_count, type: Integer
      field :driver_gene
      field :partner_gene
      field :annotation

      embedded_in :variant_report, inverse_of: :unified_gene_fusions
      
    end
