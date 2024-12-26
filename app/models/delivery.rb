class Delivery < ApplicationRecord
  # Validations
  validates :tracking_number, :tracking_secret, presence: true
  validates :tracking_number, :tracking_secret, uniqueness: { scope: :agency_id }

  # Enums
  enum :status, %i[registered sent checked_in checked_out]

  # Associations
  acts_as_tenant :agency
  belongs_to :origin, class_name: "Branch"
  belongs_to :destination, class_name: "Branch"

  belongs_to :sender, class_name: "Users::Customer"
  belongs_to :receiver, class_name: "Users::Customer"

  belongs_to :registered_by, class_name: "Users::Admin"
  belongs_to :checked_in_by, class_name: "Users::Admin", optional: true
  belongs_to :checked_out_by, class_name: "Users::Admin", optional: true
end
