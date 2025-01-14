module Admin
  class HomeController < ApplicationController
    def index
      @enterprises = Enterprise.not_special.order(:created_at)
      @marketers = Marketer.order(:created_at)
    end
  end
end
