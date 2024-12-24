module ApplicationHelper
  def navigation_partial(agency)
    return "shared/empty" unless agency.present?

    "navbar/nav"
  end

  def home_path(agency)
    return root_path unless agency.present?

    deliveries_path
  end

  def navigations
    [
      { text: t("navigations.add_delivery"), icon: "folder_plus",
        url: new_delivery_path, details: [ "deliveries", "new" ] },
      { text: t("navigations.account"), icon: "user",
        url: account_path, details: [ "users", "edit" ] },
      { text: t("navigations.settings"), icon: "setting",
        url: agency_setting_path, details: [ "agencies", "edit" ] },
      { text: t("navigations.deliveries"), icon: "folder",
        url: deliveries_path, details: [ "deliveries", "index" ] }
    ]
  end

  def active_class(controller, action)
    # return when action is different from controller action
    return if action.presence != action_name
    # return when there is a controller name is different from the request controller name
    return if controller.present? && controller != controller_name

    "active"
  end

  def flash_alert_class(type)
    case type.to_s
    when "success", "notice"
      "alert-success"
    when "error", "alert"
      "alert-danger"
    else
      "alert-info"
    end
  end

  def flash_icon(type)
    case type.to_s
    when "error", "alert"
      "shared/svgs/exclamation_triangle"
    when "success", "notice"
      "shared/svgs/check_circle"
    else
      "shared/svgs/information_circle"
    end
  end
end
