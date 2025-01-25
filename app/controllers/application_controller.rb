class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :set_enterprise # Set current tenant before authentication
  include Authentication
  before_action :set_current_user
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user

  private

  def set_enterprise
    @current_enterprise = find_enterprise_by_cookie

    unless @current_enterprise.present?
      flash[:alert] = t("sessions.select_enterprise")
      return redirect_to root_path
    end

    set_current_tenant(@current_enterprise)
  end

  def find_enterprise_by_cookie
    Enterprise.find_by(id: cookies.signed[:enterprise_id]) if cookies.signed[:enterprise_id]
  end

  def set_current_user
    @current_user ||= Current.user

    if @current_user && !@current_user.confirmed
      redirect_to login_path(params: { enterprise_name: @current_enterprise.name }), notice: t("user_invitations.unconfirmed_message")
    end
  end

  def current_user
    @current_user
  end
end
