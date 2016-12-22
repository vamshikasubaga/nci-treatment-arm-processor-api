module NciTreatmentArmProcessorApi
  class Application < Rails::Application
    attr_reader :version

    def version
      @version ||= '1.0.0'
    end
  end
end
