require 'rufus-scheduler'

patient_thread = Rufus::Scheduler.singleton
treatment_arm_thread = Rufus::Scheduler.singleton
treatment_arm_thread.every '2s' do
  Publisher.publish("basic_treatment_arm")
end
patient_thread.every '5s' do
  Publisher.publish("patient_status")
end
