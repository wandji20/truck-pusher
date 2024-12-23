class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :telephone, with: ->(e) { e.strip }
end
