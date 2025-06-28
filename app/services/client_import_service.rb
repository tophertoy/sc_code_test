class ClientImportService
  def self.call
    clients_data = JsonDataLoaderService.call
    
    clients_data.each do |client_data|
      Client.create!(
        full_name: client_data['full_name'],
        email: client_data['email']
      )
    end
  end
end