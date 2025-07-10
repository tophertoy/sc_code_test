require 'rails_helper'

RSpec.describe DuplicateEmailService do
  before do
    ClientImportService.call
  end

  describe '#call' do
    context 'with include_clients: false (default)' do
      it "finds duplicate emails" do
        duplicate_emails = DuplicateEmailService.call
        expect(duplicate_emails).to include('jane.smith@yahoo.com')
        expect(duplicate_emails.count).to eq(1)
      end

      it "returns empty when no duplicates exist" do
        Client.where(email: 'jane.smith@yahoo.com').first.destroy

        duplicate_emails = DuplicateEmailService.call
        expect(duplicate_emails).to be_empty
      end

      it "returns emails in alphabetical order" do
        # Create another duplicate email to test ordering
        create(:client, full_name: "Alice Test", email: "alice@example.com")
        create(:client, full_name: "Alice Test 2", email: "alice@example.com")
        
        duplicate_emails = DuplicateEmailService.call
        expect(duplicate_emails).to eq(duplicate_emails.sort)
      end
    end

    context 'with include_clients: true' do
      it "returns duplicate emails with client data" do
        duplicate_data = DuplicateEmailService.call(include_clients: true)
        
        expect(duplicate_data).to be_an(Array)
        expect(duplicate_data.first).to include(:email, :count, :clients)
        expect(duplicate_data.first[:email]).to eq('jane.smith@yahoo.com')
        expect(duplicate_data.first[:count]).to eq(2)
        expect(duplicate_data.first[:clients]).to be_an(Array)
        expect(duplicate_data.first[:clients].length).to eq(2)
      end

      it "returns empty array when no duplicates exist" do
        Client.where(email: 'jane.smith@yahoo.com').first.destroy

        duplicate_data = DuplicateEmailService.call(include_clients: true)
        expect(duplicate_data).to be_empty
      end

      it "orders clients by id within each email group" do
        duplicate_data = DuplicateEmailService.call(include_clients: true)
        
        # Verify that clients within each email group are ordered by ID
        duplicate_data.each do |duplicate|
          clients = duplicate[:clients]
          client_ids = clients.map { |client| client[:id] }
          expect(client_ids).to eq(client_ids.sort)
        end
      end

      it "returns duplicate emails in alphabetical order" do
        # Create another duplicate email to test ordering
        create(:client, full_name: "Alice Test", email: "alice@example.com")
        create(:client, full_name: "Alice Test 2", email: "alice@example.com")
        
        duplicate_data = DuplicateEmailService.call(include_clients: true)
        email_order = duplicate_data.map { |duplicate| duplicate[:email] }
        expect(email_order).to eq(email_order.sort)
      end
    end
  end
end
