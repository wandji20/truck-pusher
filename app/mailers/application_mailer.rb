class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  private

  def product_name
    Rails.application.credentials.app_name
  end

  def from
    "#{Rails.application.credentials.app_name} <#{Rails.application.credentials.default_email}>"
  end
end
