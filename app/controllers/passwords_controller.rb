class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  before_action :verify_invitation_token, only: %i[ edit update ]

  def new; end

  def create
    if user = Users::Admin.find_by(telephone: params[:telephone])
      if user.invited_at.present?
        redirect_to root_path, alert: t("passwords.confirm_account")
        return
      end
      # p edit_password_url(user.password_reset_token, params: { enterprise_name: params[:enterprise_name] })
      # send reset instructions via text
      redirect_to root_path, notice: t("passwords.instruction_sent")
    else
      redirect_to root_path, alert: t("passwords.invalid_telephone")
    end
  end

  def edit; end

  def update
    if @user.update(password_params)
      redirect_to login_path(params: { enterprise_name: params[:enterprise_name] }), notice: t("passwords.reset_successful")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = Users::Admin.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, alert: t("passwords.invalid_token")
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def verify_invitation_token
    if @user.invited_at.present?
      redirect_to root_path, alert: t("passwords.confirm_account")
    end
  end

  def set_enterprise
    @current_enterprise = Enterprise.find_by(name: params[:enterprise_name])

    unless @current_enterprise.present?
      flash[:alert] = t("passwords.invalid_url")
      return redirect_to root_path
    end

    set_current_tenant(@current_enterprise)
  end
end
