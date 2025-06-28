class AddSearchIndexesToClients < ActiveRecord::Migration[8.0]
  def change
    # Index for full_name searches (most important for ClientSearchService)
    add_index :clients, :full_name
    
    # Index for email lookups and duplicate detection
    add_index :clients, :email
  end
end
