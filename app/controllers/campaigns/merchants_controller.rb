module Campaigns
  class MerchantsController < ApplicationController
    skip_before_action :require_admin
    before_action :set_merchant, only: %i[edit update location]

    def index
      @merchants = @current_user.merchants.order(:created_at)
    end

    def new
      @merchant = @current_user.merchants.new
      @manager = @merchant.managers.new
      authorize! :create_merchant, @merchant
    end

    def create
      @merchant = @current_user.merchants.new
      authorize! :create_merchant, @merchant

      @merchant, @manager = @current_user.create_merchant(merchant_params, manager_params)

      if @merchant.persisted?
        redirect_to edit_campaigns_merchant_path(@merchant)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :create_merchant, @merchant
    end

    def update
      authorize! :create_merchant, @merchant

      if @merchant.update(merchant_params)
        flash[:success] = t("flash.update_success", name: @merchant.escape_value(:name))
        redirect_to edit_campaigns_merchant_path(@merchant)
      else
        render :edit, status: :upprocessable_entity
      end
    end

    def location
      if params[:latitude] && params[:longitude]
        @merchant.update(location: { latitude: params[:latitude], longitude: params[:longitude] })
        flash[:success] = t("flash.update_success", name: t("campaigns.merchants.location"))
        redirect_to edit_campaigns_merchant_path(@merchant)
      else
        flash[:error] = t("flash.update_fail", name: t("campaigns.merchants.location"))
        redirect_to edit_campaigns_merchant_path(@merchant)
      end
    end

    private

    def set_merchant
      @merchant = @current_user.merchants.find(params[:id])
    end

    def merchant_params
      params.require(:enterprise).permit(:name, :category, :description, :city)
    end

    def manager_params
      params.require(:manager).permit(:telephone)
    end
  end
end
