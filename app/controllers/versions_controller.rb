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
      @version = NciTreatmentArmProcessorApi::Application.VERSION
      @rails_version = Rails::VERSION::STRING
      @ruby_version = RUBY_VERSION
      @running_on = hash['Commit'].present? ? hash['Commit'].tr("\n", "") : ""
      @author = hash['Author'].present? ? hash['Author'].tr("\n", "") : ""
      @travisbuild = hash['TravisBuild'].present? ? hash['TravisBuild'].tr("\n", "") : ""
      @travisjob = hash['TravisJob'].present? ? hash['TravisJob'].tr("\n", "").to_i - 1 : ""
      @dockerinstance = hash['Docker'].present? ? hash['Docker'].tr("\n", "") : ""
      @buildtime = hash['BuildTime'].present? ? hash['BuildTime'].tr("\n", "") : ""
      @environment = Rails.env
    rescue => error
      standard_error_message(error)
    end
  end

  private

  def standard_error_message(error)
    logger.error error.message
    render json: error.to_json, status: 500
  end
end