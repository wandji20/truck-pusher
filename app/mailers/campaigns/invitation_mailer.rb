class Campaigns::InvitationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.marketers.invitation_mailer.invite.subject
  #
  def invite(marketer)
    @token = marketer.generate_token_for(:invitation)

    mail subject: I18n.t("marketers.invitation_mailer.subject"), to: marketer.email
  end
end
