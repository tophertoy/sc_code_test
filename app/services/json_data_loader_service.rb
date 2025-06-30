class JsonDataLoaderService
  def self.call(file_path = nil)
    file_path ||= Rails.root.join("lib", "data", "clients.json")

    begin
      json_data = File.read(file_path)
      raw_data = JSON.parse(json_data)
    rescue JSON::ParserError => e
      return {
        success: false,
        error: "Invalid JSON format: #{e.message}",
        valid_records: [],
        invalid_records: []
      }
    rescue Errno::ENOENT => e
      return {
        success: false,
        error: "File not found: #{e.message}",
        valid_records: [],
        invalid_records: []
      }
    end

    unless raw_data.is_a?(Array)
      return {
        success: false,
        error: "Expected JSON array, got #{raw_data.class}",
        valid_records: [],
        invalid_records: []
      }
    end

    valid_records = []
    invalid_records = []

    raw_data.each_with_index do |record, index|
      if record.is_a?(Hash)
        valid_records << record
      else
        invalid_records << {
          record: record,
          index: index,
          errors: [ "Record must be a hash, got #{record.class}" ]
        }
      end
    end

    {
      success: true,
      valid_records: valid_records,
      invalid_records: invalid_records,
      total_records: raw_data.length,
      valid_count: valid_records.length,
      invalid_count: invalid_records.length
    }
  end
end
