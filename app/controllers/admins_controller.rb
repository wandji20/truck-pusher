class AdminsController < ApplicationController
  def edit; end

  def update
    if current_user.update(admin_params)
      flash[:success] = t("flash.update_success", name: t("admins.account"))
      redirect_to account_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def admin_params
    params.require(:users_admin).permit(:telephone, :full_name)
  end
end
