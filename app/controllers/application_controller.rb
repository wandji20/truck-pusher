class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :set_agency # Set current tenant before authentication
  include Authentication
  before_action :set_current_user
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user

  private

  def set_agency
    @current_agency = find_agency_by_cookie

    unless @current_agency.present?
      flash[:alert] = t("sessions.select_agency")
      return redirect_to root_path
    end

    set_current_tenant(@current_agency)
  end

  def find_agency_by_cookie
    Agency.find_by(id: cookies.signed[:agency_id]) if cookies.signed[:agency_id]
  end

  def set_current_user
    @current_user ||= Current.user
  end

  def current_user
    @current_user
  end
end
