require 'rails_helper'

RSpec.describe Api::ClientsController, type: :request do
  describe 'GET /api/clients/search' do
    let!(:client1) { create(:client, full_name: 'John Doe', email: 'john@example.com') }
    let!(:client2) { create(:client, full_name: 'Jane Smith', email: 'jane@example.com') }
    let!(:client3) { create(:client, full_name: 'Bob Wilson', email: 'bob@example.com') }

    context 'with a search query' do
      it 'returns matching clients' do
        get '/api/clients/search', params: { q: 'john' }

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['query']).to eq('john')
        expect(json_response['clients'].length).to eq(1)
        expect(json_response['clients'].first['full_name']).to eq('John Doe')
      end

      it 'returns empty results for no matches' do
        get '/api/clients/search', params: { q: 'nonexistent' }

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['clients']).to be_empty
      end

      it 'performs case-insensitive search' do
        get '/api/clients/search', params: { q: 'JOHN' }

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['clients'].length).to eq(1)
        expect(json_response['clients'].first['full_name']).to eq('John Doe')
      end
    end

    context 'with pagination' do
      before do
        30.times { |i| create(:client, full_name: "Client #{i}", email: "client#{i}@example.com") }
      end

      it 'returns paginated results' do
        get '/api/clients/search', params: { q: '', page: 2, per_page: 10 }

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['page']).to eq(2)
        expect(json_response['per_page']).to eq(10)
        expect(json_response['clients'].length).to eq(10)
      end

      it 'uses default pagination when not specified' do
        get '/api/clients/search', params: { q: '' }

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['page']).to eq(1)
        expect(json_response['per_page']).to eq(25)
      end
    end

    context 'with empty query' do
      it 'returns all clients' do
        get '/api/clients/search', params: { q: '' }

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['clients'].length).to eq(3)
      end
    end
  end

  describe 'GET /api/clients/duplicates' do
    let!(:client1) { create(:client, full_name: 'John Doe', email: 'duplicate@example.com') }
    let!(:client2) { create(:client, full_name: 'Jane Smith', email: 'duplicate@example.com') }
    let!(:client3) { create(:client, full_name: 'Bob Johnson', email: 'unique@example.com') }

    it 'returns duplicate emails with their clients' do
      get '/api/clients/duplicates'

      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['duplicate_emails'].length).to eq(1)
      
      duplicate = json_response['duplicate_emails'].first
      expect(duplicate['email']).to eq('duplicate@example.com')
      expect(duplicate['count']).to eq(2)
      expect(duplicate['clients'].length).to eq(2)
    end

    context 'when no duplicates exist' do
      before do
        Client.destroy_all
        create(:client, full_name: 'John Doe', email: 'john@example.com')
        create(:client, full_name: 'Jane Smith', email: 'jane@example.com')
      end

      it 'returns empty array' do
        get '/api/clients/duplicates'

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['duplicate_emails']).to be_empty
      end
    end
  end
end 