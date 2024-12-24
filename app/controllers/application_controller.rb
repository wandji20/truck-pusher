class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :set_agency # Set current tenant before authentication
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_agency
    current_agency = Current.agency

    raise ActiveRecord::RecordNotFound unless current_agency.present?

    set_current_tenant(current_agency)
  end
end
