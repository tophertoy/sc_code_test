require 'rails_helper'

RSpec.describe ClientImportService do
  describe "importing clients from JSON" do
    it "imports clients into the database" do
      result = ClientImportService.call
      
      expect(result[:success]).to be true
      expect(result[:imported_count]).to eq(35)
      expect(result[:invalid_count]).to eq(0)
      expect(result[:total_processed]).to eq(35)
      expect(Client.count).to eq(35)
      
      first_client = Client.first
      expect(first_client.full_name).to eq('John Doe')
      expect(first_client.email).to eq('john.doe@gmail.com')
      
      duplicate_emails = Client.group(:email).having('count(*) > 1').pluck(:email)
      expect(duplicate_emails).to include('jane.smith@yahoo.com')
    end
  end

  context "when handling invalid records" do
    it "imports only valid records" do
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
  end

  context "when JSON parsing errors occur" do
    it "handles invalid JSON format" do
      allow(JsonDataLoaderService).to receive(:call).and_return(
        JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'invalid_json.json'))
      )
      
      result = ClientImportService.call
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('Invalid JSON format')
      expect(Client.count).to eq(0)
    end
  end

  context "when file not found" do
    it "handles file not found errors" do
      allow(JsonDataLoaderService).to receive(:call).and_return(
        JsonDataLoaderService.call('nonexistent_file.json')
      )
      
      result = ClientImportService.call
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('File not found')
      expect(Client.count).to eq(0)
    end
  end

  context "when handling empty data" do
    it "handles empty valid records array" do
      allow(JsonDataLoaderService).to receive(:call).and_return(
        JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'empty_array.json'))
      )
      
      result = ClientImportService.call
      
      expect(result[:success]).to be true
      expect(result[:imported_count]).to eq(0)
      expect(result[:invalid_count]).to eq(0)
      expect(result[:total_processed]).to eq(0)
      expect(Client.count).to eq(0)
    end

    it "handles all invalid records" do
      allow(JsonDataLoaderService).to receive(:call).and_return(
        JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'all_invalid.json'))
      )
      
      result = ClientImportService.call
      
      expect(result[:success]).to be true
      expect(result[:imported_count]).to eq(0)
      expect(result[:invalid_count]).to eq(4)
      expect(result[:total_processed]).to eq(4)
      expect(Client.count).to eq(0)
    end
  end

  context "when handling database constraints" do
    it "handles database constraint violations gracefully" do
      ClientImportService.call
      
      result = ClientImportService.call
      
      expect(result[:success]).to be true
      expect(result[:imported_count]).to eq(35)
      expect(Client.count).to eq(70)
    end
  end

  context "when records have missing required fields" do
    it "imports records with missing fields" do
      allow(JsonDataLoaderService).to receive(:call).and_return({
        success: true,
        valid_records: [
          { 'full_name' => 'Valid Name', 'email' => 'valid@example.com' },
          { 'full_name' => 'Missing Email' },
          { 'email' => 'missing.name@example.com' },
          { 'full_name' => 'Valid Again', 'email' => 'valid2@example.com' }
        ],
        invalid_records: [],
        total_records: 4,
        valid_count: 4,
        invalid_count: 0
      })
      
      result = ClientImportService.call
      
      expect(result[:success]).to be true
      expect(result[:imported_count]).to eq(4)
      expect(Client.count).to eq(4)
      
      missing_email_client = Client.find_by(full_name: 'Missing Email')
      missing_name_client = Client.find_by(email: 'missing.name@example.com')
      
      expect(missing_email_client.email).to be_nil
      expect(missing_name_client.full_name).to be_nil
    end
  end

  context "when JSON is not an array" do
    it "handles non-array JSON data" do
      allow(JsonDataLoaderService).to receive(:call).and_return(
        JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'non_array.json'))
      )
      
      result = ClientImportService.call
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('Expected JSON array')
      expect(Client.count).to eq(0)
    end
  end
end 