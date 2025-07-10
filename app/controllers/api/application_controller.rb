class Api::ApplicationController < ApplicationController
  before_action :authenticate_api_user!

  private

  def authenticate_api_user!
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.api_username &&
        password == Rails.application.credentials.api_password
    end
  end
end 