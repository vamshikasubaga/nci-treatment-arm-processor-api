

class VariantReport
  include Mongoid::Document


  embeds_many :single_nucleotide_variants, class_name: "SingleNucleotideVariant", inverse_of: :variant_report
  embeds_many :indels, class_name: "Indel", inverse_of: :variant_report
  embeds_many :copy_number_variants, class_name: "CopyNumberVariant", inverse_of: :variant_report
  embeds_many :gene_fusions, class_name: "GeneFusion", inverse_of: :variant_report
  embeds_many :unified_gene_fusions, class_name: "UnifiedGeneFusion", inverse_of: :variant_report
  embeds_many :non_hotspot_rules, class_name: "NonHotspotRule", inverse_of: :variant_report

  field :created_date, type: DateTime, default: Time.now


  embedded_in :treatmentarm, inverse_of: :variant_report


end