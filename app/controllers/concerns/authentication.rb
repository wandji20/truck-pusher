module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      # Ensure params are included in login url
      # Enterprise name is passed in params when attempting to view deliveries from enterprise list
      # in root url
      flash[:error] = t("sessions.login_required")
      redirect_to login_path(params: params.permit(:enterprise_name))
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || deliveries_path
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
        cookies.signed.permanent[:enterprise_id] = { value: session.enterprise_id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
      cookies.delete(:enterprise_id)
    end
end
