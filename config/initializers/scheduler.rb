require 'rufus-scheduler'

thread = Rufus::Scheduler.singleton
thread.every '5s' do
  BasicTreatmentArmJob.perform_later
end