class AgenciesController < ApplicationController
  allow_unauthenticated_access only: :index
  skip_before_action :set_agency, only: :index

  def index
    @agencies = Agency.order(:created_at)
  end

  def edit; end
end
