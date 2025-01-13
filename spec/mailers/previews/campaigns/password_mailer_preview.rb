# Preview all emails at http://localhost:3000/rails/mailers/campaigns/password_mailer
class Campaigns::PasswordMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/campaigns/password_mailer/reset
  def reset
    Campaigns::PasswordMailer.reset(Marketer.first)
  end
end
