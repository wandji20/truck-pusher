class Campaigns::InvitationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.marketers.invitation_mailer.invite.subject
  #
  def invite(marketer)
    @token = marketer.generate_token_for(:invitation)
    attrs = {
      to: marketer.email,
      from:,
      template_alias: "user-invitaion",
      template_model: {
        subject: I18n.t("campaigns.invitation_mailer.subject"),
        title: I18n.t("campaigns.invitation_mailer.invite.title"),
        message: I18n.t("campaigns.invitation_mailer.invite.message"),
        invite_url: edit_campaigns_invitation_url(@token),
        invite_text: I18n.t("campaigns.invitation_mailer.invite.accept"),
        product_name:
      }
    }

    mail attrs
  end
end
