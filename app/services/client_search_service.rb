class ClientSearchService
  def self.call(query)
    Client.where("full_name ILIKE ?", "%#{query}%")
  end
end 