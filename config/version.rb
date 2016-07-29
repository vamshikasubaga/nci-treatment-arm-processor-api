module NciTreatmentArmProcessorApi
  class Application < Rails::Application
    attr_reader :VERSION

    def VERSION
      @VERSION ||= "1.0.0"
    end
  end
end
