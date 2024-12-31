module DeliveriesHelper
  def active_nav_link(option)
    return "active" if params[:type] == option
    return "active" if params[:type].nil? && option == "all"

    ""
  end

  def delivery_type(delivery, user)
    return t("deliveries.table_row.incoming") if delivery.destination_id == user.branch_id
    return t("deliveries.table_row.outgoing") if delivery.origin_id == user.branch_id

    nil
  end
end
