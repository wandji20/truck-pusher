module Admin
  class ApplicationController < ActionController::Base
    before_action :require_admin
    layout "application"

    private

    def require_admin
      http_basic_authenticate_or_request_with name: Rails.application.credentials["app_username"] || "",
                                  password: Rails.application.credentials["app_password"] || ""
    end
  end
end
