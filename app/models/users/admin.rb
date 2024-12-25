module Users
  class Admin < User
    # Enums
    enum :role, %i[operator manager]

    # Associations
    belongs_to :branch, optional: true
    acts_as_tenant :agency
  end
end
