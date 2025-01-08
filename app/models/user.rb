class User < ApplicationRecord
  include NameConstants
  MIN_PASSWORD_LENGTH = 6
  MAX_PASSWORD_LENGTH = 128

  # Validations
  validates :telephone, presence: true, format: { with: /\A\d{9}\z/ }
  validates :telephone, uniqueness: { scope: :agency_id, case_sensitive: false }
  validates :password, presence: true,
            length: { within: (MIN_PASSWORD_LENGTH..MAX_PASSWORD_LENGTH) }

  # Secure password
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Hooks
  normalizes :telephone, with: ->(e) { e.strip }
end
