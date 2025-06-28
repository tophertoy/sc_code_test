require 'rails_helper'

RSpec.describe ClientImportService do
  it "imports clients from JSON into database" do
    result = ClientImportService.call
    
    expect(result[:success]).to be true
    expect(result[:imported_count]).to eq(35)
    expect(result[:invalid_count]).to eq(0)
    expect(result[:total_processed]).to eq(35)
    expect(Client.count).to eq(35)
    
    first_client = Client.first
    expect(first_client.full_name).to eq('John Doe')
    expect(first_client.email).to eq('john.doe@gmail.com')
    
    # Check for duplicate email (from the JSON data)
    duplicate_emails = Client.group(:email).having('count(*) > 1').pluck(:email)
    expect(duplicate_emails).to include('jane.smith@yahoo.com')
  end

  it "handles import with invalid records" do
    # Use the mixed data file that has some invalid records
    allow(JsonDataLoaderService).to receive(:call).and_return(
      JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'mixed_data.json'))
    )
    
    result = ClientImportService.call
    
    expect(result[:success]).to be true
    expect(result[:imported_count]).to eq(3)
    expect(result[:invalid_count]).to eq(2)
    expect(result[:total_processed]).to eq(5)
    expect(Client.count).to eq(3)
  end

  it "handles JSON parsing errors" do
    # Use the invalid JSON file
    allow(JsonDataLoaderService).to receive(:call).and_return(
      JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'invalid_json.json'))
    )
    
    result = ClientImportService.call
    
    expect(result[:success]).to be false
    expect(result[:error]).to include('Invalid JSON format')
    expect(Client.count).to eq(0)
  end
end 