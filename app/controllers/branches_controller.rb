class BranchesController < ApplicationController
  before_action :set_branch, only: %i[edit update]
  before_action -> { authorize! :manage, @current_agency }

  def new
    @branch = Branch.new
    respond_to do |format|
      format.json { render json: { html: render_to_string("branches/new", layout: false, formats: :html) } }
    end
  end

  def create
    @branch = Branch.create_new(branch_params.merge({ agency: @current_agency, user: current_user }))
    if @branch.persisted?
      redirect_to agency_setting_path
    else
      render turbo_stream: turbo_stream.replace("new-branch", partial: "branches/form",
                                                  locals: { branch: @branch, id: "new-branch" }),
            status: :unprocessable_entity
    end
  end

  def edit
    respond_to do |format|
      format.json { render json: { html: render_to_string("branches/edit", layout: false, formats: :html) } }
    end
  end

  def update
    if @branch.update(branch_params)
      redirect_to agency_setting_path
    else
      render turbo_stream: turbo_stream.replace("edit_branch_#{@branch.id}",
                                                  partial: "branches/form",
                                                  locals: { branch: @branch, id: "edit_branch_#{@branch.id}" }),
            status: :unprocessable_entity
    end
  end

  private

  def branch_params
    params.require(:branch).permit(:name, :telephone)
  end

  def set_branch
    @branch = Branch.find(params[:id])
  end
end
