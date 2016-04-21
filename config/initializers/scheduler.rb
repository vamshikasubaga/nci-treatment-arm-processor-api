require 'rufus-scheduler'

thread = Rufus::Scheduler.singleton
thread.every '1s' do
  BasicTreatmentArmJob.perform_later
end