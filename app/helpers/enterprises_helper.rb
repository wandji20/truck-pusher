module EnterprisesHelper
  def active_nav_link(option)
    return "active" if params[:option] == option
    return "active" if params[:option].nil? && option == "branches"
    return "active" if params[:option].nil? && option == "enterprises"

    ""
  end
end
