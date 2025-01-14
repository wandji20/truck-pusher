module Campaigns
  class SessionsController < ApplicationController
    allow_unauthenticated_access only: %i[ new create ]
    skip_before_action :require_admin
    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to root_path, alert: "Try again later." }

    def new; end

    def create
      if marketer = Marketer.authenticate_by(params.permit(:email, :password))
        start_new_session_for marketer
        redirect_to after_authentication_url
      else
        flash.now[:alert] = t("campaigns.sessions.invalid_credentials")
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      terminate_session
      redirect_to campaigns_login_path
    end
  end
end
