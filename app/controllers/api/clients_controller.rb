class Api::ClientsController < Api::ApplicationController
  def search
    query = params[:q] || ""
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 25

    clients = ClientSearchService.call(query, page: page, per_page: per_page)

    render json: {
      query: query,
      page: page,
      per_page: per_page,
      total_count: clients.total_count,
      total_pages: clients.total_pages,
      current_page: clients.current_page,
      clients: clients.map do |client|
        {
          id: client.id,
          full_name: client.full_name,
          email: client.email,
          created_at: client.created_at,
          updated_at: client.updated_at
        }
      end
    }
  end

  def duplicates
    duplicate_data = DuplicateEmailService.call(include_clients: true)

    render json: { duplicate_emails: duplicate_data }
  end
end 