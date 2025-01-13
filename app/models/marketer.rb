class Marketer < ApplicationRecord
  # Constants
  include NameConstants
  MIN_PASSWORD_LENGTH = 6
  MAX_PASSWORD_LENGTH = 128

  # validations
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true,
                        length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) },
                        if: -> { full_name.present? }
  validates :password, presence: true,
                       length: { within: (MIN_PASSWORD_LENGTH..MAX_PASSWORD_LENGTH) },
                       if: -> { password.present? }

  # Hooks
  normalizes :email, with: ->(e) { e.strip.downcase }

  has_secure_password

  # Associations
  has_many :enterprises, -> { where(category: "merchant") }
  has_many :sessions, dependent: :destroy

  generates_token_for :invitation, expires_in: 1.day

  def self.invite_new(params)
    new_marketer = if marketer = Marketer.where(confirmed: false).find_by(email: params[:email])
          marketer
    else
      password = SecureRandom.hex(8)
      Marketer.new(params.merge({ password:, password_confirmation: password }))
    end

    ActiveRecord::Base.transaction do
      new_marketer.save!

      Campaigns::InvitationMailer.invite(new_marketer).deliver_later
    end
    new_marketer
  rescue ActiveRecord::RecordInvalid
    new_marketer
  end
end
