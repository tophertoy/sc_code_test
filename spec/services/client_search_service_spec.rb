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
    results = ClientSearchService.call('', per_page: 35)
    expect(results.count).to eq(35)
  end

  it "paginates results with default per_page" do
    results = ClientSearchService.call('', page: 1)
    expect(results.count).to eq(25) # Default per_page is 25
  end

  it "paginates results with custom per_page" do
    results = ClientSearchService.call('', page: 1, per_page: 10)
    expect(results.count).to eq(10)
  end

  it "returns correct results for second page" do
    total_clients = Client.count
    per_page = 25

    first_page_results = ClientSearchService.call('', page: 1, per_page: per_page)
    second_page_results = ClientSearchService.call('', page: 2, per_page: per_page)

    expect(second_page_results).not_to include(*first_page_results)

    # Calculate expected count for the second page
    expected_second_page_count = [ total_clients - per_page, 0 ].max
    expect(second_page_results.count).to eq(expected_second_page_count)
  end
end
