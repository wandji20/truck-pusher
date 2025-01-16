module Admin
  class ApplicationController < ActionController::Base
    before_action :require_admin
    layout "application"

    private

    def require_admin
      http_basic_authenticate_or_request_with name: Rails.application.credentials.dig(:basic_auth, :username),
                                  password: Rails.application.credentials.dig(:basic_auth, :password)
    end
  end
end
