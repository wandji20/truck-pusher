class DeliveriesController < ApplicationController
  def index
    @deliveries = if params[:type] == "incoming"
      Delivery.where(destination_id: @current_user.branch_id)
    elsif params[:type] == "outgoing"
      Delivery.where(origin_id: @current_user.branch_id)
    else
      Delivery.where(origin_id: @current_user.branch_id).or(Delivery.where(destination_id: @current_user.branch_id))
    end

    @deliveries = @deliveries.joins([ :sender, :receiver ])
                              .select("deliveries.id, deliveries.agency_id, deliveries.origin_id, deliveries.destination_id,
                                        deliveries.tracking_number, deliveries.tracking_secret,
                                        deliveries.status, deliveries.created_at, users.full_name AS sender_name,
                                        users.telephone AS sender_telephone, receivers_deliveries.full_name AS receiver_name,
                                        receivers_deliveries.telephone AS receiver_telephone")
                              .order("deliveries.id": :desc)
    if params[:q].present?
      query = Delivery.sanitize_sql_like(params[:q].strip)
      @deliveries = @deliveries.where("deliveries.tracking_number = ? OR deliveries.tracking_secret = ?", query, query)
    end
  end

  def new
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
end
