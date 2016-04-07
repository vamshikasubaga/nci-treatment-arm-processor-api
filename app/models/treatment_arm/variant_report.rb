

class VariantReport
  include Mongoid::Document


  embeds_many :singleNucleotideVariants, class_name: "SingleNucleotideVariant", inverse_of: :variantReport
  embeds_many :indels, class_name: "Indel", inverse_of: :variantReport
  embeds_many :copyNumberVariants, class_name: "CopyNumberVariant", inverse_of: :variantReport
  embeds_many :geneFusions, class_name: "GeneFusion", inverse_of: :variantReport
  embeds_many :unifiedGeneFusions, class_name: "UnifiedGeneFusion", inverse_of: :variantReport
  embeds_many :nonHotspotRules, class_name: "NonHotspotRule", inverse_of: :variantReport

  field :createdDate, type: DateTime, default: Time.now


  embedded_in :treatmentarm, inverse_of: :variantReport


  def has_a_inclusion
    if loop_variant(:inclusion, singleNucleotideVariants).include? true
      return true
      elif loop_variant(:inclusion, indels).include? true
        return true
      elsif loop_variant(:inclusion, copyNumberVariants).include? true
        return true
      elsif loop_variant(:inclusion, geneFusions).include? true
        return true
      elsif loop_variant(:inclusion, unifiedGeneFusions).include? true
        return true
      elsif loop_variant(:inclusion, nonHotspotRules).include? true
        return true
      else
        return false
    end
  end


  private

  def loop_variant(attributeName, objects=self)
    objects.collect do | object |
      object.read_attribute(attributeName)
    end
  end


end