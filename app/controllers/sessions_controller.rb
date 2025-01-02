class SessionsController < ApplicationController
  skip_before_action :set_agency, only: :destroy
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
    @current_agency = find_agency_by_cookie

    terminate_session
    redirect_to login_path(params: { agency_name: @current_agency.name })
  end

  private

  def set_agency
    @current_agency = Agency.find_by(name: params[:agency_name])

    unless @current_agency.present?
      flash[:alert] = t("sessions.select_agency")
      return redirect_to root_path
    end

    set_current_tenant(@current_agency)
  end
end
