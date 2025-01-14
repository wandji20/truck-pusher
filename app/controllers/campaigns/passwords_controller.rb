module Campaigns
  class PasswordsController < ApplicationController
    skip_before_action :require_admin
    allow_unauthenticated_access
    before_action :set_marketer_by_token, only: %i[ edit update ]
    before_action :verify_invitation_token, only: %i[ edit update ]

    def new; end

    def create
      if marketer = Marketer.find_by(email: params[:email])
        if !marketer.confirmed
          redirect_to campaigns_login_path, alert: t("campaigns.passwords.confirm_account")
          return
        end

        Campaigns::PasswordMailer.reset(marketer).deliver_later
        redirect_to campaigns_login_path, notice: t("campaigns.passwords.instruction_sent")
      else
        redirect_to campaigns_login_path, alert: t("campaigns.passwords.invalid_email")
      end
    end

    def edit; end

    def update
      if @marketer.update(password_params)
        redirect_to campaigns_login_path, notice: t("campaigns.passwords.reset_successful")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_marketer_by_token
      @marketer = Marketer.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to campaigns_login_path, alert: t("campaigns.passwords.invalid_token")
    end

    def password_params
      params.permit(:password, :password_confirmation)
    end

    def verify_invitation_token
      if !@marketer.confirmed
        redirect_to campaigns_login_path, alert: t("campaigns.passwords.confirm_account")
      end
    end
  end
end
