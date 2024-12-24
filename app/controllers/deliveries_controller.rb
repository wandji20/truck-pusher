class DeliveriesController < ApplicationController
  def index
  end

  private

  def set_agency
    # Attempt to set agency from Current object
    current_agency = Current.agency
    # Else set from params
    current_agency = Agency.find_by(name: params[:agency_name])

    unless current_agency.present?
      flash[:alert] = t("sessions.select_agency")
      return redirect_to root_path
    end

    set_current_tenant(current_agency)
  end
end
