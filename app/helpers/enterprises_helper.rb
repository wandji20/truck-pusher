module EnterprisesHelper
  def active_nav_link(option)
    return "active" if params[:option] == option
    return "active" if params[:option].nil? && option == "branches"
    return "active" if params[:option].nil? && option == "enterprises"

    ""
  end

  def enterprise_categories
    Enterprise.categories.except(:special).keys.map do |category|
      [ category, t("admin.enterprises.categories.#{category}") ]
    end
  end
end
