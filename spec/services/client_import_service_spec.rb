require 'rails_helper'

RSpec.describe ClientImportService do
  it "imports clients from JSON into database" do
    expect { ClientImportService.call }.to change(Client, :count).by(35)
    
    first_client = Client.first
    expect(first_client.full_name).to eq('John Doe')
    expect(first_client.email).to eq('john.doe@gmail.com')
    
    # Check for duplicate email (from the JSON data)
    duplicate_emails = Client.group(:email).having('count(*) > 1').pluck(:email)
    expect(duplicate_emails).to include('jane.smith@yahoo.com')
  end
end 