class Delivery < ApplicationRecord
  # Constants
  HEADERS = [ "tracking_no", "tracking_secret", "sender", "receiver", "type", "description", "action" ].freeze
  # Validations
  validates :tracking_number, :tracking_secret, presence: true
  validates :tracking_number, :tracking_secret, uniqueness: { scope: :agency_id }

  # Enums
  enum :status, %i[registered sent checked_in checked_out]

  # Hooks
  before_validation :generate_tracking_number, :generate_tracking_secret

  # Associations
  acts_as_tenant :agency
  belongs_to :origin, class_name: "Branch"
  belongs_to :destination, class_name: "Branch"

  belongs_to :sender, class_name: "Users::Customer"
  belongs_to :receiver, class_name: "Users::Customer"

  belongs_to :registered_by, class_name: "Users::Admin"
  belongs_to :checked_in_by, class_name: "Users::Admin", optional: true
  belongs_to :checked_out_by, class_name: "Users::Admin", optional: true

  def sender_name
    attributes["sender_name"] || sender.full_name
  end

  def receiver_name
    attributes["receiver_name"] || receiver.full_name
  end

  def sender_telephone
    attributes["sender_telephone"] || sender.telephone
  end

  def receiver_telephone
    attributes["receiver_telephone"] || receiver.telephone
  end

  private

  def generate_tracking_number
    self.tracking_number = "#{Time.current.to_i.to_s(36)}-#{encode_branches}"
  end

  def generate_tracking_secret
    encode_timestamp = (Time.current.to_f * 1000000).to_i.to_s(36)

    self.tracking_secret = "#{SecureRandom.hex(2).upcase}-#{encode_timestamp}"
  end

  def encode_branches
    "#{(agency_id.to_s + origin_id.to_s + destination_id.to_s).to_i.to_s(36)}"
  end
end
