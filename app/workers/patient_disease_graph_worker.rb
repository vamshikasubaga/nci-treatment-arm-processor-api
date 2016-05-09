class PatientDiseaseGraphWorker
  include Shoryuken::Worker

  shoryuken_options queue: 'ta_basic_treatment_arm_dev', auto_delete: true

  def perform(message)
    begin
      treatment_arms = TreatmentArm.distinct(:treatment_arm_id)
      treatment_arms.each do | treatment_arm_id |
        insert_if_not_present(treatment_arm_id)
        update_pie_data(treatment_arm_id)
      end
      p "patient_disease_pie_data has been updated"
      ack!
    rescue => error
      p error
      reject!
    end
  end

  def update_pie_data(treatment_arm_id)
    status_pie_data = DiseasePieData.where(:_id => treatment_arm_id).first
    new_disease_array = []
    disease_list = TreatmentArm.where(:treatment_arm_id => treatment_arm_id).distinct(:'patient.diseases.ctep_sub_category')
    disease_list.each do | disease |
      disease_data = TreatmentArm.where(:treatment_arm_id => treatment_arm_id, :'patient.diseases.ctep_sub_category' => disease).map {| val | val[:patient][:patient_sequence_number] }
      pie_data = {
          :label => disease,
          :data => disease_data.length,
          :psns => disease_data
      }
      new_disease_array << pie_data
    end
    status_pie_data.disease_array = new_disease_array
    status_pie_data.save
  end


  def insert_if_not_present(treatment_arm_id)
    if !DiseasePieData.where(:_id => treatment_arm_id).exists?
      DiseasePieData.new({:_id => treatment_arm_id, :disease_array => []}).save
      p "Saving new DiseasePieData for #{treatment_arm_id}"
    end
  end
end
