module ApplicationHelper
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
