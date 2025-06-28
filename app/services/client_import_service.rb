class ClientImportService
  def self.call
    result = JsonDataLoaderService.call
    
    return { success: false, error: result[:error] } unless result[:success]
    
    result[:valid_records].each do |client_data|
      Client.create!(
        full_name: client_data['full_name'],
        email: client_data['email']
      )
    end
    
    {
      success: true,
      imported_count: result[:valid_records].length,
      invalid_count: result[:invalid_records].length,
      total_processed: result[:total_records]
    }
  end
end