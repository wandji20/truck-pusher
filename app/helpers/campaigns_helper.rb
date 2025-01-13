module CampaignsHelper
  def campaign_navigations
    [
      { text: t("campaigns.navigations.add_merchant"), icon: "plus", url: new_campaigns_merchant_path,
        active: active_class("merchants", "new") || active_class("merchants", "create") },
      { text: t("campaigns.navigations.account"), icon: "user", url: campaigns_account_path,
        active: active_class("marketers", "edit") || active_class("marketers", "update") },
      { text: t("campaigns.navigations.merchants"), icon: "building", url: campaigns_merchants_path,
      active: active_class("merchants", "index") }
    ]
  end
end
