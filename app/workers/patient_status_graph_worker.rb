class PatientStatusGraphWorker
  include Sneakers::Worker

  from_queue :patient_status,
             :durable => true,
             :block => true

  def work(message)
    begin
      treatment_arms = TreatmentArm.distinct(:treatment_arm_id)
      treatment_arms.each do | treatment_arm_id |
        insert_if_not_present(treatment_arm_id)
        update_pie_data(treatment_arm_id)
      end
      p "patient_status_pie_data has been updated"
      ack!
    rescue => error
      p error
      reject!
    end
  end

  def update_pie_data(treatment_arm_id)
    status_pie_data = StatusPieData.where(:_id => treatment_arm_id).first
    status_list = TreatmentArm.distinct(:'patient.current_patient_status')
    new_status_array = []
    status_list.each do | status |
      status_data = TreatmentArm.where(:treatment_arm_id => treatment_arm_id, :'patient.current_patient_status' => status).map {| val | val[:patient][:patient_sequence_number] }
      pie_data = {
          :label => status,
          :data => status_data.length,
          :psns => status_data
      }
      new_status_array << pie_data
    end
    status_pie_data.status_array = new_status_array
    status_pie_data.save
  end


  def insert_if_not_present(treatment_arm_id)
    if !StatusPieData.where(:_id => treatment_arm_id).exists?
      StatusPieData.new({:_id => treatment_arm_id, :status_array => []}).save
      p "Saving new StatusPieData for #{treatment_arm_id}"
    end
  end
end
