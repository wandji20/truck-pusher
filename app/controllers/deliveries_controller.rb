class DeliveriesController < ApplicationController
  def index
    search_deliveries
  end

  def new
    @branches = filter_branches
    @delivery = Delivery.new(registered_by: current_user)
  end

  def create
    @delivery = current_user.create_delivery(delivery_params)

    if @delivery.persisted?
      redirect_to deliveries_path
    else
      @branches = (Branch.where(id: @delivery.destination_id) +
                    filter_branches.where.not(id: [ @delivery.destination_id ])).take(10)
      @senders = Users::Customer.where(id: @delivery.sender_id)
      @receivers = Users::Customer.where(id: @delivery.receiver_id)
      render :new, status: :unprocessable_entity
    end
  end

  def search_branch
    return head :bad_request unless [ "origin", "destination" ].include?(params[:type])

    branches = filter_branches
    render turbo_stream: turbo_stream.replace("#{params[:type]}-options", partial: "deliveries/search/branch",
      locals: { branches:,  selected: params[:selected], type: "#{params[:type]}",
                name: "delivery[#{params[:type]}_id]", list_class: branches.length == 0 ? "hidden" : "" })
  end

  def search_customer
    return head :bad_request unless [ "sender", "receiver" ].include?(params[:type])

    render turbo_stream: turbo_stream.replace("#{params[:type]}-options", partial: "deliveries/search/customer",
      locals: { customers: filter_customers,  selected: params[:selected],
                type: "#{params[:type]}", name: "delivery[#{params[:type]}_id]" })
  end

  private

  def set_agency
    # Attempt to set agency from cookies
    @current_agency = find_agency_by_cookie
    # Else set from params
    @current_agency ||= Agency.find_by(name: params[:agency_name])

    unless @current_agency.present?
      flash[:alert] = t("sessions.select_agency")
      return redirect_to root_path
    end

    set_current_tenant(@current_agency)
  end

  def search_deliveries
    @deliveries = Delivery.where(origin_id: @current_user.branch_id)
                          .or(Delivery.where(destination_id: @current_user.branch_id))

    @deliveries = @deliveries.joins([ :sender, :receiver ])
                              .select("deliveries.id, deliveries.agency_id, deliveries.origin_id, deliveries.destination_id,
                                        deliveries.tracking_number, deliveries.tracking_secret, deliveries.description,
                                        deliveries.status, deliveries.created_at, users.full_name AS sender_name,
                                        users.telephone AS sender_telephone, receivers_deliveries.full_name AS receiver_name,
                                        receivers_deliveries.telephone AS receiver_telephone")
                              .order("deliveries.id": :desc)
    if params[:q].present?
      query = Delivery.sanitize_sql_like(params[:q] || "")
      @deliveries = @deliveries.where(
        "deliveries.tracking_number LIKE ? OR deliveries.tracking_secret LIKE ?", "%#{query}%", "%#{query}%"
      )
    end
  end

  def filter_customers
    query = User.sanitize_sql_like(params[:search])
    selected_ids = Array(params[:selected]).reject(&:blank?)
    customers = Users::Customer.where(id: params[:selected])
    customers += Users::Customer.where("telephone LIKE ?", "%#{query}%")
                                .where.not(id: selected_ids)
                                .limit(10)

    if params[:search] && !customers.present?
      customers = [ MyCustomer.new("new", t("deliveries.add_customer"), params[:search]) ]
    end

    customers
  end

  def filter_branches
    query = Branch.sanitize_sql_like(params[:search] || "")
    Branch.where("name LIKE ?", "%#{query}%")
          .where.not(id: current_user.branch_id)
          .or(Branch.where(id: params[:selected]))
          .order(:name)
          .limit(10)
  end

  def delivery_params
    attrs = params.require(:delivery).permit(:sender_id, :receiver_id, :destination_id, :description)

    attrs.merge!({ sender: sender_params }) if params[:new_sender] == "1"
    attrs.merge!({ receiver: receiver_params }) if params[:new_receiver] == "1"

    attrs
  end

  def sender_params
    params.require(:sender).permit(:full_name, :telephone)
  end

  def receiver_params
    params.require(:receiver).permit(:full_name, :telephone)
  end

  MyCustomer = Struct.new(:id, :full_name, :telephone)
end
