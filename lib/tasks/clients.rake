namespace :clients do
  desc "Import clients from JSON file"
  task import: :environment do
    puts "Importing clients from JSON..."
    
    begin
      ClientImportService.call
      puts "Successfully imported #{Client.count} clients"
    rescue => e
      puts "Error importing clients: #{e.message}"
    end
  end

  desc "Search clients by name"
  task :search, [:query] => :environment do |task, args|
    query = args[:query]
    
    if query.blank?
      puts "Usage: rails clients:search[query]"
      puts "Example: rails clients:search[john]"
      exit 1
    end
    
    puts "Searching for clients with name containing '#{query}'..."
    clients = ClientSearchService.call(query)
    
    if clients.any?
      puts "Found #{clients.count} client(s):"
      clients.each do |client|
        puts "  - #{client.full_name} (#{client.email})"
      end
    else
      puts "No clients found matching '#{query}'"
    end
  end

  desc "Find clients with duplicate emails"
  task duplicates: :environment do
    puts "Finding clients with duplicate emails..."
    duplicate_emails = DuplicateEmailService.call
    
    if duplicate_emails.any?
      puts "Found #{duplicate_emails.count} email(s) with duplicates:"
      duplicate_emails.each do |email|
        clients = Client.where(email: email)
        puts "\nEmail: #{email}"
        clients.each do |client|
          puts "  - #{client.full_name} (ID: #{client.id})"
        end
      end
    else
      puts "No duplicate emails found"
    end
  end
end 