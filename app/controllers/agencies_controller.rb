class AgenciesController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :set_agency

  def index
    @agencies = Agency.order(:created_at)
  end
end
