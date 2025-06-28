require 'rails_helper'

RSpec.describe JsonDataLoaderService do
  describe '.call' do
    it "loads and parses valid clients.json" do
      result = JsonDataLoaderService.call
      
      expect(result).to be_a(Hash)
      expect(result[:success]).to be true
      expect(result[:valid_records]).to be_an(Array)
      expect(result[:invalid_records]).to be_an(Array)
      expect(result[:valid_records].first).to include('id', 'full_name', 'email')
    end

    it "handles file not found gracefully" do
      result = JsonDataLoaderService.call('nonexistent_file.json')
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('File not found')
      expect(result[:valid_records]).to eq([])
      expect(result[:invalid_records]).to eq([])
    end

    it "handles invalid JSON format" do
      result = JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'invalid_json.json'))
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('Invalid JSON format')
      expect(result[:valid_records]).to eq([])
      expect(result[:invalid_records]).to eq([])
    end

    it "handles non-array JSON data" do
      result = JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'non_array.json'))
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('Expected JSON array')
      expect(result[:valid_records]).to eq([])
      expect(result[:invalid_records]).to eq([])
    end

    it "handles mixed valid and invalid records" do
      result = JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'mixed_data.json'))
      
      expect(result[:success]).to be true
      expect(result[:valid_records].length).to eq(3)
      expect(result[:invalid_records].length).to eq(2)
      expect(result[:total_records]).to eq(5)
      expect(result[:valid_count]).to eq(3)
      expect(result[:invalid_count]).to eq(2)
      
      # Check valid records
      expect(result[:valid_records].map { |r| r['name'] }).to eq([
        'Valid User', 'Another Valid', 'Third Valid'
      ])
      
      # Check invalid records
      expect(result[:invalid_records].map { |r| r[:errors].first }).to eq([
        'Record must be a hash, got String',
        'Record must be a hash, got Integer'
      ])
    end

    it "handles empty array" do
      result = JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'empty_array.json'))
      
      expect(result[:success]).to be true
      expect(result[:valid_records]).to eq([])
      expect(result[:invalid_records]).to eq([])
      expect(result[:total_records]).to eq(0)
      expect(result[:valid_count]).to eq(0)
      expect(result[:invalid_count]).to eq(0)
    end

    it "handles array with only invalid records" do
      result = JsonDataLoaderService.call(Rails.root.join('lib', 'data', 'all_invalid.json'))
      
      expect(result[:success]).to be true
      expect(result[:valid_records]).to eq([])
      expect(result[:invalid_records].length).to eq(4)
      expect(result[:total_records]).to eq(4)
      expect(result[:valid_count]).to eq(0)
      expect(result[:invalid_count]).to eq(4)
    end
  end
end 