class TreatmentWorker
  include Shoryuken::Worker

  shoryuken_options queue: ->{"#{ENV['queue_name']}"}, auto_delete: true

  def perform(_sqs_message, treatment_arm)
    begin
      treatment_arm = JSON.parse(treatment_arm).symbolize_keys!
      if(TreatmentArm.scan(:scan_filter =>
                               {"name" => {:comparison_operator => "EQ",
                                           :attribute_value_list => [treatment_arm[:id]]},
                                "stratum_id" => {:comparison_operator => "EQ",
                                                 :attribute_value_list => [treatment_arm[:stratum_id]]
                                },
                                "version" => {:comparison_operator => "EQ",
                                              :attribute_value_list => [treatment_arm[:version]]
                                }
                               }, :conditional_operator => "AND").collect{ | data | data.to_h }.blank?)
        insert(treatment_arm)
      else
        Shoryuken.logger.info("TreatmentArm #{treatment_arm[:id]} version #{treatment_arm[:version]} exists already.  Skipping")
      end
    rescue => error
      Shoryuken.logger.error("Treatment Arm Worker failed with error #{error}")
    end
  end

  def insert(treatment_arm)
    begin
      treatment_arm_model = TreatmentArm.new
      json = remove_blank_document(treatment_arm)
      json = treatment_arm_model.convert_models(json).to_json
      treatment_arm_model.from_json(json)
      treatment_arm_model.save
      Shoryuken.logger.info("TreatmentArm #{treatment_arm[:id]} version #{treatment_arm[:version]} has been saved successfully")
    rescue => error
      Shoryuken.logger.error("Failed to save treatment arm with error #{error}")
    end
  end

  #Refacto!
  def remove_blank_document(treatment_arm)
    hash_proc = Proc.new { |k, v| v.kind_of?(Hash) ? (v.delete_if(&hash_proc); nil) : v.to_s.blank? }
    treatment_arm.delete_if(&hash_proc)
    if !treatment_arm[:exclusion_drugs].blank?
      treatment_arm[:exclusion_drugs].each do | drugs |
        drugs.delete_if(&hash_proc)
      end
    end
    treatment_arm
  end
end