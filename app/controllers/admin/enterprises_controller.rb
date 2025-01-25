module Admin
  class EnterprisesController < ApplicationController
    before_action :set_enterprise, only: %i[edit update]

    def create
      enterprise, manager = Enterprise.create_new(enterprise_params, manager_params)

      if enterprise.persisted?
        flash[:success] = I18n.t("flash.create_success", name: enterprise.escape_value(:name))
        redirect_to admin_path
      else
        render turbo_stream: turbo_stream.replace("new_enterprise", partial: "admin/enterprises/form",
                                                  locals: { enterprise:, manager: }),
                              status: :unprocessable_entity
      end
    end

    def new
      @enterprise = Enterprise.new(category: nil)
      @manager = @enterprise.managers.new

      respond_to do |format|
        format.json { render json: { html: render_to_string("admin/enterprises/new", layout: false, formats: :html) } }
      end
    end

    def edit
      respond_to do |format|
        format.json { render json: { html: render_to_string("admin/enterprises/edit", layout: false, formats: :html) } }
      end
    end

    def update
      if @enterprise.update(enterprise_params)
        flash[:success] = I18n.t("flash.update_success", name: @enterprise.escape_value(:name))
        redirect_to admin_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def enterprise_params
      params.require(:enterprise).permit(:name, :category, :description)
    end

    def manager_params
      params.require(:manager).permit(:telephone)
    end

    def set_enterprise
      @enterprise = Enterprise.find(params[:id])
    end
  end
end
