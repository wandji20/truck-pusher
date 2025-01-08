module AgenciesHelper
  def active_nav_link(option)
    return "active" if params[:option] == option
    return "active" if params[:option].nil? && option == "branches"

    ""
  end
end
