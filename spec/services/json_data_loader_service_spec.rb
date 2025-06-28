require 'rails_helper'

RSpec.describe JsonDataLoaderService do
  it "loads and parses clients.json" do
    clients = JsonDataLoaderService.call
    
    expect(clients).to be_an(Array)
    expect(clients.first).to include('id', 'full_name', 'email')
    expect(clients.first['full_name']).to eq('John Doe')
    expect(clients.first['email']).to eq('john.doe@gmail.com')
  end
end 