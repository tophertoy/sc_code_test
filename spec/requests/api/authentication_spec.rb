require 'rails_helper'

RSpec.describe 'API Authentication', type: :request do
  let(:username) { 'testuser' }
  let(:password) { 'testpass' }

  before do
    # Set up test credentials
    allow(Rails.application.credentials).to receive(:api_username).and_return(username)
    allow(Rails.application.credentials).to receive(:api_password).and_return(password)
  end

  describe 'API endpoints' do
    context 'with valid credentials' do
      it 'allows access to search endpoint' do
        get '/api/clients/search', 
            headers: { 'HTTP_AUTHORIZATION' => "Basic #{Base64.strict_encode64("#{username}:#{password}")}" }

        expect(response).to have_http_status(:ok)
      end

      it 'allows access to duplicates endpoint' do
        get '/api/clients/duplicates',
            headers: { 'HTTP_AUTHORIZATION' => "Basic #{Base64.strict_encode64("#{username}:#{password}")}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid credentials' do
      it 'denies access to search endpoint' do
        get '/api/clients/search',
            headers: { 'HTTP_AUTHORIZATION' => "Basic #{Base64.strict_encode64('wrong:credentials')}" }

        expect(response).to have_http_status(:unauthorized)
      end

      it 'denies access to duplicates endpoint' do
        get '/api/clients/duplicates',
            headers: { 'HTTP_AUTHORIZATION' => "Basic #{Base64.strict_encode64('wrong:credentials')}" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'without credentials' do
      it 'denies access to search endpoint' do
        get '/api/clients/search'

        expect(response).to have_http_status(:unauthorized)
      end

      it 'denies access to duplicates endpoint' do
        get '/api/clients/duplicates'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end 