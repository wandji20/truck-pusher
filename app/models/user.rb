class User < ApplicationRecord
  include NameConstants

  # Validations
  validates :full_name, presence: true,
                  length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) }

  # Secure password
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Hooks
  normalizes :telephone, with: ->(e) { e.strip }
end
