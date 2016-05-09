require 'rufus-scheduler'

patient_thread = Rufus::Scheduler.singleton
treatment_arm_thread = Rufus::Scheduler.singleton

treatment_arm_thread.every '5s' do

  TreatmentWorker.perform_async("Hello from treatment_arm_worker")
  # Publisher.publish("basic_treatment_arm")

end
patient_thread.every '5s' do

  PatientWorker.perform_async("patient found")
  # Publisher.publish("patient_status")
  # Publisher.publish("patient_disease")
end
