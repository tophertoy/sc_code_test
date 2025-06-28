class JsonDataLoaderService
  def self.call
    file_path = Rails.root.join('lib', 'data', 'clients.json')
    json_data = File.read(file_path)
    JSON.parse(json_data)
  end
end