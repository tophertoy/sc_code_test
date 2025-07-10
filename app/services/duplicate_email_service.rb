class DuplicateEmailService
  def initialize(include_clients: false)
    @include_clients = include_clients
  end

  def call
    duplicate_emails = find_duplicate_emails
    
    return duplicate_emails unless @include_clients
    
    create_duplicate_data(duplicate_emails)
  end

  def self.call(include_clients: false)
    new(include_clients: include_clients).call
  end

  private

  def find_duplicate_emails
    Client.group(:email).having("count(*) > 1").pluck(:email).sort
  end

  def create_duplicate_data(duplicate_emails)
    grouped_clients = group_clients_by_email(duplicate_emails)
    
    grouped_clients.sort.to_h.map do |email, clients|
      create_email_group(email, clients)
    end
  end

  def group_clients_by_email(duplicate_emails)
    Client.where(email: duplicate_emails)
          .order(:email, :id)
          .group_by(&:email)
  end

  def create_email_group(email, clients)
    {
      email: email,
      count: clients.count,
      clients: serialize_clients(clients)
    }
  end

  def serialize_clients(clients)
    clients.sort_by(&:id).map do |client|
      {
        id: client.id,
        full_name: client.full_name,
        created_at: client.created_at,
        updated_at: client.updated_at
      }
    end
  end
end
