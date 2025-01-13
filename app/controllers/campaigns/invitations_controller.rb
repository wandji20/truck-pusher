module Campaigns
  class InvitationsController < ApplicationController
    allow_unauthenticated_access
    skip_before_action :require_admin, only: %i[edit update]
    before_action :set_marketer_by_token, only: %i[edit update]

    def new
      @marketer = Marketer.new
      respond_to do |format|
        format.json do
          render json: { html: render_to_string("campaigns/invitations/new",
                                                 layout: false, formats: :html) }
        end
      end
    end

    def create
      @marketer = Marketer.invite_new(params.require(:marketer).permit(:email))

      if @marketer.persisted? && @marketer.errors.none?
        flash[:success] = t("campaigns.invitations.sent", email: @marketer.escape_value(:email))
        redirect_back fallback_location: admin_path(params: { option: "marketers" })
      else
        render turbo_stream: turbo_stream.replace("new_marketer", partial: "campaigns/invitations/new_form",
                                                    locals: { marketer: @marketer }),
                status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @marketer.update(
        params.require(:marketer)
              .permit(:password, :password_confirmation, :full_name).merge(confirmed: true)
      )
        start_new_session_for(@marketer)

        flash[:success] = t("campaigns.invitations.confirmed")
        redirect_to marketer_enterprises_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_marketer_by_token
      @marketer = Marketer.find_by_token_for!(:invitation, params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to campaigns_login_path, alert: t("campaigns.invitations.invalid_token")
    end
  end
end
