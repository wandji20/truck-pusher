class UserInvitationsController < ApplicationController
  skip_before_action :set_agency, only: %i[new create]
  allow_unauthenticated_access only: %i[edit update]
  before_action :set_user_by_token, only: %i[edit update]

  def new
    current_agency = find_agency_by_cookie
    set_current_tenant(current_agency)

    @user = Users::Admin.new
    respond_to do |format|
      format.json { render json: { html: render_to_string("user_invitations/new", layout: false, formats: :html) } }
    end
  end

  def create
    current_agency = find_agency_by_cookie
    set_current_tenant(current_agency)

    @user = current_user.invite_user(
      params.require(:users_admin).permit(:telephone, :role).merge(agency: current_agency)
    )

    if @user.persisted? && @user.errors.none?
      flash[:success] = t("user_invitations.sent", telephone: @user.escape_value(:telephone))
      redirect_back fallback_location: agency_setting_path(params: { option: "users" })
    else
      render turbo_stream: turbo_stream.replace("new-user", partial: "user_invitations/form",
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
      p @user.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = Users::Admin.find_by_token_for!(:invitation, params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to login_path(params: { agency_name: current_agency.name }), alert: t("user_invitations.invalid_token")
  end

  def set_agency
    @current_agency = Agency.find_by(name: params[:agency_name])

    unless @current_agency.present?
      flash[:alert] = t("user_invitations.invalid_url")
      return redirect_to root_path
    end

    set_current_tenant(@current_agency)
  end
end
