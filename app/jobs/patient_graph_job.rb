class PatientGraphJob

  attr_accessor :ta_distinct_list, :status_distinct_list, :disease_list

  def perform(body)

    treatment_arm_list = TreatmentArm.scan({attributes_to_get: ["name"]})
    @ta_distinct_list ||= []
    treatment_arm_list.each do | treatment_arm_id |
      ta_distinct_list.push(treatment_arm_id)
    end
    @ta_distinct_list.uniq!{ |x| x.name }

    patient_status = TreatmentArmPatient.scan({attributes_to_get: ["current_patient_status"]})
    @status_distinct_list ||= []
    patient_status.each do | treatment_arm_id |
      status_distinct_list.push(treatment_arm_id)
    end
    @status_distinct_list.uniq!{ |x| x.current_patient_status }

    @ta_distinct_list.each do | ta_name |
      update(ta_name)
    end

  end


  def update(ta_name)
    new_status_array = []
    status_distinct_list.each do | status |
      status_data = TreatmentArmPatient.scan(:scan_filter => {"treatment_arm_name_version" => {:comparison_operator => "CONTAINS", :attribute_value_list => [ta_name.name]},
                                                              "current_patient_status" => {:comparison_operator => "EQ", :attribute_value_list => [status.current_patient_status]}},
                                             :conditional_operator => "AND").map {| val | val.patient_sequence_number}
      pie_data = {
          :label => status.current_patient_status,
          :data => status_data.length,
          :psns => status_data
      }
      new_status_array << pie_data
    end
    if !StatusPieData.find(:id => ta_name.name).blank?
      data = StatusPieData.find(:id => ta_name.name)
      data.status_array = new_status_array
      data.save
    else
      status_pie_data = StatusPieData.new
      status_pie_data.id = ta_name.name
      status_pie_data.status_array = new_status_array
      status_pie_data.save
    end
  end

end
