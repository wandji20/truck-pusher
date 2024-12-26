class Branch < ApplicationRecord
  include NameConstants

  # Validations
  validates :name, presence: true,
                  length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) },
                  uniqueness: { scope: :agency_id }

  # Associations
  belongs_to :agency
end
