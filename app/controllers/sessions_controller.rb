class SessionsController < ApplicationController
  skip_before_action :set_enterprise, only: :destroy
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to root_path, alert: "Try again later." }

  def new; end

  def create
    if user = Users::Admin.authenticate_by(params.permit(:telephone, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      flash.now[:alert] = t("sessions.invalid_credentials")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @current_enterprise = find_enterprise_by_cookie

    terminate_session
    redirect_to login_path(params: { enterprise_name: @current_enterprise.name })
  end

  private

  def set_enterprise
    @current_enterprise = Enterprise.find_by(name: params[:enterprise_name])

    unless @current_enterprise.present?
      flash[:alert] = t("sessions.select_enterprise")
      return redirect_to root_path
    end

    set_current_tenant(@current_enterprise)
  end
end
