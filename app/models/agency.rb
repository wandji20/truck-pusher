class Agency < ApplicationRecord
  include NameConstants

  # Validations
  validates :name, presence: true,
                  length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) },
                  uniqueness: true

  # Associations
  has_many :branches, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :managers, -> { where(role: "manager") },
                      class_name: "Users::Admin",
                      dependent: :destroy
end
