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
  task :search, [:query, :page, :per_page] => :environment do |task, args|
    query = args[:query] || ''
    page = args[:page] || 1
    per_page = args[:per_page] || 25
    
    if query.nil?
      puts "Usage: rails clients:search[query,page,per_page]"
      puts "Example: rails clients:search[john,1,25]"
      puts "Example: rails clients:search['',1,25] (empty query returns all clients)"
      exit 1
    end
    
    search_description = query.empty? ? "all clients" : "clients with name containing '#{query}'"
    puts "Searching for #{search_description}..."
    clients = ClientSearchService.call(query, page: page, per_page: per_page)
    
    if clients.any?
      puts "Found #{clients.count} client(s) on page #{page}:"
      clients.each do |client|
        puts "  - #{client.full_name} (#{client.email})"
      end
    else
      if query.empty?
        puts "No clients found on page #{page}"
      else
        puts "No clients found matching '#{query}' on page #{page}"
      end
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