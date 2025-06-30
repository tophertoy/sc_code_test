class ClientSearchService
  def self.call(query, page: 1, per_page: 25)
    Client.where("full_name ILIKE ?", "%#{query}%").page(page).per(per_page)
  end
end
