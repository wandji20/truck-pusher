class AgenciesController < ApplicationController
  allow_unauthenticated_access only: :index
  skip_before_action :set_agency, only: :index

  def index
    @agencies = Agency.order(:created_at)
  end

  def edit
    @branches = Branch.order(:name)
    @users = Users::Admin.left_outer_joins([ :branch, :invited_by ])
                         .where(archived: false)
                         .select("users.*, branches.name AS branch_name,
                                  invited_bies_users.full_name AS invited_by_name")
                         .order(:created_at)
  end

  def remove_user
    authorize! :manage, @current_agency

    user = Users::Admin.find(params[:user_id])
    user.update_column(:archived, true)

    render turbo_stream: turbo_stream.remove(user)
  end
end
