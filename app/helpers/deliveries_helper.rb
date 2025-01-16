module DeliveriesHelper
  def delivery_type(delivery, user)
    return t("deliveries.table_row.incoming") if delivery.destination_id == user.branch_id
    return t("deliveries.table_row.outgoing") if delivery.origin_id == user.branch_id

    nil
  end

  def user_roles
    Users::Admin.roles.keys.map { |role| [ role, t("admins.roles.#{role}") ] }
  end

  def delivery_headers(enterprise)
    Delivery::HEADERS.select do |header|
      if enterprise.merchant?
        !(header.in?(%w[tracking_secret action]))
      else
        header != "status"
      end
    end
  end
end
