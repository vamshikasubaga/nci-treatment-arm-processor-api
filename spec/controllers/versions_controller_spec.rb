require 'rails_helper'

describe VersionsController do
  describe 'GET #version' do
    it 'Should return the API version' do
      get :version
      expect(response).to have_http_status(200)
    end

    it 'should route to the correct controller' do
      expect(get: '/version').to route_to(controller: 'versions', action: 'version')
    end

    it 'should handle an error correctly' do
      allow(NciTreatmentArmProcessorApi::Application).to receive(:VERSION).and_raise('this error')
      get :version
      expect(response).to have_http_status(500)
    end
  end
end