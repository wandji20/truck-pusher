module DeliveriesHelper
  def active_nav_link(option)
    return "active" if params[:type] == option
    return "active" if params[:type].nil? && option == "all"

    ""
  end
end
