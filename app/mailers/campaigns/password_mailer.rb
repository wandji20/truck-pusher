class Campaigns::PasswordMailer < ApplicationMailer
  def reset(marketer)
    @token = marketer.password_reset_token

    mail subject: I18n.t("campaigns.password_mailer.subject"), to: marketer.email
  end
end
