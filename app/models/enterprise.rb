class Enterprise < ApplicationRecord
  include NameConstants
  BRANCH_HEADERS = %w[name telephone action]
  USER_HEADERS = %w[full_name telephone branch role invited_by action]

  # Validations
  validates :name, presence: true,
                  length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) },
                  uniqueness: true
  validates :category, presence: true
  validates :description, :city, presence: true, if: -> { merchant? }

  # Enums
  enum :category, %i[agency special merchant]

  # Associations
  belongs_to :marketer, optional: true, counter_cache: true
  has_many :branches, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :managers, -> { where(role: "manager") },
                      class_name: "Users::Admin",
                      dependent: :destroy
  has_many_attached :images

  def self.create_new(enterprise_params, manager_params)
    password = SecureRandom.hex(8)
    enterprise = Enterprise.new(enterprise_params)
    manager = enterprise.managers.build(
      manager_params.merge({ password:, password_confirmation: password })
    )

    ActiveRecord::Base.transaction  do
      enterprise.save!
      manager.save!
      # send confirmation text message
    end
    [ enterprise, manager ]
  rescue ActiveRecord::RecordInvalid
    [ enterprise, manager ]
  end
end
