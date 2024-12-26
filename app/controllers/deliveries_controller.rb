class DeliveriesController < ApplicationController
  def index
  end

  def new
  end

  private

  def set_agency
    # Attempt to set agency from cookies
    @current_agency = find_agency_by_cookie
    # Else set from params
    @current_agency ||= Agency.find_by(name: params[:agency_name])

    unless @current_agency.present?
      flash[:alert] = t("sessions.select_agency")
      return redirect_to root_path
    end

    set_current_tenant(@current_agency)
  end
end
