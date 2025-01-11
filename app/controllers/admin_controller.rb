class AdminController < ActionController::Base
  http_basic_authenticate_with name: Rails.application.credentials["app_username"] || "",
                                password: Rails.application.credentials["app_password"] || ""
  before_action :set_enterprise, only: %i[edit update]
  layout "application"

  def index
    @enterprises = Enterprise.all
  end

  def create
    @enterprise, @manager = Enterprise.create_new(enterprise_params, manager_params)

    if @enterprise.persisted?
      redirect_to admin_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @enterprise = Enterprise.new
    @manager = @enterprise.managers.new
  end

  def edit; end

  def update
    if @enterprise.update(enterprise_params)
      redirect_to admin_index_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def enterprise_params
    params.require(:enterprise).permit(:name)
  end

  def manager_params
    params.require(:manager).permit(:telephone)
  end

  def set_enterprise
    @enterprise = Enterprise.find(params[:id])
  end
end
