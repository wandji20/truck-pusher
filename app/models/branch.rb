class Branch < ApplicationRecord
  include NameConstants

  # Validations
  validates :name, presence: true,
                  length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) },
                  uniqueness: { scope: :agency_id }

  # Associations
  acts_as_tenant :agency
  has_many :operators, -> { where(role: "operator") },
                        class_name: "Users::Admin",
                        dependent: :destroy
end
