class Campaigns::PasswordMailer < ApplicationMailer
  def reset(marketer)
    @token = marketer.password_reset_token

    attrs = {
      to: marketer.email,
      from:,
      template_alias: "user-invitaion",
      template_model: {
        subject: I18n.t("campaigns.password_mailer.subject"),
        title: I18n.t("campaigns.password_mailer.reset.title"),
        reset_url: edit_campaigns_password_url(@token),
        reset_text: I18n.t("campaigns.password_mailer.reset.reset"),
        message: I18n.t("campaigns.password_mailer.reset.message"),
        product_name:
      }
    }

    mail attrs
  end
end
