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

  def confirm_arrival
    delivery = Delivery.find(params[:id])

    if delivery.confirm_arrival(current_user)
      message = t("deliveries.confirm.success")
      render turbo_stream: [ turbo_stream.replace("delivery_#{delivery.id}", partial: "deliveries/table_row", locals: { delivery: }),
                              turbo_stream.append("flash-notifications", partial: "shared/flash_message", locals: { message:, type: :success }) ]
    else
      message = t("deliveries.confirm.fail")
      render turbo_stream: turbo_stream.append("flash-notifications", partial: "shared/flash_message", locals: { message:, type: :alert })
    end
  end

  def confirm_delivery
    delivery = Delivery.find(params[:id])
    if delivery.confirm_delivery(current_user)
      message = t("deliveries.deliver.success")
      render turbo_stream: [ turbo_stream.replace("delivery_#{delivery.id}", partial: "deliveries/table_row", locals: { delivery: }),
                              turbo_stream.append("flash-notifications", partial: "shared/flash_message", locals: { message:, type: :success }) ]
    else
      message = t("deliveries.deliver.fail")
      render turbo_stream: turbo_stream.append("flash-notifications", partial: "shared/flash_message", locals: { message:, type: :alert })
    end
  end

  private

  def set_enterprise
    # Attempt to set enterprise from cookies
    @current_enterprise = find_enterprise_by_cookie
    # Else set from params
    @current_enterprise ||= Enterprise.find_by(name: params[:enterprise_name])

    unless @current_enterprise.present?
      flash[:alert] = t("sessions.select_enterprise")
      return redirect_to root_path
    end

    set_current_tenant(@current_enterprise)
  end

  def search_deliveries
    @deliveries = if @current_enterprise.special?
      ActsAsTenant.without_tenant do
        Delivery.joins(:enterprise)
                .where("(origin_id = ? OR destination_id = ?) AND enterprises.category != ?",
                        @current_user.branch_id, @current_user.branch_id, 0)
      end
    else
      Delivery.where("origin_id = ? OR destination_id = ?", @current_user.branch_id, @current_user.branch_id)
    end

    @deliveries = @deliveries.joins([ :receiver, :destination ])
                              .select("deliveries.id, deliveries.enterprise_id, deliveries.origin_id, deliveries.destination_id,
                                        deliveries.tracking_number, deliveries.tracking_secret, deliveries.description,
                                        deliveries.status, deliveries.created_at, users.full_name AS receiver_name,
                                        users.telephone AS receiver_telephone, branches.name AS destination_name")
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

  def set_enterprise
    @current_enterprise = Enterprise.find_by(name: params[:enterprise_name]) || find_enterprise_by_cookie

    unless @current_enterprise.present?
      flash[:alert] = t("sessions.select_enterprise")
      return redirect_to root_path
    end

    set_current_tenant(@current_enterprise)
  end

  MyCustomer = Struct.new(:id, :full_name, :telephone)
end
