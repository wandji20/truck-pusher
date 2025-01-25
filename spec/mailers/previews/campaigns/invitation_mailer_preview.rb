# Preview all emails at http://localhost:3000/rails/mailers/campaigns/invitation_mailer
class Campaigns::InvitationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/campaigns/invitation_mailer/invite
  def invite
    marketer = Marketer.first
    Marketers::InvitationMailer.invite(marketer)
  end
end
