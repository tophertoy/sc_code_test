require 'rails_helper'

RSpec.describe Client, type: :model do
  it "can be created with full_name and email" do
    client = create(:client)
    expect(client).to be_valid
    expect(client.full_name).to eq("John Doe")
    expect(client.email).to eq("john.doe@example.com")
  end
end
