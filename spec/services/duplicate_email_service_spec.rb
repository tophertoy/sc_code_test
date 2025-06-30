require 'rails_helper'

RSpec.describe DuplicateEmailService do
  before do
    ClientImportService.call
  end

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
end
