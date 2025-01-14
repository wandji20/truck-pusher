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
  has_many :merchants, -> { where(category: "merchant") }, class_name: "Enterprise"
  has_many :sessions, dependent: :destroy

  generates_token_for :invitation, expires_in: 1.day

  def create_merchant(merchant_params, manager_params)
    password = SecureRandom.hex(8)
    merchant = merchants.build(merchant_params)
    manager = merchant.managers.build(
      manager_params.merge({ password:, password_confirmation: password })
    )

    ActiveRecord::Base.transaction  do
      merchant.save!
      manager.save!
      # send confirmation text message
    end
    [ merchant, manager ]
  rescue ActiveRecord::RecordInvalid
    [ merchant, manager ]
  end

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
