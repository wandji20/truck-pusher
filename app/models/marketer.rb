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
  has_many :enterprises
end
