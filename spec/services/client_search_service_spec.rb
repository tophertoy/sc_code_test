require 'rails_helper'

RSpec.describe ClientSearchService do
  before do
    ClientImportService.call
  end

  it "finds clients with partial name match" do
    results = ClientSearchService.call('john')
    expect(results.count).to eq(2)
    expect(results.pluck(:full_name)).to include('John Doe', 'Alex Johnson')
  end

  it "returns empty when no matches found" do
    results = ClientSearchService.call('xyz')
    expect(results).to be_empty
  end

  it "is case insensitive" do
    results = ClientSearchService.call('JOHN')
    expect(results.count).to eq(2)
  end

  it "handles empty query" do
    results = ClientSearchService.call('')
    expect(results.count).to eq(35) 
  end
end