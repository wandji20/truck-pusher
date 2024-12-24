class SessionsController < ApplicationController
  skip_before_action :set_agency, only: :destroy
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  def set_agency
    current_agency = Agency.find_by(name: params[:agency_name])

    raise ActiveRecord::RecordNotFound unless current_agency.present?

    set_current_tenant(current_agency)
  end
end
