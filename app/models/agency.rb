class Agency < ApplicationRecord
  # Constants
  MIN_NAME_LENGTH = 5
  MAX_NAME_LENGTH = 256

  # Validations
  validates :name, presence: true,
                  length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) },
                  uniqueness: true

  # Associations
  has_many :branches, dependent: :destroy
end
