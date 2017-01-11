class VersionsController < ApplicationController
  def version
    begin
      document = File.open('build_number.html', 'r')
      hash = Hash.new
      document.each_line do |line|
        str = line.to_s
        arr = str.split('=', 2)
        hash.store(arr[0], arr[1])
      end
      @version = NciTreatmentArmProcessorApi::Application.version
      @rails_version = Rails::VERSION::STRING
      @ruby_version = RUBY_VERSION
      @running_on = hash['Commit'].present? ? hash['Commit'] : ''
      @author = hash['Author'].present? ? hash['Author'] : ''
      @travisbuild = hash['TravisBuild'].present? ? hash['TravisBuild'] : ''
      @travisjob = hash['TravisBuildID'].present? ? hash['TravisBuildID'] : ''
      @dockerinstance = hash['Docker'].present? ? hash['Docker'] : ''
      @buildtime = hash['BuildTime'].present? ? hash['BuildTime'] : ''
      @environment = Rails.env
    rescue => error
      standard_error_message(error)
    end
  end
end