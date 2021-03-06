# Versions Controller, Gets Triggered when /version call is hit
class VersionsController < ApplicationController
  def version
    begin
      File.open('build_number.html', 'r') do |document|
        @hash = {}
        document.each_line do |line|
          arr = line.split('=', 2)
          @hash.store(arr[0], arr[1])
        end
        document.close
      end
      @version = NciTreatmentArmProcessorApi::Application.version
      @rails_version = Rails::VERSION::STRING
      @ruby_version = RUBY_VERSION
      @running_on = @hash['Commit'].present? ? @hash['Commit'] : ''
      @author = @hash['Author'].present? ? @hash['Author'] : ''
      @travisbuild = @hash['TravisBuild'].present? ? @hash['TravisBuild'] : ''
      @travisjob = @hash['TravisBuildID'].present? ? @hash['TravisBuildID'] : ''
      @dockerinstance = @hash['Docker'].present? ? @hash['Docker'] : ''
      @buildtime = @hash['BuildTime'].present? ? @hash['BuildTime'] : ''
      @environment = Rails.env
    rescue => error
      standard_error_message(error)
    end
  end
end
