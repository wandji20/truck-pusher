class Branch < ApplicationRecord
  include NameConstants

  # Validations
  validates :name, presence: true,
                  length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) },
                  uniqueness: { scope: :agency_id }
  validates :telephone, presence: true, format: { with: /\A\d{9}\z/ }
  validates :telephone, uniqueness: { scope: :agency_id, case_sensitive: false }

  # Associations
  acts_as_tenant :agency
  has_many :operators, -> { where(role: "operator") },
                        class_name: "Users::Admin",
                        dependent: :destroy

  def self.create_new(params)
    user = params.delete :user
    branch = Branch.new(params)

    ActiveRecord::Base.transaction do
      branch.save!
      user.update!({ branch_id: branch.id }) unless user.branch.present?
    end
    branch

  rescue ActiveRecord::RecordInvalid
    branch
  end
end
