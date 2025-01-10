class AdminController < ActionController::Base
  http_basic_authenticate_with name: Rails.application.credentials["app_username"] || "",
                                password: Rails.application.credentials["app_password"] || ""
  before_action :set_agency, only: %i[edit update]
  layout "application"

  def index
    @agencies = Agency.all
  end

  def create
    @agency, @manager = Agency.create_new(agency_params, manager_params)

    if @agency.persisted?
      redirect_to admin_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @agency = Agency.new
    @manager = @agency.managers.new
  end

  def edit; end

  def update
    if @agency.update(agency_params)
      redirect_to admin_index_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def agency_params
    params.require(:agency).permit(:name)
  end

  def manager_params
    params.require(:manager).permit(:telephone)
  end

  def set_agency
    @agency = Agency.find(params[:id])
  end
end
