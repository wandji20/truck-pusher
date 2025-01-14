class UserInvitationsController < ApplicationController
  skip_before_action :set_enterprise, only: %i[new create]
  allow_unauthenticated_access only: %i[edit update]
  before_action :set_user_by_token, only: %i[edit update]

  def new
    current_enterprise = find_enterprise_by_cookie
    set_current_tenant(current_enterprise)
    authorize! :manage, current_enterprise

    @user = Users::Admin.new
    respond_to do |format|
      format.json { render json: { html: render_to_string("user_invitations/new", layout: false, formats: :html) } }
    end
  end

  def create
    current_enterprise = find_enterprise_by_cookie
    set_current_tenant(current_enterprise)
    authorize! :manage, current_enterprise

    @user = current_user.invite_user(
      params.require(:users_admin).permit(:telephone, :role, :branch_id).merge(enterprise: current_enterprise)
    )

    if @user.persisted? && @user.errors.none?
      flash[:success] = t("user_invitations.sent", telephone: @user.escape_value(:telephone))
      redirect_back fallback_location: enterprise_setting_path(params: { option: "users" })
    else
      render turbo_stream: turbo_stream.replace("new-user", partial: "user_invitations/new_form",
                                                  locals: { user: @user, id: "new-user", url: user_invitations_path }),
              status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(
      params.require(:users_admin)
            .permit(:password, :password_confirmation, :full_name).merge(confirmed: true)
    )
      start_new_session_for(@user)

      flash[:success] = t("user_invitations.confirmed")
      redirect_to deliveries_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = Users::Admin.find_by_token_for!(:invitation, params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to login_path(params: { enterprise_name: current_enterprise.name }), alert: t("user_invitations.invalid_token")
  end

  def set_enterprise
    @current_enterprise = Enterprise.find_by(name: params[:enterprise_name])

    unless @current_enterprise.present?
      flash[:alert] = t("user_invitations.invalid_url")
      return redirect_to root_path
    end

    set_current_tenant(@current_enterprise)
  end
end
