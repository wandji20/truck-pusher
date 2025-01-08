class Agency < ApplicationRecord
  include NameConstants
  BRANCH_HEADERS = %w[name telephone action]
  USER_HEADERS = %w[full_name telephone branch role invited_by action]

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

  def self.create_new(agency_params, manager_params)
    password = SecureRandom.hex(8)
    agency = Agency.new(agency_params)
    manager = agency.managers.build(
      manager_params.merge({ password:, password_confirmation: password })
    )

    ActiveRecord::Base.transaction  do
      agency.save!
      manager.save!
      # send confirmation text message
    end
    [ agency, manager ]
  rescue ActiveRecord::RecordInvalid
    [ agency, manager ]
  end
end
