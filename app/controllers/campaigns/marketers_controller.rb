module Campaigns
  class MarketersController < ApplicationController
    skip_before_action :require_admin

    def edit
    end

    def update
      if current_user.update(params.require(:marketer).permit(:full_name))
        flash[:success] = t("flash.update_success", name: t("campaigns.marketers.account"))
        redirect_to campaigns_account_path
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
