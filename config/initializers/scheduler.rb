require 'rufus-scheduler'

patient_thread = Rufus::Scheduler.singleton
treatment_arm_thread = Rufus::Scheduler.singleton

treatment_arm_thread.every '5s' do
  TreatmentWorker.perform_async("Hello from treatment_arm_worker")
  BasicTreatmentArmWorker.perform_async("Update Basic Treatment Arms")
end

patient_thread.every '5s' do
  PatientWorker.perform_async("patient found")
end
