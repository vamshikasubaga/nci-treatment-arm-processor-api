require 'rufus-scheduler'

patient_thread = Rufus::Scheduler.singleton
treatment_arm_thread = Rufus::Scheduler.singleton

treatment_arm_thread.every '15s' do
  BasicTreatmentArmWorker.perform_async("BasicTreatmentArmUpdater")
end

patient_thread.every '15s' do
  # PatientWorker.perform_async("patient found")
end
