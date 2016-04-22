require 'rufus-scheduler'

thread = Rufus::Scheduler.singleton
thread.every '3s' do
  BasicTreatmentArmJob.perform_later
end