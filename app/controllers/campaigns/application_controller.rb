module Campaigns
  class ApplicationController < ActionController::Base
    include MarketerAuthentication
    before_action :require_admin
    before_action :set_current_user
    # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
    allow_browser versions: :modern
    helper_method :current_user

    layout "campaigns"

    private

    def require_admin
      http_basic_authenticate_or_request_with name: Rails.application.credentials["app_username"] || "",
                                  password: Rails.application.credentials["app_password"] || ""
    end

    def set_current_user
      @current_user ||= Current.marketer

      if @current_user && !@current_user.confirmed
        redirect_to campaigns_login_path, notice: t("campaigns.invitations.unconfirmed_message")
      end
    end

    def current_user
      @current_user
    end
  end
end
